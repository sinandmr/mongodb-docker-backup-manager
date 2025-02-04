# MongoDB Docker Yedekleme Yöneticisi API Dokümantasyonu

## Fonksiyonlar ve Kullanımları

### 1. Container Yönetimi

#### `select_container()`

- **Açıklama**: Docker container'larını listeler ve seçim yapmanızı sağlar
- **Dönüş Değeri**: Seçilen container ID ve adı
- **Örnek Kullanım**:

```bash
select_container
```

### 2. Yedekleme İşlemleri

#### `do_backup()`

- **Açıklama**: Seçili veritabanının yedeğini alır
- **Parametreler**:
  - `backup_type`: Yedek türü (tam/koleksiyon bazlı)
- **Örnek Kullanım**:

```bash
do_backup "full"
```

### 3. Geri Yükleme İşlemleri

#### `do_restore()`

- **Açıklama**: Seçili yedeği geri yükler
- **Parametreler**:
  - `restore_type`: Geri yükleme türü (tam/koleksiyon bazlı)
- **Örnek Kullanım**:

```bash
do_restore "full"
```

### 4. Veritabanı İşlemleri

#### `select_database()`

- **Açıklama**: Veritabanı seçimi yapar
- **Dönüş Değeri**: Seçilen veritabanı adı
- **Örnek Kullanım**:

```bash
select_database
```

### 5. Koleksiyon İşlemleri

#### `select_collections()`

- **Açıklama**: Koleksiyon seçimi yapar
- **Dönüş Değeri**: Seçilen koleksiyonların listesi
- **Örnek Kullanım**:

```bash
select_collections
```

### 6. Yedek Yönetimi

#### `list_backups()`

- **Açıklama**: Mevcut yedekleri listeler
- **Örnek Kullanım**:

```bash
list_backups
```

#### `delete_backup()`

- **Açıklama**: Seçili yedeği siler
- **Örnek Kullanım**:

```bash
delete_backup
```

### 7. İstatistik ve Analiz

#### `show_db_stats()`

- **Açıklama**: Veritabanı istatistiklerini gösterir
- **Örnek Kullanım**:

```bash
show_db_stats
```

#### `show_backup_content()`

- **Açıklama**: Yedek içeriğini detaylı gösterir
- **Örnek Kullanım**:

```bash
show_backup_content
```

### 8. Karşılaştırma İşlemleri

#### `compare_backups()`

- **Açıklama**: İki yedeği karşılaştırır
- **Örnek Kullanım**:

```bash
compare_backups
```

## Hata Kodları ve Açıklamaları

- `ERR_NO_CONTAINERS`: Docker'da MongoDB container'ı bulunamadı
- `ERR_AUTH_FAILED`: Kimlik doğrulama başarısız
- `ERR_BACKUP_FAILED`: Yedekleme işlemi başarısız
- `ERR_RESTORE_FAILED`: Geri yükleme işlemi başarısız
- `ERR_INVALID_CHOICE`: Geçersiz seçim
- `ERR_NO_DATABASE`: Veritabanı bulunamadı
- `ERR_NO_BACKUPS`: Yedek bulunamadı

## Güvenlik Notları

1. Kimlik bilgilerini güvenli bir şekilde saklayın
2. Yedekleri şifrelenmiş bir ortamda tutun
3. Hassas verileri içeren yedekleri güvenli bir şekilde silin
4. Yetkilendirme kontrollerini düzenli olarak gözden geçirin
