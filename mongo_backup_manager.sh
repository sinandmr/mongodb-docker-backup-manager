#!/bin/bash

# MongoDB Docker Backup Manager

🇹🇷 Docker üzerinde çalışan MongoDB veritabanları için Türkçe arayüzlü yedekleme yönetim aracı

# Kullanım: ./mongo_backup_manager.sh

# Konsolu temizle
clear

# Renk tanımlamaları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Varsayılan değerler
CURRENT_DATE=$(date +%Y%m%d_%H%M%S)
CONFIG_FILE="backup_config.conf"
MONGO_USER=""
MONGO_PASS=""
AUTH_DB="admin"
DB_NAME=""
CONTAINER_ID=""
CONTAINER_NAME=""

# Fonksiyonlar
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[HATA] $1${NC}" >&2
    exit 1
}

warning() {
    echo -e "${YELLOW}[UYARI] $1${NC}"
}

info() {
    echo -e "${BLUE}$1${NC}"
}

# Docker container listesini al
get_containers() {
    docker ps --format "{{.ID}}\t{{.Names}}\t{{.Image}}" | grep "mongo"
}

# MongoDB bağlantısını test et
test_mongo_connection() {
    local container_id="$1"
    docker exec "$container_id" mongosh --quiet --eval "db.getMongo().getDBs()" &>/dev/null
    return $?
}

# Container seç
select_container() {
    echo
    info "MongoDB Container Listesi:"
    echo "----------------------------------------"
    
    # Container listesini al ve diziye kaydet
    declare -a container_ids
    declare -a container_names
    declare -a container_images
    local counter=1
    
    while IFS=$'\t' read -r id name image; do
        container_ids+=("$id")
        container_names+=("$name")
        container_images+=("$image")
        echo "$counter) $name - $image"
        ((counter++))
    done < <(get_containers)
    
    if [ $counter -eq 1 ]; then
        error "Çalışan MongoDB container'ı bulunamadı!"
    fi
    
    echo "----------------------------------------"
    local max_choice=$((counter - 1))
    
    # Eğer tek container varsa otomatik seç
    if [ $max_choice -eq 1 ]; then
        log "Tek container mevcut olduğu için otomatik seçildi: ${container_names[0]}"
        sleep 2  # 2 saniye bekle
        CONTAINER_ID="${container_ids[0]}"
        CONTAINER_NAME="${container_names[0]}"
    else
        read -p "Container numarasını girin (1-$max_choice): " choice
        
        if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt $max_choice ]; then
            error "Geçersiz seçim!"
        fi
        
        # Seçilen container'ın bilgilerini al (0-based index)
        local idx=$((choice-1))
        CONTAINER_ID="${container_ids[$idx]}"
        CONTAINER_NAME="${container_names[$idx]}"
    fi
    
    # Container bilgilerini geçici dosyaya kaydet
    echo "CONTAINER_ID='$CONTAINER_ID'" > /tmp/mongo_container.conf
    echo "CONTAINER_NAME='$CONTAINER_NAME'" >> /tmp/mongo_container.conf
    
    # Önce auth olmadan bağlantıyı dene
    log "MongoDB bağlantısı test ediliyor..."
    if ! test_mongo_connection "$CONTAINER_ID"; then
        warning "Auth gerektiren bir MongoDB instance'ı tespit edildi."
        get_mongo_credentials
    else
        log "Bağlantı başarılı (auth gerektirmiyor)"
        # Auth gerektirmediği için auth bilgilerini temizle
        MONGO_USER=""
        MONGO_PASS=""
        AUTH_DB="admin"
        rm -f /tmp/mongo_auth.conf
    fi
}

