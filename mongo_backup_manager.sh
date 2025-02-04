#!/bin/bash

# MongoDB Docker Backup Manager

🇹🇷 Docker üzerinde çalışan MongoDB veritabanları için Türkçe arayüzlü yedekleme yönetim aracı

# Kullanım: ./mongo_backup_manager.sh

# Dil seçimi için fonksiyon
select_language() {
    clear
    echo "============================================"
    echo "       Language Selection / Dil Seçimi      "
    echo "============================================"
    echo "1) Türkçe"
    echo "2) English"
    echo "----------------------------------------"
    read -p "Select language / Dil seçin (1/2): " lang_choice

    case $lang_choice in
        1)
            LANG_FILE="lang/tr.sh"
            ;;
        2)
            LANG_FILE="lang/en.sh"
            ;;
        *)
            LANG_FILE="lang/tr.sh"  # Varsayılan olarak Türkçe
            ;;
    esac

    # Dil dosyasını yükle
    if [ -f "$LANG_FILE" ]; then
        source "$LANG_FILE"
    else
        echo "Error: Language file not found! / Hata: Dil dosyası bulunamadı!"
        exit 1
    fi
}

# Program başlangıcında dil seçimi yap
select_language

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
        error "$ERR_NO_CONTAINERS"
    fi
    
    echo "----------------------------------------"
    local max_choice=$((counter - 1))
    
    # Eğer tek container varsa otomatik seç
    if [ $max_choice -eq 1 ]; then
        log "$MSG_SINGLE_CONTAINER: ${container_names[0]}"
        sleep 2  # 2 saniye bekle
        CONTAINER_ID="${container_ids[0]}"
        CONTAINER_NAME="${container_names[0]}"
    else
        read -p "$PROMPT_CHOICE (1-$max_choice): " choice
        
        if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt $max_choice ]; then
            error "$ERR_INVALID_CHOICE"
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
    log "$MSG_TESTING_CONNECTION"
    if ! test_mongo_connection "$CONTAINER_ID"; then
        warning "$MSG_AUTH_REQUIRED"
        get_mongo_credentials
    else
        log "$MSG_AUTH_SUCCESS"
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
    info "$INFO_AUTH"
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
        log "$MSG_AUTH_TESTING"
        if docker exec "$CONTAINER_ID" mongosh --quiet --username "$MONGO_USER" --password "$MONGO_PASS" --authenticationDatabase "$AUTH_DB" --eval "db.getMongo().getDBs()" &>/dev/null; then
            log "$MSG_AUTH_SUCCESS"
            return 0
        else
            warning "$ERR_AUTH_FAILED (Deneme $attempt/$max_attempts)"
            ((attempt++))
            
            if [ $attempt -le $max_attempts ]; then
                read -p "$PROMPT_RETRY" retry
                if [[ $retry =~ ^[Hh]$ ]]; then
                    error "$ERR_AUTH_FAILED"
                fi
            fi
        fi
    done
    
    error "$ERR_MAX_ATTEMPTS"
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
    info "$INFO_BACKUP_DIR"
    info "$INFO_OS: $(uname -s)"
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        info "$INFO_DISTRIBUTION: $NAME"
    fi
    echo "----------------------------------------"
    echo "1) $OPT_DEFAULT_DIR ($default_dir)"
    echo "2) $OPT_CUSTOM_DIR"
    read -p "$PROMPT_CHOICE (1/2): " choice

    case $choice in
        1)
            BACKUP_DIR="$default_dir"
            ;;
        2)
            read -p "$PROMPT_BACKUP_DIR: " BACKUP_DIR
            ;;
        *)
            BACKUP_DIR="$default_dir"
            warning "$ERR_INVALID_CHOICE $OPT_DEFAULT_DIR"
            ;;
    esac

    # Dizin oluşturma izinlerini kontrol et
    if ! mkdir -p "$BACKUP_DIR" 2>/dev/null; then
        warning "$ERR_DIR_CREATE: $BACKUP_DIR"
        warning "Sudo ile deneniyor..."
        sudo mkdir -p "$BACKUP_DIR" || error "$ERR_DIR_CREATE"
        sudo chown $(whoami) "$BACKUP_DIR" || error "$ERR_DIR_PERMS"
    fi

    info "$INFO_BACKUP_DIR: $BACKUP_DIR"
    info "Dizin izinleri: $(ls -ld "$BACKUP_DIR")"
}

