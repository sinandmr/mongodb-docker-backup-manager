# MongoDB Docker Yedekleme Yöneticisi Katkı Sağlama Rehberi

## 1. Başlarken

### 1.1 Geliştirme Ortamı Kurulumu

1. Repository'yi klonlayın:

```bash
git clone https://github.com/kullaniciadi/mongo-backup-manager.git
cd mongo-backup-manager
```

2. Test ortamını hazırlayın:

```bash
# MongoDB test container'ı başlat
docker run -d --name mongodb-test -p 27017:27017 mongo:latest

# Gerekli bağımlılıkları kur
# (Projenin ihtiyaçlarına göre)
```

### 1.2 Kod Standartları

- Bash script yazım kurallarına uyun
- Fonksiyon ve değişken isimleri açıklayıcı olmalı
- Her fonksiyon için açıklama ekleyin
- Hata kontrollerini unutmayın
- Kodunuzu test edin

## 2. Katkı Sağlama Süreci

### 2.1 Issue Oluşturma

1. GitHub'da yeni bir issue açın
2. Issue template'ini kullanın
3. Detaylı açıklama yapın
4. İlgili etiketleri ekleyin

### 2.2 Pull Request Süreci

1. Yeni bir branch oluşturun:

```bash
git checkout -b feature/yeni-ozellik
# veya
git checkout -b fix/hata-duzeltme
```

2. Değişikliklerinizi yapın ve commit edin:

```bash
git add .
git commit -m "feat: yeni özellik eklendi"
# veya
git commit -m "fix: hata düzeltildi"
```

3. Pull request açın:

- PR template'ini kullanın
- Değişiklikleri detaylı açıklayın
- Test sonuçlarını ekleyin

## 3. Geliştirme Kuralları

### 3.1 Commit Mesajları

Commit mesajları şu formatta olmalı:

- `feat: yeni özellik`
- `fix: hata düzeltme`
- `docs: dokümantasyon güncellemesi`
- `style: kod formatı düzenlemesi`
- `refactor: kod iyileştirmesi`
- `test: test ekleme/düzenleme`
- `chore: genel bakım`

### 3.2 Branch İsimlendirme

- `feature/`: Yeni özellikler için
- `fix/`: Hata düzeltmeleri için
- `docs/`: Dokümantasyon güncellemeleri için
- `refactor/`: Kod iyileştirmeleri için
- `test/`: Test eklemeleri için

## 4. Test Etme

### 4.1 Test Senaryoları

1. Temel fonksiyonlar için testler:

- Container seçimi
- Yedekleme işlemi
- Geri yükleme işlemi
- Hata durumları

2. Özel durumlar için testler:

- Büyük veritabanları
- Bağlantı kopması
- Disk dolması

### 4.2 Test Ortamı

```bash
# Test container'ı oluştur
docker run -d --name mongodb-test mongo:latest

# Test veritabanı oluştur
mongosh mongodb://localhost:27017/test

# Test verisi ekle
db.test.insertMany([...])
```

## 5. Dokümantasyon

### 5.1 Kod Dokümantasyonu

- Her fonksiyon için açıklama ekleyin
- Parametreleri ve dönüş değerlerini belirtin
- Örnekler ekleyin

Örnek:

```bash
# Fonksiyon: do_backup
# Açıklama: Veritabanı yedeği alır
# Parametreler:
#   - backup_type: Yedek türü (tam/koleksiyon)
# Dönüş: 0 başarılı, 1 hata
do_backup() {
    local backup_type="$1"
    ...
}
```

### 5.2 Kullanıcı Dokümantasyonu

- README.md güncellemeleri
- Kullanım örnekleri
- Sık sorulan sorular

## 6. Güvenlik

### 6.1 Güvenlik Kontrolleri

- Hassas bilgileri kontrol edin
- Yetkilendirmeleri doğrulayın
- Güvenlik açıklarını test edin

### 6.2 Güvenlik Raporlama

1. Güvenlik açığı bulduysanız:

- Public issue açmayın
- Özel olarak bildirin
- POC ekleyin

## 7. Performans

### 7.1 Performans İyileştirmeleri

- Kod optimizasyonu yapın
- Kaynak kullanımını ölçün
- Benchmark testleri ekleyin

### 7.2 Performans Testleri

```bash
# Performans testi örneği
time ./mongo_backup_manager.sh backup
```

## 8. Sürüm Yönetimi

### 8.1 Versiyonlama

Semantic Versioning (SemVer) kullanın:

- MAJOR.MINOR.PATCH
- Örnek: 1.0.0, 1.1.0, 1.1.1

### 8.2 Release Süreci

1. Version bump
2. Changelog güncelleme
3. Tag oluşturma
4. Release notes

## 9. Topluluk

### 9.1 İletişim Kanalları

- GitHub Issues
- Discussions
- E-posta

### 9.2 Davranış Kuralları

1. Saygılı olun
2. Yapıcı geri bildirim verin
3. Topluluk kurallarına uyun

## 10. Lisans

Bu proje MIT lisansı altında dağıtılmaktadır. Katkıda bulunarak:

1. Kodunuzun MIT lisansı altında dağıtılmasını kabul edersiniz
2. Katkınızın size ait olduğunu beyan edersiniz
3. Üçüncü parti lisansları bildirmeyi kabul edersiniz
