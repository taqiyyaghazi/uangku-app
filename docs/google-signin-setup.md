# 🔐 Panduan Setup Google Sign-In (Multi-Flavor)

Panduan ini menjelaskan langkah-langkah untuk mengaktifkan Google Sign-In pada aplikasi Uangku, terutama untuk mengatasi error `clientConfigurationError` atau `serverClientId must be provided on Android`.

## 1. Dapatkan SHA-1 Fingerprint (Wajib)

Google Sign-In memerlukan SHA-1 fingerprint dari mesin pengembangan Anda untuk memverifikasi aplikasi.

### SHA-1 Debug (Untuk Development)

Jalankan perintah ini di terminal (Gunakan JBR dari Android Studio jika `keytool` bawaan tidak ditemukan):

```bash
"/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/keytool" -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

> [!NOTE]
> Jika Anda menggunakan Windows, file `.keystore` biasanya ada di `C:\Users\Username\.android\debug.keystore`.

### SHA-1 Release (Untuk Produksi)

Jika Anda sudah mengikuti **Panduan Penandatanganan Aplikasi** di `technical-guide.md`, jalankan:

```bash
"/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/keytool" -list -v -keystore ~/upload-keystore.jks -alias upload
```

> [!TIP]
> Di macOS, Flutter biasanya menggunakan Java yang dibundel dengan Android Studio. Jika Anda mendapatkan error "Unable to locate a Java Runtime", gunakan path lengkap di atas.

Cari baris yang bertuliskan `SHA1: XX:XX:XX...` dan copy kodenya.

---

## 2. Registrasi di Firebase Console

Anda harus melakukan ini **dua kali** (satu untuk project **Dev**, satu untuk project **Prod**).

1. Buka [Firebase Console](https://console.firebase.google.com/).
2. Masuk ke **Project Settings** > Tab **General**.
3. Di bagian **Android Apps**, pilih app ID yang sesuai:
   - Dev: `com.taqiyyaghazi.uangku.dev`
   - Prod: `com.taqiyyaghazi.uangku`
4. Klik **Add fingerprint**, tempel kode SHA-1 tadi, lalu **Save**.
5. **Penting:** Ulangi langkah di atas jika Anda memiliki SHA-1 yang berbeda (misal dari laptop lain atau CI/CD).

---

## 3. Aktifkan Google Sign-In Provider

1. Di menu samping Firebase, pilih **Authentication** > Tab **Sign-in method**.
2. Klik **Add new provider** > pilih **Google**.
3. Klik switch **Enable**.
4. Pilih **Project support email**.
5. Di bagian paling bawah (Web SDK configuration), copy **Web client ID**. Anda akan membutuhkannya untuk kode Flutter.
6. Klik **Save**.

---

## 4. Update Project Flutter

### A. Download Ulang `google-services.json`

Setelah menambahkan fingerprint, download ulang file `google-services.json` dari Firebase Console dan ganti file yang lama di:

- `android/app/src/dev/google-services.json`
- `android/app/src/prod/google-services.json`

Pastikan file baru sekarang memiliki isi di bagian `"oauth_client": [...]`.

### B. Konfigurasi `AppConfig`

Buka `lib/core/config/app_config.dart` dan tempel **Web Client ID** yang Anda copy tadi ke bagian `serverClientId`.

```dart
static String? get serverClientId => isDev
    ? 'PASTE_WEB_CLIENT_ID_DEV_DI_SINI'
    : 'PASTE_WEB_CLIENT_ID_PROD_DI_SINI';
```

### C. Inisialisasi GoogleSignIn

Pastikan di `auth_provider.dart`, `GoogleSignIn` diinisialisasi dengan `serverClientId` tersebut (jika versi plugin mendukungnya).

---

## 5. Troubleshooting (Masalah Umum)

| Error Code                 | Arti & Solusi                                                                                                                                                                                            |
| -------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `clientConfigurationError` | **Penyebab:** `serverClientId` belum diset di kode Flutter atau `google-services.json` masih versi lama (kosong bagian OAuth). **Solusi:** Ikuti langkah 4B.                                             |
| `Status: 10`               | **Penyebab:** SHA-1 Mismatch. Sidik jari digital di Firebase tidak cocok dengan yang ada di laptop Anda. **Solusi:** Jalankan lagi perintah `keytool` dan pastikan kodenya sama dengan yang di Firebase. |
| `Status: 12500`            | **Penyebab:** Masalah pada layanan Google Play atau konfigurasi OAuth. **Solusi:** Pastikan email support sudah diset di Google Sign-In provider di Firebase.                                            |