# Veritabanı seç
select_database() {
    echo
    info "$INFO_AVAILABLE_BACKUPS"
    echo "----------------------------------------"
    
    # Veritabanı listesini diziye al
    declare -a db_list
    local counter=1
    
    # Tüm veritabanları seçeneğini ekle
    db_list+=("all")
    echo "$counter) $OPT_ALL_DBS"
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
        error "$ERR_NO_DATABASE"
    fi
    
    read -p "$PROMPT_CHOICE (1-$max_choice): " choice
    
    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt $max_choice ]; then
        error "$ERR_INVALID_CHOICE"
    fi
    
    # Seçilen veritabanını al (0-based index)
    DB_NAME="${db_list[$((choice-1))]}"
    
    if [ "$DB_NAME" = "all" ]; then
        info "$OPT_ALL_DBS"
    else
        info "$INFO_SELECTED_DATABASE: $DB_NAME"
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
    info "$INFO_BACKUP_DESC"
    read -p "$MSG_ENTER_BACKUP_DESC: " backup_description
    backup_description=${backup_description:-"$MSG_DEFAULT_DESC"}
    
    local backup_path="${BACKUP_DIR}/${DB_NAME}_${CURRENT_DATE}"
    
    log "$MSG_BACKUP_STARTED"
    
    log "$MSG_BACKUP_STARTED"
    local mongo_cmd="mongodump"
    
    if [ -n "$MONGO_USER" ] && [ -n "$MONGO_PASS" ]; then
        mongo_cmd="$mongo_cmd --username $MONGO_USER --password $MONGO_PASS --authenticationDatabase $AUTH_DB"
    fi

    # Container'da geçici dizin oluştur
    docker exec "$CONTAINER_ID" rm -rf /dump
    docker exec "$CONTAINER_ID" mkdir -p /dump

    if [ "$DB_NAME" = "all" ]; then
        docker exec "$CONTAINER_ID" $mongo_cmd --out /dump || error "$ERR_BACKUP_FAILED"
        mkdir -p "$backup_path/dump"
        docker cp "${CONTAINER_ID}:/dump/." "$backup_path/dump/" || error "$ERR_COPY_FAILED"
    else
        docker exec "$CONTAINER_ID" $mongo_cmd --db "$DB_NAME" --out /dump || error "$ERR_BACKUP_FAILED"
        mkdir -p "$backup_path/dump"
        docker cp "${CONTAINER_ID}:/dump/$DB_NAME/." "$backup_path/dump/$DB_NAME/" || error "$ERR_COPY_FAILED"
    fi

    docker exec "$CONTAINER_ID" rm -rf /dump
    
    # Yedek meta bilgilerini kaydet
    echo "description=$backup_description" > "$backup_path/backup.info"
    echo "date=$CURRENT_DATE" >> "$backup_path/backup.info"
    echo "database=$DB_NAME" >> "$backup_path/backup.info"
    echo "container=$CONTAINER_NAME" >> "$backup_path/backup.info"
    
    local backup_size=$(get_dir_size "$backup_path")
    log_history "$MSG_BACKUP_COMPLETED" "$DB_NAME - $backup_description ($backup_size)"
    
    log "$MSG_BACKUP_COMPLETED: $backup_path ($backup_size)"
}

# Yedekleri listele
list_backups() {
    echo
    info "$INFO_AVAILABLE_BACKUPS"
    echo "----------------------------------------"
    if [ -d "$BACKUP_DIR" ]; then
        declare -a backup_list
        local counter=1
        
        printf "%-3s %-25s %-15s %-30s %s\n" "#" "$INFO_DATE" "$INFO_SIZE" "$INFO_BACKUP_DESC" "$INFO_SELECTED_DATABASE"
        echo "--------------------------------------------------------------------------------"
        
        while read -r backup; do
            if [ "$DB_NAME" = "all" ]; then
                if [ -d "$BACKUP_DIR/$backup/dump" ]; then
                    backup_list+=("$backup")
                    local date_str=$(echo "$backup" | grep -o '[0-9]\{8\}_[0-9]\{6\}')
                    local formatted_date=$(format_date "$date_str")
                    local size=$(get_dir_size "$BACKUP_DIR/$backup")
                    local description="$MSG_DEFAULT_DESC"
                    local db_name="$OPT_ALL_DBS"
                    
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
                    local description="$MSG_DEFAULT_DESC"
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
            warning "$MSG_NO_BACKUPS"
        fi
    else
        warning "$MSG_NO_BACKUPS"
    fi
    echo "----------------------------------------"
    
    # Son işlemleri göster
    if [ -f "/tmp/mongo_backup_history.log" ]; then
        echo
        info "$INFO_BACKUP_HISTORY"
        echo "----------------------------------------"
        cat "/tmp/mongo_backup_history.log"
        echo "----------------------------------------"
    fi
    
    read -p "$PROMPT_CONTINUE"
}