# MongoDB kimlik bilgilerini al
get_mongo_credentials() {
    echo
    info "MongoDB Kimlik Doğrulama"
    echo "----------------------------------------"
    
    local max_attempts=3
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        read -p "MongoDB kullanıcı adı: " MONGO_USER
        read -s -p "MongoDB şifresi: " MONGO_PASS
        echo
        read -p "Kimlik doğrulama veritabanı [admin]: " input_auth_db
        AUTH_DB=${input_auth_db:-admin}
        
        # Auth bilgilerini geçici dosyaya kaydet
        echo "MONGO_USER=$MONGO_USER" > /tmp/mongo_auth.conf
        echo "MONGO_PASS=$MONGO_PASS" >> /tmp/mongo_auth.conf
        echo "AUTH_DB=$AUTH_DB" >> /tmp/mongo_auth.conf
        
        # Bağlantıyı test et
        log "Kimlik bilgileri test ediliyor..."
        if docker exec "$CONTAINER_ID" mongosh --quiet --username "$MONGO_USER" --password "$MONGO_PASS" --authenticationDatabase "$AUTH_DB" --eval "db.getMongo().getDBs()" &>/dev/null; then
            log "Kimlik doğrulama başarılı"
            return 0
        else
            warning "Kimlik doğrulama başarısız! (Deneme $attempt/$max_attempts)"
            ((attempt++))
            
            if [ $attempt -le $max_attempts ]; then
                read -p "Tekrar denemek ister misiniz? (E/h): " retry
                if [[ $retry =~ ^[Hh]$ ]]; then
                    error "Kimlik doğrulama iptal edildi!"
                fi
            fi
        fi
    done
    
    error "Maksimum deneme sayısına ulaşıldı!"
}

# Veritabanı listesini al
get_databases() {
    local container_id="$1"
    local mongo_cmd="mongosh --quiet"
    
    if [ -n "$MONGO_USER" ] && [ -n "$MONGO_PASS" ]; then
        mongo_cmd="$mongo_cmd --username $MONGO_USER --password $MONGO_PASS --authenticationDatabase $AUTH_DB"
    fi
    
    mongo_cmd="$mongo_cmd --eval \"db.getMongo().getDBs().databases.forEach(function(db) { print(db.name) })\""
    
    docker exec "$container_id" bash -c "$mongo_cmd" || error "Veritabanı listesi alınamadı. Kimlik bilgilerini kontrol edin."
}

# Varsayılan yedek dizinini belirle
get_default_backup_dir() {
    local os_type=$(uname -s)
    local default_dir

    case "$os_type" in
        "Darwin")  # macOS
            default_dir="$HOME/Desktop/mongodb_backups"
            ;;
        "Linux")
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                case "$ID" in
                    "ubuntu"|"debian")
                        default_dir="/var/backups/mongodb"
                        ;;
                    "centos"|"rhel"|"fedora")
                        default_dir="/var/opt/mongodb/backups"
                        ;;
                    *)
                        default_dir="/opt/mongodb/backups"
                        ;;
                esac
            else
                default_dir="/opt/mongodb/backups"
            fi
            ;;
        *)
            default_dir="$HOME/mongodb_backups"
            ;;
    esac

    echo "$default_dir"
}

# Yedek dizinini seç
select_backup_dir() {
    clear
    local default_dir=$(get_default_backup_dir)
    
    echo
    info "Yedek Dizini Seçimi"
    info "İşletim Sistemi: $(uname -s)"
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        info "Dağıtım: $NAME"
    fi
    echo "----------------------------------------"
    echo "1) Varsayılan dizin ($default_dir)"
    echo "2) Özel dizin belirtin"
    read -p "Seçiminiz (1/2): " choice

    case $choice in
        1)
            BACKUP_DIR="$default_dir"
            ;;
        2)
            read -p "Yedek dizini tam yolu: " BACKUP_DIR
            ;;
        *)
            BACKUP_DIR="$default_dir"
            warning "Geçersiz seçim. Varsayılan dizin kullanılıyor."
            ;;
    esac

    # Dizin oluşturma izinlerini kontrol et
    if ! mkdir -p "$BACKUP_DIR" 2>/dev/null; then
        warning "Dizin oluşturulamadı: $BACKUP_DIR"
        warning "Sudo ile deneniyor..."
        sudo mkdir -p "$BACKUP_DIR" || error "Dizin oluşturulamadı!"
        sudo chown $(whoami) "$BACKUP_DIR" || error "Dizin izinleri ayarlanamadı!"
    fi

    info "Yedek dizini: $BACKUP_DIR"
    info "Dizin izinleri: $(ls -ld "$BACKUP_DIR")"
}

