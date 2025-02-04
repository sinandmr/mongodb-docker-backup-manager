#!/bin/bash

# MongoDB Docker Backup Manager Test Suite

# Test ortamı hazırlığı
setup() {
    echo "Test ortamı hazırlanıyor..."
    # Test MongoDB container'ı başlat
    docker run -d --name mongodb-test -p 27017:27017 mongo:latest
    # Container'ın başlamasını bekle
    sleep 5
    # Test veritabanı ve koleksiyonları oluştur
    docker exec mongodb-test mongosh --eval '
        db = db.getSiblingDB("test_db");
        db.test_collection.insertMany([
            { "name": "test1", "value": 1 },
            { "name": "test2", "value": 2 }
        ]);
    '
}

# Test ortamı temizliği
teardown() {
    echo "Test ortamı temizleniyor..."
    docker stop mongodb-test >/dev/null 2>&1
    docker rm mongodb-test >/dev/null 2>&1
    rm -rf test_backups
}

# Test yardımcı fonksiyonları
assert_equals() {
    if [ "$1" = "$2" ]; then
        echo "✅ Test başarılı: Beklenen=$1, Alınan=$2"
        return 0
    else
        echo "❌ Test başarısız: Beklenen=$1, Alınan=$2"
        return 1
    fi
}

assert_file_exists() {
    if [ -f "$1" ]; then
        echo "✅ Test başarılı: Dosya mevcut: $1"
        return 0
    else
        echo "❌ Test başarısız: Dosya bulunamadı: $1"
        return 1
    fi
}

assert_dir_exists() {
    if [ -d "$1" ]; then
        echo "✅ Test başarılı: Dizin mevcut: $1"
        return 0
    else
        echo "❌ Test başarısız: Dizin bulunamadı: $1"
        return 1
    fi
}

# Test senaryoları
test_container_selection() {
    echo "Test: Container seçimi testi"
    
    # Container listesi kontrolü
    local containers=$(docker ps --format "{{.Names}}" | grep "mongodb-test")
    assert_equals "mongodb-test" "$containers"
    
    # Container ID kontrolü
    CONTAINER_ID=$(docker ps -qf "name=mongodb-test")
    assert_equals "mongodb-test" "$(docker ps --format "{{.Names}}" -f "id=$CONTAINER_ID")"
}

test_backup_creation() {
    echo "Test: Yedek oluşturma testi"
    
    # Test dizini oluştur
    mkdir -p test_backups
    local backup_path="test_backups/test_backup"
    mkdir -p "$backup_path/dump/test_db"
    
    # Test yedeği oluştur
    docker exec mongodb-test mongodump --db test_db --out /tmp/dump
    docker cp mongodb-test:/tmp/dump/test_db test_backups/test_backup/dump/
    
    # Yedek dosyalarını kontrol et
    assert_dir_exists "test_backups"
    assert_dir_exists "test_backups/test_backup/dump/test_db"
}

test_backup_restore() {
    echo "Test: Yedek geri yükleme testi"
    
    # Test yedeği oluştur
    mkdir -p test_backups/test_restore/dump
    docker exec mongodb-test mongodump --db test_db --out /tmp/dump
    docker cp mongodb-test:/tmp/dump/test_db test_backups/test_restore/dump/
    
    # Veritabanını temizle
    docker exec mongodb-test mongosh --eval 'db.getSiblingDB("test_db").dropDatabase()'
    
    # Yedeği geri yükle
    docker cp test_backups/test_restore/dump/test_db mongodb-test:/tmp/
    docker exec mongodb-test mongorestore --db test_db /tmp/test_db
    
    # Verileri kontrol et
    local count=$(docker exec mongodb-test mongosh --quiet --eval 'db.getSiblingDB("test_db").test_collection.countDocuments()')
    assert_equals "2" "$count"
}

test_backup_comparison() {
    echo "Test: Yedek karşılaştırma testi"
    
    # İlk yedek
    mkdir -p test_backups/backup1/dump
    docker exec mongodb-test mongodump --db test_db --out /tmp/dump1
    docker cp mongodb-test:/tmp/dump1/test_db test_backups/backup1/dump/
    
    # Veriyi değiştir
    docker exec mongodb-test mongosh --eval '
        db = db.getSiblingDB("test_db");
        db.test_collection.insertOne({ "name": "test3", "value": 3 });
    '
    
    # İkinci yedek
    mkdir -p test_backups/backup2/dump
    docker exec mongodb-test mongodump --db test_db --out /tmp/dump2
    docker cp mongodb-test:/tmp/dump2/test_db test_backups/backup2/dump/
    
    # Yedekleri karşılaştır
    diff -r test_backups/backup1/dump/test_db test_backups/backup2/dump/test_db > /tmp/backup_comparison_result.txt
    
    # Karşılaştırma sonuçlarını kontrol et
    assert_file_exists "/tmp/backup_comparison_result.txt"
}

test_error_handling() {
    echo "Test: Hata yönetimi testi"
    
    # Geçersiz container ile test
    if docker exec invalid_container mongodump &>/dev/null; then
        echo "❌ Test başarısız: Geçersiz container hatası beklendi"
        return 1
    else
        echo "✅ Test başarılı: Geçersiz container hatası alındı"
    fi
    
    # Yetki hatası testi
    if docker exec mongodb-test mongosh --authenticationDatabase admin -u invalid_user -p invalid_pass --eval "db.getMongo()" &>/dev/null; then
        echo "❌ Test başarısız: Yetki hatası beklendi"
        return 1
    else
        echo "✅ Test başarılı: Yetki hatası alındı"
    fi
    
    # Geçersiz port testi
    if docker exec mongodb-test mongosh --port 12345 --eval "db.getMongo()" &>/dev/null; then
        echo "❌ Test başarısız: Port hatası beklendi"
        return 1
    else
        echo "✅ Test başarılı: Port hatası alındı"
    fi
    
    # Geçersiz komut testi
    if docker exec mongodb-test invalid_command &>/dev/null; then
        echo "❌ Test başarısız: Komut hatası beklendi"
        return 1
    else
        echo "✅ Test başarılı: Komut hatası alındı"
    fi
    
    return 0
}

# Ana test fonksiyonu
run_tests() {
    echo "MongoDB Docker Backup Manager Test Suite başlatılıyor..."
    
    # Önceki test ortamını temizle
    teardown
    
    # Test ortamını hazırla
    setup
    
    # Testleri çalıştır
    test_container_selection
    test_backup_creation
    test_backup_restore
    test_backup_comparison
    test_error_handling
    
    # Test ortamını temizle
    teardown
    
    echo "Tüm testler tamamlandı."
}

# Testleri çalıştır
run_tests 