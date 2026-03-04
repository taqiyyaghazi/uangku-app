## 🛠️ Panduan Teknis

### 1. Mengubah Icon Aplikasi (Cara Tercepat)

Gunakan package `flutter_launcher_icons`. Ini jauh lebih mudah daripada mengganti file manual di folder Android dan iOS satu-satu.

- Tambahkan di `pubspec.yaml`.
- Siapkan gambar `assets/icon/logo.png` (minimal 1024x1024 px).
- Jalankan command: `flutter pub run flutter_launcher_icons:main`.

### 2. Mengubah Nama Aplikasi & Package ID

Cara paling aman adalah menggunakan package `rename`.

- Jalankan: `flutter pub global run rename --bundleId com.namaanda.uangku`.
- Jalankan: `flutter pub global run rename --appname "Uangku"`.

### 3. Cara Update Versi (Teknis)

Buka file `pubspec.yaml`, cari baris:
`version: 1.0.0+1`

- **1.0.0** adalah **Version Name** (yang dilihat user: v1.1, v1.2, dst).
- **1** adalah **Version Code** (Angka bulat yang harus SELALU naik setiap kali Anda update ke Play Store/App Store).
- _Update Fitur Kecil:_ `1.0.1+2`
- _Update Fitur Besar:_ `1.1.0+3`

---

## ⚠️ Peringatan Penting tentang Database (Drift)

Karena Anda sudah punya data di HP, setiap kali Anda mengubah **Struktur Tabel** (seperti nambah kolom `notes` atau tabel `Categories` kemarin), Anda **WAJIB**:

1. Menaikkan `schemaVersion` di file `local_db.dart`.
2. Menulis logika migrasi agar data lama tidak terhapus saat aplikasi di-update.

---

## 🚀 Panduan Build & Release

### 1. Persiapan Akhir (Pre-Flight Check)

Sebelum memencet tombol "Build", pastikan dua hal ini:

- **Bersihkan Project:** Jalankan `flutter clean` di terminal untuk menghapus cache lama.
- **Update Versi:** Pastikan di `pubspec.yaml`, versinya sudah sesuai, misal `version: 1.0.0+1`.

---

### 2. Membuat File APK (Untuk Instalasi Langsung)

APK (_Android Package_) adalah file yang bisa Anda kirim lewat WhatsApp atau Telegram ke teman, dan mereka bisa langsung menginstalnya.

**Command:**

```bash
flutter build apk --split-per-abi
```

**Kenapa pakai `--split-per-abi`?**
Secara default, Flutter membuat satu APK raksasa (Fat APK). Dengan perintah ini, Flutter akan menghasilkan 3 file APK yang berbeda sesuai arsitektur prosesor HP (v7, v8, x86).

- **Hasilnya:** Ukuran file lebih kecil (biasanya berkurang 50%!).
- **Lokasi file:** `build/app/outputs/flutter-apk/app-release-arm64-v8a-release.apk` (Ini yang biasanya dipakai untuk HP Android modern).

---

### 3. Membuat App Bundle / AAB (Untuk Play Store)

Jika Anda berencana mengunggah **Uangku** ke Google Play Store, Google tidak menerima APK lagi. Anda wajib menggunakan **AAB**.

**Command:**

```bash
flutter build appbundle
```

- **Lokasi file:** `build/app/outputs/bundle/release/app-release.aab`.

---

## 🔐 Panduan Penandatanganan Aplikasi (App Signing)

Jika Anda ingin mendistribusikan aplikasi secara massal atau ke Play Store, aplikasi harus "ditandatangani" secara digital.

### Langkah 1: Membuat File Keystore

Buka terminal di root project Flutter Anda dan jalankan perintah ini (untuk macOS/Linux atau Windows PowerShell):

**Windows:**

```powershell
keytool -genkey -v -keystore c:\Users\USER_ANDA\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**macOS / Linux:**

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

> [!CAUTION]
> **PENTING:** Anda akan diminta memasukkan password. **Jangan sampai lupa!** Simpan file `.jks` ini di tempat yang sangat aman (misal: Google Drive atau Cloud Vault), jangan masukkan ke Git/GitHub.

---

### Langkah 2: Buat File `key.properties`

Buat file baru bernama `android/key.properties` (ini agar Flutter tahu di mana kunci Anda disimpan). Isi filenya seperti ini:

```properties
storePassword=PASSWORD_YANG_ANDA_BUAT
keyPassword=PASSWORD_YANG_ANDA_BUAT
keyAlias=upload
storeFile=/Users/USER_ANDA/upload-keystore.jks (atau path lengkap di Windows)
```

---

### Langkah 3: Konfigurasi `android/app/build.gradle`

Sekarang kita harus memberi tahu Gradle (sistem build Android) untuk menggunakan kunci tersebut. Cari file `android/app/build.gradle` dan sesuaikan:

**1. Di bagian paling atas (sebelum `android { ... }`):**

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

**2. Di dalam blok `android { ... }`, tambahkan `signingConfigs`:**

```gradle
android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release // <--- Pastikan ini merujuk ke signingConfigs.release
            minifyEnabled true // Opsional: Mengecilkan ukuran aplikasi
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