# Veritabanı seç
select_database() {
    echo
    info "Veritabanı Listesi:"
    echo "----------------------------------------"
    
    # Veritabanı listesini diziye al
    declare -a db_list
    local counter=1
    
    # Tüm veritabanları seçeneğini ekle
    db_list+=("all")
    echo "$counter) Tüm Veritabanları"
    ((counter++))
    
    # MongoDB'den veritabanı listesini al
    while read -r db_name; do
        if [ -n "$db_name" ]; then  # Boş satırları atla
            db_list+=("$db_name")
            echo "$counter) $db_name"
            ((counter++))
        fi
    done < <(get_databases "$CONTAINER_ID")
    
    echo "----------------------------------------"
    local max_choice=$((counter - 1))
    
    if [ $max_choice -eq 1 ]; then
        error "Veritabanı listesi alınamadı!"
    fi
    
    read -p "Veritabanı numarasını girin (1-$max_choice): " choice
    
    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt $max_choice ]; then
        error "Geçersiz seçim!"
    fi
    
    # Seçilen veritabanını al (0-based index)
    DB_NAME="${db_list[$((choice-1))]}"
    
    if [ "$DB_NAME" = "all" ]; then
        info "Tüm veritabanları seçildi"
    else
        info "Seçilen veritabanı: $DB_NAME"
    fi
}

# Geçmiş işlemleri kaydet
log_history() {
    local action="$1"
    local details="$2"
    local history_file="/tmp/mongo_backup_history.log"
    local max_history=10
    
    # Geçmiş dosyasını oluştur
    touch "$history_file"
    
    # Yeni kaydı dosyanın başına ekle
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $action: $details" | cat - "$history_file" > temp && mv temp "$history_file"
    
    # Sadece son 10 kaydı tut
    tail -n $max_history "$history_file" > temp && mv temp "$history_file"
}

# Dizin boyutunu hesapla
get_dir_size() {
    local dir="$1"
    if [ -d "$dir" ]; then
        du -sh "$dir" | cut -f1
    else
        echo "0B"
    fi
}

# Tarihi okunabilir formata çevir
format_date() {
    local date_str="$1"
    date -j -f "%Y%m%d_%H%M%S" "$date_str" "+%d.%m.%Y %H:%M:%S" 2>/dev/null || echo "$date_str"
}

# Yedekleme işlemi
do_backup() {
    echo
    info "Yedek Açıklaması"
    read -p "Bu yedek için bir açıklama girin: " backup_description
    backup_description=${backup_description:-"Açıklama girilmedi"}
    
    local backup_path="${BACKUP_DIR}/${DB_NAME}_${CURRENT_DATE}"
    
    log "Yedekleme başlatılıyor..."
    
    log "MongoDB dump işlemi başlatılıyor..."
    local mongo_cmd="mongodump"
    
    if [ -n "$MONGO_USER" ] && [ -n "$MONGO_PASS" ]; then
        mongo_cmd="$mongo_cmd --username $MONGO_USER --password $MONGO_PASS --authenticationDatabase $AUTH_DB"
    fi

    # Container'da geçici dizin oluştur
    docker exec "$CONTAINER_ID" rm -rf /dump
    docker exec "$CONTAINER_ID" mkdir -p /dump

    if [ "$DB_NAME" = "all" ]; then
        docker exec "$CONTAINER_ID" $mongo_cmd --out /dump || error "MongoDB dump işlemi başarısız!"
        mkdir -p "$backup_path/dump"
        docker cp "${CONTAINER_ID}:/dump/." "$backup_path/dump/" || error "Yedek dosyaları kopyalanamadı!"
    else
        docker exec "$CONTAINER_ID" $mongo_cmd --db "$DB_NAME" --out /dump || error "MongoDB dump işlemi başarısız!"
        mkdir -p "$backup_path/dump"
        docker cp "${CONTAINER_ID}:/dump/$DB_NAME/." "$backup_path/dump/$DB_NAME/" || error "Yedek dosyaları kopyalanamadı!"
    fi

    docker exec "$CONTAINER_ID" rm -rf /dump
    
    # Yedek meta bilgilerini kaydet
    echo "description=$backup_description" > "$backup_path/backup.info"
    echo "date=$CURRENT_DATE" >> "$backup_path/backup.info"
    echo "database=$DB_NAME" >> "$backup_path/backup.info"
    echo "container=$CONTAINER_NAME" >> "$backup_path/backup.info"
    
    local backup_size=$(get_dir_size "$backup_path")
    log_history "Yedek alındı" "$DB_NAME - $backup_description ($backup_size)"
    
    log "Yedekleme tamamlandı: $backup_path ($backup_size)"
}