# Geri yükleme işlemi
do_restore() {
    echo
    info "$INFO_AVAILABLE_BACKUPS"
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
        error "$MSG_NO_BACKUPS"
    fi
    
    echo "----------------------------------------"
    local max_choice=${#backup_list[@]}
    read -p "$PROMPT_BACKUP_NUMBER (1-$max_choice): " choice
    
    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt $max_choice ]; then
        error "$ERR_INVALID_CHOICE"
    fi
    
    # Seçilen yedeğin adını al
    local backup_name="${backup_list[$((choice-1))]}"
    local restore_path="$BACKUP_DIR/$backup_name"
    
    if [ ! -d "$restore_path" ]; then
        error "$ERR_BACKUP_NOT_FOUND: $restore_path"
    fi

    echo
    info "$INFO_RESTORE_OPTIONS"
    echo "1) $OPT_RESTORE_DROP"
    echo "2) $OPT_RESTORE_KEEP"
    read -p "$PROMPT_CHOICE (1/2): " restore_choice

    log "$MSG_RESTORE_STARTED"
    
    # Container'da geçici dizin oluştur
    docker exec "$CONTAINER_ID" rm -rf /dump
    docker exec "$CONTAINER_ID" mkdir -p /dump

    # Yedeği container'a kopyala
    log "$MSG_COPYING_FILES"
    if [ "$DB_NAME" = "all" ]; then
        docker cp "$restore_path/dump/." "${CONTAINER_ID}:/dump/" || error "$ERR_COPY_FAILED"
    else
        docker cp "$restore_path/dump/$DB_NAME/." "${CONTAINER_ID}:/dump/$DB_NAME/" || error "$ERR_COPY_FAILED"
    fi

    # Restore işlemi
    log "$MSG_RESTORE_STARTED"
    local mongo_cmd="mongorestore"
    
    if [ -n "$MONGO_USER" ] && [ -n "$MONGO_PASS" ]; then
        mongo_cmd="$mongo_cmd --username $MONGO_USER --password $MONGO_PASS --authenticationDatabase $AUTH_DB"
    fi

    if [ "$restore_choice" = "1" ]; then
        if [ "$DB_NAME" = "all" ]; then
            docker exec "$CONTAINER_ID" $mongo_cmd --drop /dump || error "$ERR_RESTORE_FAILED"
        else
            docker exec "$CONTAINER_ID" $mongo_cmd --nsInclude="${DB_NAME}.*" --drop /dump || error "$ERR_RESTORE_FAILED"
        fi
    else
        if [ "$DB_NAME" = "all" ]; then
            docker exec "$CONTAINER_ID" $mongo_cmd /dump || error "$ERR_RESTORE_FAILED"
        else
            docker exec "$CONTAINER_ID" $mongo_cmd --nsInclude="${DB_NAME}.*" /dump || error "$ERR_RESTORE_FAILED"
        fi
    fi

    docker exec "$CONTAINER_ID" rm -rf /dump
    log "$MSG_RESTORE_COMPLETED"
}