---

### Langkah 4: Build Ulang (The Official Release)

Sekarang jalankan perintah build lagi. Kali ini, file yang dihasilkan sudah "ditandatangani" secara resmi.

```bash
flutter build apk --release
```

---

### ⚠️ Tips Keamanan Winston

1. **Daftar .gitignore:** Tambahkan `android/key.properties` ke file `.gitignore` Anda agar password Anda tidak tersebar di internet.
2. **Backup Keystore:** Sekali lagi, jika file `.jks` hilang, Anda tamat. Simpan cadangannya!
3. **Internal Sharing:** APK yang sudah di-_sign_ ini sekarang bisa diinstal di HP mana pun, dan jika nanti Anda buat versi `1.0.1+2`, HP tersebut akan mengenalinya sebagai update resmi (data tidak hilang).

---

## 📉 Panduan Optimasi Ukuran Aplikasi

Menjaga aplikasi tetap ringan adalah kunci agar user tidak malas mengunduhnya. Berikut adalah teknik penciutan ukuran aplikasi:

### 1. Obfuscation: Melindungi & Mengecilkan

_Obfuscation_ adalah proses mengacak nama variabel dan fungsi dalam kode Anda (misal: `calculateDailyBreath()` menjadi `a()`). Ini memiliki dua manfaat:

1. **Keamanan:** Kode Anda jadi sangat sulit dibaca jika seseorang mencoba melakukan _reverse-engineering_.
2. **Ukuran:** Nama fungsi yang panjang diganti dengan satu atau dua karakter, yang secara kumulatif mengurangi ukuran file biner.

**Command untuk Build dengan Obfuscation:**

```bash
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

- `--obfuscate`: Mengaktifkan pengacakan kode.
- `--split-debug-info`: Memisahkan simbol debug ke file eksternal agar tidak membebani APK, tapi Anda tetap bisa menelusuri _crash_ jika terjadi di HP user.

---

### 2. Tree Shaking: Membuang yang Tidak Perlu

Flutter secara otomatis melakukan _tree shaking_, yaitu menghapus kode atau icon yang tidak pernah dipanggil. Namun, kita bisa membantu proses ini:

- **Hapus Assets Tak Terpakai:** Cek folder `assets/`. Jika ada gambar atau font yang Anda masukkan saat eksperimen tapi tidak dipakai di UI, segera hapus dari `pubspec.yaml`.
- **Gunakan Font Spesifik:** Jangan memasukkan satu paket seluruh font Google (TTF) jika hanya butuh beberapa karakter.

---

### 3. Memanfaatkan App Bundle (AAB)

Ingat, jika Anda memberikan file ke teman, APK memang paling mudah. Tapi jika Anda sudah "Go Public", **AAB adalah kuncinya**.

Google Play Store menggunakan AAB untuk membuat APK yang dikustomisasi khusus untuk HP user tersebut.

- **Contoh:** Jika HP user hanya mendukung layar _high-density_, Google hanya akan mengirim gambar resolusi tinggi ke HP itu, dan membuang gambar resolusi rendah.
- **Hasil:** User mengunduh hingga **20-30% lebih sedikit** data dibandingkan mengunduh APK biasa.

---

### 4. Analisis Ukuran (App Size Analyzer)

Ingin tahu file apa yang paling banyak memakan tempat? Flutter punya alat detektif untuk ini!

**Jalankan Command:**

```bash
flutter build apk --analyze-size
```

After selesai, Flutter akan menghasilkan file JSON dan memberikan link atau ringkasan di terminal tentang bagian mana yang paling berat (biasanya _Dart Code_, _Assets_, atau _Native Code_).

---

### 📉 Estimasi Perubahan Ukuran

| Teknik               | Ukuran Awal (Fat APK) | Hasil Akhir                   |
| -------------------- | --------------------- | ----------------------------- |
| Standar Build        | ~50 MB                | -                             |
| `--split-per-abi`    | ~50 MB                | ~15-20 MB per file            |
| `+ Obfuscation`      | ~18 MB                | ~16-17 MB                     |
| `+ AAB (Play Store)` | ~16 MB                | **~10-12 MB** (Download size) |
