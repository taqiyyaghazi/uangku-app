# 🚀 Dokumentasi Setup CI/CD: Uangku App

**Target:** GitHub Actions ➡️ Firebase App Distribution
**Versi:** 1.0 (Maret 2026)

---

## 1. Persiapan Kredensial (Kunci Rahasia)

Sistem otomatisasi membutuhkan akses khusus ke layanan Google dan tanda tangan digital Anda.

### A. Firebase Service Account (Akses Robot)

1. Buka [Google Cloud Console](https://console.cloud.google.com/).
2. Pilih Proyek Firebase **Uangku**.
3. Buka menu **IAM & Admin > Service Accounts**.
4. Klik **Create Service Account**, beri nama `github-actions-distributor`.
5. Beri Role: **Firebase App Distribution Admin**.
6. Masuk ke tab **Keys > Add Key > Create New Key (JSON)**.
7. Simpan file ini (Isinya akan digunakan sebagai `GCP_SA_KEY`).

### B. App Signing (Tanda Tangan Digital)

1. Siapkan file `upload-keystore.jks` Anda.
2. Ubah file tersebut menjadi teks Base64 agar bisa disimpan di GitHub:
* **Windows:** `[Convert]::ToBase64String([IO.File]::ReadAllBytes("upload-keystore.jks")) | clip`
* **macOS/Linux:** `base64 -i upload-keystore.jks | pbcopy`



---

## 2. Konfigurasi GitHub Secrets

Masukkan variabel berikut ke dalam **GitHub Repository > Settings > Secrets and variables > Actions**:

| Nama Secret | Deskripsi | Sumber |
| --- | --- | --- |
| `APP_ID` | ID Unik Aplikasi Android | Firebase Project Settings |
| `FIREBASE_SERVICE_CREDENTIALS` | Isi lengkap file JSON dari Langkah 1.A | Google Cloud Key |
| `KEYSTORE_BASE64` | Teks Base64 dari Langkah 1.B | Hasil Konversi Base64 |
| `KEYSTORE_PASSWORD` | Password untuk file .jks | Password yang Anda buat |
| `KEY_ALIAS` | Nama alias kunci | Biasanya `upload` |
| `KEY_PASSWORD` | Password untuk alias kunci | Biasanya sama dengan pass keystore |

---

## 3. Konfigurasi File Proyek

Pastikan file berikut sudah ada di dalam repository Git Anda:

1. `android/app/google-services.json` (Commit secara normal).
2. `android/app/build.gradle` (Sudah dikonfigurasi menggunakan `key.properties`).

---

## 4. File Workflow GitHub Actions

Buat file di `.github/workflows/release_to_firebase.yml`:

```yaml
name: Deploy Signed APK to Firebase

on:
  push:
    branches:
      - main  # Trigger otomatis saat push ke branch main

jobs:
  build_and_deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v3

      - name: Setup Java (v17)
        uses: actions/setup-java@v3
        with:
          distribution: 'zulu'
          java-version: '17'

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'

      # Langkah 1: Decode Keystore dari Base64 ke file fisik
      - name: Decode Keystore
        run: |
          echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 --decode > android/app/upload-keystore.jks

      # Langkah 2: Buat file key.properties secara dinamis
      - name: Create key.properties
        run: |
          echo "storePassword=${{ secrets.KEYSTORE_PASSWORD }}" > android/key.properties
          echo "keyPassword=${{ secrets.KEY_PASSWORD }}" >> android/key.properties
          echo "keyAlias=${{ secrets.KEY_ALIAS }}" >> android/key.properties
          echo "storeFile=upload-keystore.jks" >> android/key.properties

      - name: Install Dependencies
        run: flutter pub get

      # Langkah 3: Build APK Release (Signed & Obfuscated)
      - name: Build Signed APK
        run: flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols

      # Langkah 4: Kirim ke Firebase App Distribution
      - name: Upload to Firebase
        uses: w9jds/firebase-action@master
        with:
          args: appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk --app ${{ secrets.APP_ID }} --groups "testers"
        env:
          GCP_SA_KEY: ${{ secrets.FIREBASE_SERVICE_CREDENTIALS }}

```

---

## 5. Workflow Penggunaan (Best Practice)

1. **Koding:** Selesaikan fitur atau fix di branch develop/feature.
2. **Update Versi:** Naikkan versi di `pubspec.yaml` (misal: `1.0.1+2`).
3. **Push to Main:** Lakukan merge atau push langsung ke `main`.
4. **Monitor:** Pantau tab **Actions** di GitHub. Jika ikon hijau ✅ muncul, cek email Anda!
