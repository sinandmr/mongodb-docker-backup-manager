#!/bin/bash

# Türkçe dil paketi

# Menü metinleri
MENU_TITLE="MongoDB Yedekleme Yöneticisi"
MENU_CONTAINER_SELECT="Container Seç"
MENU_DATABASE_SELECT="Veritabanı Seç"
MENU_DATABASE_CHANGE="Veritabanı Değiştir"
MENU_BACKUP="Yedek Al"
MENU_RESTORE="Yedek Geri Yükle"
MENU_LIST="Yedekleri Listele"
MENU_DELETE="Yedek Sil"
MENU_CONTAINER_CHANGE="Container Değiştir"
MENU_HISTORY="Son İşlemler"
MENU_EXIT="Çıkış"

# Bilgi mesajları
INFO_SELECTED_CONTAINER="Seçili Container"
INFO_SELECTED_DATABASE="Seçili Veritabanı"
INFO_AUTH="Kimlik Doğrulama"
INFO_BACKUP_DIR="Yedek Dizini"
INFO_OS="İşletim Sistemi"
INFO_DISTRIBUTION="Dağıtım"
INFO_BACKUP_DESC="Yedek Açıklaması"
INFO_AVAILABLE_BACKUPS="Mevcut Yedekler"
INFO_BACKUP_HISTORY="Son İşlemler"
INFO_RESTORE_OPTIONS="Geri Yükleme Seçenekleri"
INFO_DELETABLE_BACKUPS="Silinebilecek Yedekler"

# Ek bilgi mesajları
INFO_DATE="Tarih"
INFO_SIZE="Boyut"
INFO_WARNING="DİKKAT"

# İşlem mesajları
MSG_BACKUP_STARTED="Yedekleme başlatılıyor..."
MSG_BACKUP_COMPLETED="Yedekleme tamamlandı"
MSG_RESTORE_STARTED="Geri yükleme başlatılıyor..."
MSG_RESTORE_COMPLETED="Geri yükleme tamamlandı"
MSG_TESTING_CONNECTION="MongoDB bağlantısı test ediliyor..."
MSG_AUTH_REQUIRED="Auth gerektiren bir MongoDB instance'ı tespit edildi."
MSG_AUTH_SUCCESS="Bağlantı başarılı (auth gerektirmiyor)"
MSG_AUTH_TESTING="Kimlik bilgileri test ediliyor..."
MSG_SINGLE_CONTAINER="Tek container mevcut olduğu için otomatik seçildi"
MSG_NO_BACKUPS="Henüz yedek bulunmuyor"
MSG_ENTER_BACKUP_DESC="Bu yedek için bir açıklama girin"
MSG_DEFAULT_DESC="Açıklama girilmedi"
MSG_CONFIRM_DELETE="Onaylıyor musunuz?"
MSG_NO_HISTORY="Henüz işlem geçmişi bulunmuyor"

# Ek işlem mesajları
MSG_COPYING_FILES="Yedek dosyaları container'a kopyalanıyor..."
MSG_WARNING="DİKKAT"
MSG_BACKUP_DELETED="Yedek silindi"
MSG_DELETE_CANCELLED="Silme işlemi iptal edildi"

# Hata mesajları
ERR_NO_CONTAINERS="Çalışan MongoDB container'ı bulunamadı!"
ERR_INVALID_CHOICE="Geçersiz seçim!"
ERR_NO_DATABASE="Önce veritabanı seçmelisiniz!"
ERR_AUTH_FAILED="Kimlik doğrulama başarısız!"
ERR_MAX_ATTEMPTS="Maksimum deneme sayısına ulaşıldı!"
ERR_BACKUP_FAILED="MongoDB dump işlemi başarısız!"
ERR_COPY_FAILED="Yedek dosyaları kopyalanamadı!"
ERR_RESTORE_FAILED="MongoDB restore işlemi başarısız!"
ERR_DIR_CREATE="Dizin oluşturulamadı"
ERR_DIR_PERMS="Dizin izinleri ayarlanamadı"

# Ek hata mesajları
ERR_BACKUP_NOT_FOUND="Belirtilen yedek dizini bulunamadı"

# Seçenekler
OPT_DEFAULT_DIR="Varsayılan dizin"
OPT_CUSTOM_DIR="Özel dizin belirtin"
OPT_ALL_DBS="Tüm Veritabanları"
OPT_RESTORE_DROP="Mevcut verileri sil ve yedeği yükle"
OPT_RESTORE_KEEP="Mevcut verileri koru ve yedeği yükle"

# Onay mesajları
PROMPT_CONTINUE="Devam etmek için ENTER tuşuna basın..."
PROMPT_RETRY="Tekrar denemek ister misiniz? (E/h)"
PROMPT_CHOICE="Seçiminiz"
PROMPT_CHOICE_RANGE="Seçiminiz (%d-%d): "
PROMPT_CHOICE_SINGLE="Seçiminiz (%d): "
PROMPT_BACKUP_NUMBER="Geri yüklenecek yedeğin numarasını girin"
PROMPT_DELETE_NUMBER="Silmek istediğiniz yedeğin numarasını girin (iptal için 0)"
PROMPT_BACKUP_DIR="Yedek dizini tam yolu" 