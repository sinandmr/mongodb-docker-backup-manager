# MongoDB Docker Yedekleme Yöneticisi Kullanım Senaryoları

## 1. Temel Kullanım Senaryoları

### 1.1 İlk Kez Kullanım

```bash
# Scripti çalıştır
./mongo_backup_manager.sh

# Dil seçimi yap (1: Türkçe, 2: English)
# Container seç
# Veritabanı seç
```

### 1.2 Tam Yedek Alma

```bash
1) Yedek Al seçeneğini seç
1) Tam Yedek seçeneğini seç
# Yedek açıklaması gir
```

### 1.3 Koleksiyon Bazlı Yedek Alma

```bash
1) Yedek Al seçeneğini seç
2) Koleksiyon Bazlı Yedek seçeneğini seç
# Koleksiyonları seç
# Yedek açıklaması gir
```

### 1.4 Yedek Geri Yükleme

```bash
2) Yedek Geri Yükle seçeneğini seç
# Yedeği seç
1) Üzerine Yaz veya 2) Mevcut Verileri Koru seçeneğini seç
```

## 2. İleri Seviye Kullanım Senaryoları

### 2.1 Yedekleri Karşılaştırma

```bash
10) Yedekleri Karşılaştır seçeneğini seç
# İlk yedeği seç
# İkinci yedeği seç
# Karşılaştırma sonuçlarını incele
```

### 2.2 Veritabanı İstatistiklerini İnceleme

```bash
8) Veritabanı İstatistikleri seçeneğini seç
# İstatistikleri incele
```

### 2.3 Yedek İçeriğini İnceleme

```bash
9) Yedek İçeriği seçeneğini seç
# İncelemek istediğin yedeği seç
```

## 3. Yönetim Senaryoları

### 3.1 Eski Yedekleri Temizleme

```bash
4) Yedek Sil seçeneğini seç
# Silinecek yedeği seç
# Silme işlemini onayla
```

### 3.2 Container Değiştirme

```bash
5) Container Değiştir seçeneğini seç
# Yeni container seç
```

### 3.3 Veritabanı Değiştirme

```bash
6) Veritabanı Değiştir seçeneğini seç
# Yeni veritabanı seç
```

## 4. İzleme ve Raporlama Senaryoları

### 4.1 Yedekleme Geçmişini İnceleme

```bash
7) Son İşlemler seçeneğini seç
# Geçmiş işlemleri incele
```

### 4.2 Yedek Boyutlarını İnceleme

```bash
3) Yedekleri Listele seçeneğini seç
# Yedek boyutlarını ve tarihlerini incele
```

## 5. Güvenlik Senaryoları

### 5.1 Kimlik Doğrulama Gerektiren Veritabanına Bağlanma

```bash
# Container seçiminden sonra
MongoDB kullanıcı adı: [kullanıcı adı gir]
MongoDB şifresi: [şifre gir]
Kimlik doğrulama veritabanı: [auth db adı gir]
```

### 5.2 SSL/TLS Bağlantısı Kullanma

```bash
# Container'ın SSL/TLS sertifikalarının doğru yapılandırıldığından emin ol
# Normal bağlantı adımlarını takip et
```

## 6. Hata Durumu Senaryoları

### 6.1 Bağlantı Hatası Durumu

```bash
# Hata mesajını kontrol et
# Container'ın çalışır durumda olduğunu doğrula
# Kimlik bilgilerini kontrol et
# Yeniden dene
```

### 6.2 Disk Alanı Yetersizliği Durumu

```bash
# Yedek dizininde yer açın
# Eski yedekleri temizleyin
# Yedekleme işlemini tekrar deneyin
```

## 7. Performans İyileştirme Senaryoları

### 7.1 Büyük Veritabanları için Yedekleme

```bash
# Yedekleme öncesi disk alanını kontrol et
# Koleksiyon bazlı yedekleme kullan
# Yedekleme işlemini sakin saatlerde planla
```

### 7.2 Yedekleri Optimize Etme

```bash
# Düzenli olarak eski yedekleri temizle
# Gereksiz koleksiyonları yedekleme dışında tut
# Yedekleri sıkıştırılmış formatta sakla
```