# Yedek sil
delete_backup() {
    echo
    info "$INFO_DELETABLE_BACKUPS"
    echo "----------------------------------------"
    
    # Yedekleri numaralandır
    declare -a backup_list
    local counter=1
    
    printf "%-3s %-25s %-15s %-30s %s\n" "#" "$INFO_DATE" "$INFO_SIZE" "$INFO_BACKUP_DESC" "$INFO_SELECTED_DATABASE"
    echo "--------------------------------------------------------------------------------"
    
    # Önce tüm yedekleri bir diziye al
    while read -r backup; do
        if [ -d "$BACKUP_DIR/$backup/$DB_NAME" ] || [ -d "$BACKUP_DIR/$backup/dump/$DB_NAME" ]; then
            backup_list+=("$backup")
            local date_str=$(echo "$backup" | grep -o '[0-9]\{8\}_[0-9]\{6\}')
            local formatted_date=$(format_date "$date_str")
            local size=$(get_dir_size "$BACKUP_DIR/$backup")
            local description="$MSG_DEFAULT_DESC"
            local db_name="$DB_NAME"
            
            if [ -f "$BACKUP_DIR/$backup/backup.info" ]; then
                description=$(grep "^description=" "$BACKUP_DIR/$backup/backup.info" | cut -d= -f2)
                db_name=$(grep "^database=" "$BACKUP_DIR/$backup/backup.info" | cut -d= -f2)
            fi
            
            printf "%-3d %-25s %-15s %-30s %s\n" "$counter" "$formatted_date" "$size" "$description" "$db_name"
            ((counter++))
        fi
    done < <(find "$BACKUP_DIR" -maxdepth 1 -type d ! -path "$BACKUP_DIR" -exec basename {} \;)
    
    if [ ${#backup_list[@]} -eq 0 ]; then
        warning "$MSG_NO_BACKUPS"
        return
    fi
    
    echo "----------------------------------------"
    local max_choice=${#backup_list[@]}
    read -p "$PROMPT_DELETE_NUMBER" choice
    
    if [ "$choice" = "0" ]; then
        return
    fi
    
    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt $max_choice ]; then
        error "$ERR_INVALID_CHOICE"
    fi
    
    # Seçilen yedeğin adını al
    local backup_name="${backup_list[$((choice-1))]}"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    echo
    info "$MSG_WARNING: $backup_name"
    read -p "$MSG_CONFIRM_DELETE (e/H): " confirm
    
    if [ "$confirm" = "e" ] || [ "$confirm" = "E" ]; then
        local backup_size=$(get_dir_size "$backup_path")
        rm -rf "$backup_path"
        log "$MSG_BACKUP_DELETED: $backup_path"
        log_history "$MSG_BACKUP_DELETED" "$DB_NAME - $backup_size"
    else
        warning "$MSG_DELETE_CANCELLED"
    fi
}

# Son işlemleri görüntüle
show_history() {
    echo
    info "$INFO_BACKUP_HISTORY"
    echo "----------------------------------------"
    if [ -f "/tmp/mongo_backup_history.log" ]; then
        cat "/tmp/mongo_backup_history.log"
    else
        warning "$MSG_NO_HISTORY"
    fi
    echo "----------------------------------------"
    read -p "$PROMPT_CONTINUE"
}

# Ana menü
show_menu() {
    clear
    echo "============================================"
    echo "       $MENU_TITLE         "
    echo "============================================"
    
    # Container ve auth bilgilerini yükle
    if [ -f /tmp/mongo_container.conf ]; then
        source /tmp/mongo_container.conf
    fi
    if [ -f /tmp/mongo_auth.conf ]; then
        source /tmp/mongo_auth.conf
    fi
    
    if [ -n "$CONTAINER_NAME" ]; then
        info "$INFO_SELECTED_CONTAINER: $CONTAINER_NAME"
        if [ -n "$MONGO_USER" ]; then
            info "$INFO_AUTH: $MONGO_USER@$AUTH_DB"
        fi
    fi
    if [ -n "$DB_NAME" ]; then
        info "$INFO_SELECTED_DATABASE: $DB_NAME"
    fi
    echo "----------------------------------------"
    
    # Container seçili değilse sadece container seçim ve çıkış seçeneklerini göster
    if [ -z "$CONTAINER_ID" ]; then
        echo "1) $MENU_CONTAINER_SELECT"
        echo "2) $MENU_EXIT"
        echo "============================================"
        return
    fi
    
    # Container seçili ise diğer seçenekleri göster
    echo "1) $MENU_BACKUP"
    echo "2) $MENU_RESTORE"
    echo "3) $MENU_LIST"
    echo "4) $MENU_DELETE"
    echo "5) $MENU_CONTAINER_CHANGE"
    echo "6) $MENU_DATABASE_CHANGE"
    echo "7) $MENU_HISTORY"
    echo "8) $MENU_EXIT"
    echo "============================================"
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

# Container seçildikten sonra doğrudan veritabanı seçimine git
select_database

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
        printf "$PROMPT_CHOICE_RANGE" 1 2
        read choice
        case $choice in
            1)  # Container Seç
                select_container
                select_database  # Container seçiminden sonra doğrudan veritabanı seçimine git
                ;;
            2)  # Çıkış
                echo "Program sonlandırılıyor..."
                exit 0
                ;;
            *)
                warning "$ERR_INVALID_CHOICE"
                read -p "$PROMPT_CONTINUE"
                ;;
        esac
        continue
    fi
    
    printf "$PROMPT_CHOICE_RANGE" 1 8
    read choice
    case $choice in
        1)  # Yedek Al
            do_backup
            read -p "$PROMPT_CONTINUE"
            ;;
        2)  # Yedek Geri Yükle
            do_restore
            read -p "$PROMPT_CONTINUE"
            ;;
        3)  # Yedekleri Listele
            list_backups
            ;;
        4)  # Yedek Sil
            delete_backup
            read -p "$PROMPT_CONTINUE"
            ;;
        5)  # Container Değiştir
            select_container
            select_database  # Container değişiminden sonra doğrudan veritabanı seçimine git
            ;;
        6)  # Veritabanı Değiştir
            select_database
            ;;
        7)  # Son İşlemler
            show_history
            ;;
        8)  # Çıkış
            echo "Program sonlandırılıyor..."
            exit 0
            ;;
        *)
            warning "$ERR_INVALID_CHOICE"
            read -p "$PROMPT_CONTINUE"
            ;;
    esac
done 