# Yedekleri listele
list_backups() {
    echo
    info "Mevcut Yedekler:"
    echo "----------------------------------------"
    if [ -d "$BACKUP_DIR" ]; then
        declare -a backup_list
        local counter=1
        
        printf "%-3s %-25s %-15s %-30s %s\n" "#" "Tarih" "Boyut" "Açıklama" "Veritabanı"
        echo "--------------------------------------------------------------------------------"
        
        while read -r backup; do
            if [ "$DB_NAME" = "all" ]; then
                if [ -d "$BACKUP_DIR/$backup/dump" ]; then
                    backup_list+=("$backup")
                    local date_str=$(echo "$backup" | grep -o '[0-9]\{8\}_[0-9]\{6\}')
                    local formatted_date=$(format_date "$date_str")
                    local size=$(get_dir_size "$BACKUP_DIR/$backup")
                    local description="Açıklama yok"
                    local db_name="Tüm VT"
                    
                    if [ -f "$BACKUP_DIR/$backup/backup.info" ]; then
                        description=$(grep "^description=" "$BACKUP_DIR/$backup/backup.info" | cut -d= -f2)
                        db_name=$(grep "^database=" "$BACKUP_DIR/$backup/backup.info" | cut -d= -f2)
                    fi
                    
                    printf "%-3d %-25s %-15s %-30s %s\n" "$counter" "$formatted_date" "$size" "$description" "$db_name"
                    ((counter++))
                fi
            else
                if [ -d "$BACKUP_DIR/$backup/dump/$DB_NAME" ]; then
                    backup_list+=("$backup")
                    local date_str=$(echo "$backup" | grep -o '[0-9]\{8\}_[0-9]\{6\}')
                    local formatted_date=$(format_date "$date_str")
                    local size=$(get_dir_size "$BACKUP_DIR/$backup")
                    local description="Açıklama yok"
                    local db_name="$DB_NAME"
                    
                    if [ -f "$BACKUP_DIR/$backup/backup.info" ]; then
                        description=$(grep "^description=" "$BACKUP_DIR/$backup/backup.info" | cut -d= -f2)
                    fi
                    
                    printf "%-3d %-25s %-15s %-30s %s\n" "$counter" "$formatted_date" "$size" "$description" "$db_name"
                    ((counter++))
                fi
            fi
        done < <(find "$BACKUP_DIR" -maxdepth 1 -type d ! -path "$BACKUP_DIR" -exec basename {} \;)
        
        if [ ${#backup_list[@]} -eq 0 ]; then
            warning "Henüz yedek bulunmuyor."
        fi
    else
        warning "Henüz yedek bulunmuyor."
    fi
    echo "----------------------------------------"
    
    # Son işlemleri göster
    if [ -f "/tmp/mongo_backup_history.log" ]; then
        echo
        info "Son İşlemler:"
        echo "----------------------------------------"
        cat "/tmp/mongo_backup_history.log"
        echo "----------------------------------------"
    fi
    
    read -p "Devam etmek için ENTER tuşuna basın..."
}

# Geri yükleme işlemi
do_restore() {
    echo
    info "Mevcut Yedekler:"
    echo "----------------------------------------"
    
    # Yedekleri numaralandır
    declare -a backup_list
    local counter=1
    
    # Önce tüm yedekleri bir diziye al
    while read -r backup; do
        # Yedek dizininin geçerli olup olmadığını kontrol et
        if [ "$DB_NAME" = "all" ]; then
            if [ -d "$BACKUP_DIR/$backup/dump" ]; then
                backup_list+=("$backup")
                echo "$counter) $backup"
                ((counter++))
            fi
        else
            if [ -d "$BACKUP_DIR/$backup/dump/$DB_NAME" ]; then
                backup_list+=("$backup")
                echo "$counter) $backup"
                ((counter++))
            fi
        fi
    done < <(find "$BACKUP_DIR" -maxdepth 1 -type d ! -path "$BACKUP_DIR" -exec basename {} \;)
    
    if [ ${#backup_list[@]} -eq 0 ]; then
        error "Henüz yedek bulunmuyor!"
    fi
    
    echo "----------------------------------------"
    local max_choice=${#backup_list[@]}
    read -p "Geri yüklenecek yedeğin numarasını girin (1-$max_choice): " choice
    
    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt $max_choice ]; then
        error "Geçersiz seçim!"
    fi
    
    # Seçilen yedeğin adını al
    local backup_name="${backup_list[$((choice-1))]}"
    local restore_path="$BACKUP_DIR/$backup_name"
    
    if [ ! -d "$restore_path" ]; then
        error "Belirtilen yedek dizini bulunamadı: $restore_path"
    fi

    echo
    info "Geri yükleme Seçenekleri:"
    echo "1) Mevcut verileri sil ve yedeği yükle"
    echo "2) Mevcut verileri koru ve yedeği yükle"
    read -p "Seçiminiz (1/2): " restore_choice

    log "Geri yükleme başlatılıyor..."
    
    # Container'da geçici dizin oluştur
    docker exec "$CONTAINER_ID" rm -rf /dump
    docker exec "$CONTAINER_ID" mkdir -p /dump

    # Yedeği container'a kopyala
    log "Yedek dosyaları container'a kopyalanıyor..."
    if [ "$DB_NAME" = "all" ]; then
        docker cp "$restore_path/dump/." "${CONTAINER_ID}:/dump/" || error "Yedek dosyaları kopyalanamadı!"
    else
        docker cp "$restore_path/dump/$DB_NAME/." "${CONTAINER_ID}:/dump/$DB_NAME/" || error "Yedek dosyaları kopyalanamadı!"
    fi

    # Restore işlemi
    log "MongoDB restore işlemi başlatılıyor..."
    local mongo_cmd="mongorestore"
    
    if [ -n "$MONGO_USER" ] && [ -n "$MONGO_PASS" ]; then
        mongo_cmd="$mongo_cmd --username $MONGO_USER --password $MONGO_PASS --authenticationDatabase $AUTH_DB"
    fi

    if [ "$restore_choice" = "1" ]; then
        if [ "$DB_NAME" = "all" ]; then
            docker exec "$CONTAINER_ID" $mongo_cmd --drop /dump || error "MongoDB restore işlemi başarısız!"
        else
            docker exec "$CONTAINER_ID" $mongo_cmd --nsInclude="${DB_NAME}.*" --drop /dump || error "MongoDB restore işlemi başarısız!"
        fi
    else
        if [ "$DB_NAME" = "all" ]; then
            docker exec "$CONTAINER_ID" $mongo_cmd /dump || error "MongoDB restore işlemi başarısız!"
        else
            docker exec "$CONTAINER_ID" $mongo_cmd --nsInclude="${DB_NAME}.*" /dump || error "MongoDB restore işlemi başarısız!"
        fi
    fi

    docker exec "$CONTAINER_ID" rm -rf /dump
    log "Geri yükleme tamamlandı"
}

# Ana menü
show_menu() {
    clear
    echo "============================================"
    echo "       MongoDB Yedekleme Yöneticisi         "
    echo "============================================"
    
    # Container ve auth bilgilerini yükle
    if [ -f /tmp/mongo_container.conf ]; then
        source /tmp/mongo_container.conf
    fi
    if [ -f /tmp/mongo_auth.conf ]; then
        source /tmp/mongo_auth.conf
    fi
    
    if [ -n "$CONTAINER_NAME" ]; then
        info "Seçili Container: $CONTAINER_NAME"
        if [ -n "$MONGO_USER" ]; then
            info "Kimlik Doğrulama: $MONGO_USER@$AUTH_DB"
        fi
    fi
    if [ -n "$DB_NAME" ]; then
        info "Seçili Veritabanı: $DB_NAME"
    fi
    echo "----------------------------------------"
    
    # Container seçili değilse sadece container seçim ve çıkış seçeneklerini göster
    if [ -z "$CONTAINER_ID" ]; then
        echo "1) Container Seç"
        echo "2) Çıkış"
        echo "============================================"
        return
    fi
    
    # Container seçili ise diğer seçenekleri göster
    if [ -z "$DB_NAME" ]; then
        echo "1) Veritabanı Seç"
    else
        echo "1) Yedek Al"
        echo "2) Yedek Geri Yükle"
        echo "3) Yedekleri Listele"
        echo "4) Yedek Sil"
        echo "5) Container Değiştir"
        echo "6) Veritabanı Değiştir"
        echo "7) Çıkış"
    fi
    echo "============================================"
}

# Yedek sil
delete_backup() {
    echo
    info "Silinebilecek Yedekler:"
    echo "----------------------------------------"
    
    # Yedekleri numaralandır
    declare -a backup_list
    local counter=1
    local backups_file="/tmp/backups.txt"
    rm -f "$backups_file"
    
    # Önce tüm yedekleri bir diziye al
    while read -r backup; do
        if [ -d "$BACKUP_DIR/$backup/$DB_NAME" ] || [ -d "$BACKUP_DIR/$backup/dump/$DB_NAME" ]; then
            backup_list+=("$backup")
            echo "$counter) $backup" | tee -a "$backups_file"
            ((counter++))
        fi
    done < <(find "$BACKUP_DIR" -maxdepth 1 -type d ! -path "$BACKUP_DIR" -exec basename {} \;)
    
    if [ ${#backup_list[@]} -eq 0 ]; then
        warning "Silinebilecek yedek bulunmuyor."
        return
    fi
    
    echo "----------------------------------------"
    local max_choice=${#backup_list[@]}
    read -p "Silmek istediğiniz yedeğin numarasını girin (iptal için 0): " choice
    
    if [ "$choice" = "0" ]; then
        return
    fi
    
    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt $max_choice ]; then
        error "Geçersiz seçim!"
    fi
    
    # Seçilen yedeğin adını al
    local backup_name="${backup_list[$((choice-1))]}"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    echo
    info "DİKKAT: $backup_name yedeği silinecek!"
    read -p "Onaylıyor musunuz? (e/H): " confirm
    
    if [ "$confirm" = "e" ] || [ "$confirm" = "E" ]; then
        rm -rf "$backup_path"
        log "Yedek silindi: $backup_path"
    else
        warning "Silme işlemi iptal edildi."
    fi
}

# Program başlangıcında geçici dosyaları temizle
cleanup() {
    rm -f /tmp/mongo_container.conf
    rm -f /tmp/mongo_auth.conf
}

# Program sonlandığında temizlik yap
trap cleanup EXIT

# Ana program
select_backup_dir

# İlk container seçimini yap
select_container

# Tab completion için fonksiyon
_mongo_backup_completion() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="backup restore list delete help"

    case "${prev}" in
        backup|restore|delete)
            # Mevcut yedekleri listele
            if [ -d "$BACKUP_DIR" ]; then
                local backups=$(find "$BACKUP_DIR" -maxdepth 1 -type d ! -path "$BACKUP_DIR" -exec basename {} \;)
                COMPREPLY=( $(compgen -W "${backups}" -- ${cur}) )
            fi
            return 0
            ;;
        *)
            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
            return 0
            ;;
    esac
}

# Tab completion'ı aktif et
complete -F _mongo_backup_completion ./mongo_backup_manager.sh

while true; do
    # Her döngüde container ve auth bilgilerini yükle
    if [ -f /tmp/mongo_container.conf ]; then
        source /tmp/mongo_container.conf
    fi
    if [ -f /tmp/mongo_auth.conf ]; then
        source /tmp/mongo_auth.conf
    fi
    
    show_menu
    
    if [ -z "$CONTAINER_ID" ]; then
        read -p "Seçiminiz (1-2): " choice
        case $choice in
            1)  # Container Seç
                select_container
                ;;
            2)  # Çıkış
                echo "Program sonlandırılıyor..."
                exit 0
                ;;
            *)
                warning "Geçersiz seçim!"
                read -p "Devam etmek için ENTER tuşuna basın..."
                ;;
        esac
        continue
    fi
    
    if [ -z "$DB_NAME" ]; then
        read -p "Seçiminiz (1): " choice
        case $choice in
            1)  # Veritabanı Seç
                select_database
                ;;
            *)
                warning "Geçersiz seçim!"
                read -p "Devam etmek için ENTER tuşuna basın..."
                ;;
        esac
    else
        read -p "Seçiminiz (1-7): " choice
        case $choice in
            1)  # Yedek Al
                do_backup
                read -p "Devam etmek için ENTER tuşuna basın..."
                ;;
            2)  # Yedek Geri Yükle
                do_restore
                read -p "Devam etmek için ENTER tuşuna basın..."
                ;;
            3)  # Yedekleri Listele
                list_backups
                ;;
            4)  # Yedek Sil
                delete_backup
                read -p "Devam etmek için ENTER tuşuna basın..."
                ;;
            5)  # Container Değiştir
                select_container
                DB_NAME=""  # Yeni container seçildiğinde veritabanı seçimini sıfırla
                ;;
            6)  # Veritabanı Değiştir
                select_database
                ;;
            7)  # Çıkış
                echo "Program sonlandırılıyor..."
                exit 0
                ;;
            *)
                warning "Geçersiz seçim!"
                read -p "Devam etmek için ENTER tuşuna basın..."
                ;;
        esac
    fi
done 