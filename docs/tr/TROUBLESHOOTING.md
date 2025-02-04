# MongoDB Docker Yedekleme Yöneticisi Sorun Giderme Rehberi

## 1. Bağlantı Sorunları

### 1.1 Container Bağlantı Sorunları

#### Sorun: Container bulunamıyor

- **Belirtiler**: "Docker'da MongoDB container'ı bulunamadı" hatası
- **Çözüm**:
  1. Docker servisinin çalıştığını kontrol edin: `docker ps`
  2. MongoDB container'ının çalışır durumda olduğunu doğrulayın
  3. Container ismini ve ID'sini kontrol edin

#### Sorun: Container yanıt vermiyor

- **Belirtiler**: "Container'a bağlanılamıyor" hatası
- **Çözüm**:
  1. Container'ı yeniden başlatın: `docker restart <container_id>`
  2. Docker logs'ları kontrol edin: `docker logs <container_id>`
  3. Container'ın kaynak kullanımını kontrol edin

### 1.2 MongoDB Bağlantı Sorunları

#### Sorun: Kimlik doğrulama hatası

- **Belirtiler**: "Kimlik doğrulama başarısız" hatası
- **Çözüm**:
  1. Kullanıcı adı ve şifreyi kontrol edin
  2. Auth database'ini doğrulayın
  3. MongoDB kullanıcı yetkilerini kontrol edin

#### Sorun: SSL/TLS bağlantı hatası

- **Belirtiler**: "SSL bağlantısı kurulamadı" hatası
- **Çözüm**:
  1. SSL sertifikalarının doğru konumda olduğunu kontrol edin
  2. Sertifikaların geçerlilik sürelerini kontrol edin
  3. MongoDB SSL yapılandırmasını kontrol edin

## 2. Yedekleme Sorunları

### 2.1 Disk Alanı Sorunları

#### Sorun: Yetersiz disk alanı

- **Belirtiler**: "Disk alanı yetersiz" hatası
- **Çözüm**:
  1. Disk kullanımını kontrol edin: `df -h`
  2. Eski yedekleri temizleyin
  3. Yedekleme dizinini farklı bir diske taşıyın

#### Sorun: Yedek dizini erişim hatası

- **Belirtiler**: "Dizine yazma izni yok" hatası
- **Çözüm**:
  1. Dizin izinlerini kontrol edin: `ls -la`
  2. Dizin sahipliğini düzeltin: `chown`
  3. Dizin izinlerini düzenleyin: `chmod`

### 2.2 Yedekleme İşlem Sorunları

#### Sorun: Yedekleme zaman aşımı

- **Belirtiler**: "Yedekleme işlemi zaman aşımına uğradı" hatası
- **Çözüm**:
  1. Veritabanı boyutunu kontrol edin
  2. Network bağlantısını kontrol edin
  3. Koleksiyon bazlı yedekleme deneyin

#### Sorun: Bozuk yedek

- **Belirtiler**: "Yedek dosyası bozuk" hatası
- **Çözüm**:
  1. Yedekleme işlemini tekrarlayın
  2. Disk hatalarını kontrol edin
  3. MongoDB versiyon uyumluluğunu kontrol edin

## 3. Geri Yükleme Sorunları

### 3.1 Veri Tutarlılığı Sorunları

#### Sorun: Veri tutarsızlığı

- **Belirtiler**: "Veri tutarsızlığı tespit edildi" hatası
- **Çözüm**:
  1. Yedek dosyasının bütünlüğünü kontrol edin
  2. MongoDB versiyonlarını kontrol edin
  3. Koleksiyon indekslerini yeniden oluşturun

#### Sorun: Eksik koleksiyonlar

- **Belirtiler**: "Bazı koleksiyonlar eksik" hatası
- **Çözüm**:
  1. Yedek içeriğini kontrol edin
  2. Koleksiyon isimlerini doğrulayın
  3. Yedekleme ayarlarını kontrol edin

### 3.2 Performans Sorunları

#### Sorun: Yavaş geri yükleme

- **Belirtiler**: Geri yükleme işlemi normalden yavaş
- **Çözüm**:
  1. Sistem kaynaklarını kontrol edin
  2. İndeksleri geri yükleme sonrasına bırakın
  3. Geri yükleme işlemini parçalara bölün

## 4. Sistem Sorunları

### 4.1 Kaynak Kullanımı

#### Sorun: Yüksek CPU kullanımı

- **Belirtiler**: Sistem yavaşlaması, yüksek CPU kullanımı
- **Çözüm**:
  1. İşlem önceliğini düşürün
  2. Eşzamanlı işlemleri sınırlayın
  3. Sistem kaynaklarını izleyin

#### Sorun: Bellek yetersizliği

- **Belirtiler**: "Yetersiz bellek" hatası
- **Çözüm**:
  1. Swap kullanımını kontrol edin
  2. Gereksiz servisleri kapatın
  3. Bellek limitlerini ayarlayın

### 4.2 Network Sorunları

#### Sorun: Network timeout

- **Belirtiler**: "Network bağlantısı zaman aşımına uğradı" hatası
- **Çözüm**:
  1. Network bağlantısını test edin
  2. Firewall ayarlarını kontrol edin
  3. Timeout değerlerini artırın

## 5. Güvenlik Sorunları

### 5.1 Yetkilendirme Sorunları

#### Sorun: Yetkisiz erişim

- **Belirtiler**: "Yetki hatası" mesajı
- **Çözüm**:
  1. Kullanıcı rollerini kontrol edin
  2. Yetki seviyelerini düzenleyin
  3. Güvenlik loglarını inceleyin

### 5.2 Şifreleme Sorunları

#### Sorun: Şifreleme hatası

- **Belirtiler**: "Şifreleme/şifre çözme hatası" mesajı
- **Çözüm**:
  1. Şifreleme anahtarlarını kontrol edin
  2. SSL sertifikalarını yenileyin
  3. Güvenlik protokollerini güncelleyin

## 6. Log ve İzleme

### Sorun Tespiti için Log Analizi

#### Önemli Log Dosyaları:

1. MongoDB logları: `/var/log/mongodb/`
2. Docker logları: `docker logs`
3. Sistem logları: `/var/log/syslog`

#### Log Analiz Komutları:

```bash
# MongoDB log analizi
tail -f /var/log/mongodb/mongod.log

# Docker container logları
docker logs -f <container_id>

# Sistem kaynak kullanımı
top
htop
```

## 7. İletişim ve Destek

### Hata Bildirimi:

1. Hata mesajının tam çıktısını alın
2. Sistem bilgilerini toplayın
3. Yapılan son değişiklikleri not edin
4. GitHub üzerinden issue açın

### Yardım Alma:

1. Dokümantasyonu kontrol edin
2. GitHub issues bölümünü kontrol edin
3. MongoDB topluluk forumlarını ziyaret edin
