# MongoDB Docker Backup Manager

🇹🇷 Docker üzerinde çalışan MongoDB veritabanları için Türkçe arayüzlü yedekleme yönetim aracı

## Özellikler

- 🔍 Otomatik MongoDB container tespiti ve seçimi
- 🔐 Kimlik doğrulamalı ve doğrulamasız MongoDB desteği
- 💾 Tek veya tüm veritabanlarını yedekleme
- 📦 Akıllı yedek depolama yönetimi
- 🔄 Kolay geri yükleme (mevcut veriyi koruma/silme seçenekli)
- 📋 Detaylı yedek geçmişi
- 🎯 Çoklu platform desteği (Linux, macOS)
- 🇹🇷 Tam Türkçe arayüz

## Gereksinimler

- Docker yüklü ve çalışır durumda olmalı
- En az bir MongoDB container'ı çalışıyor olmalı
- Bash shell ortamı
- Docker işlemleri için yeterli yetkiler

## Kurulum

1. Repo'yu klonlayın:

```bash
git clone https://github.com/kullanıcı-adı/mongodb-docker-backup-manager.git
cd mongodb-docker-backup-manager
```

2. Scripti çalıştırılabilir yapın:

```bash
chmod +x mongo_backup_manager.sh
```

## Kullanım

1. Scripti başlatın:

```bash
./mongo_backup_manager.sh
```

2. İlk çalıştırmada:

   - Yedekleme dizini seçmeniz istenecek
   - Çalışan MongoDB container'ları listelenecek
   - Container seçimi yapmanız istenecek
   - Gerekiyorsa kimlik doğrulama bilgileri istenecek

3. Ana menüden işlem seçin:
   - Yedek alma
   - Yedek geri yükleme
   - Yedekleri listeleme
   - Yedek silme
   - Container değiştirme
   - Veritabanı değiştirme

## Özellikler Detayı

### Yedekleme

- 📝 Her yedek için açıklama ekleme
- 📊 Yedek boyutu gösterimi
- 🕒 Okunabilir tarih formatı
- 📜 Son işlemler geçmişi
- ⌨️ Tab completion desteği

### Geri Yükleme

- 🔄 Mevcut veriyi koruma seçeneği
- 🗑️ Mevcut veriyi silip temiz kurulum
- 📋 Yedek listesinden kolay seçim

### Güvenlik

- 🔐 Güvenli kimlik doğrulama
- 🛡️ Yedek dizini izin kontrolleri
- ⚡ Otomatik sudo yönetimi

### Platform Desteği

- 🍎 macOS için özel dizin yapısı
- 🐧 Linux dağıtımlarına özel yapılandırma
- 📁 İşletim sistemine göre akıllı dizin seçimi

## Sık Sorulan Sorular

**S: Yedekler nereye kaydediliyor?** C: İşletim sistemine göre varsayılan dizinler:

- macOS: `~/Desktop/mongodb_backups`
- Ubuntu/Debian: `/var/backups/mongodb`
- CentOS/RHEL: `/var/opt/mongodb/backups`

**S: Kimlik doğrulama bilgilerini her seferinde girmem gerekiyor mu?** C: Hayır, script oturumu boyunca bilgiler saklanır.

**S: Yedekleri nasıl organize edebilirim?** C: Her yedeğe açıklama ekleyebilir, tarih ve boyut bilgilerini görüntüleyebilirsiniz.

## Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

## Katkıda Bulunma

1. Fork edin
2. Feature branch oluşturun (`git checkout -b feature/özellik`)
3. Değişikliklerinizi commit edin (`git commit -am 'Yeni özellik: özellik açıklaması'`)
4. Branch'inizi push edin (`git push origin feature/özellik`)
5. Pull Request oluşturun
