# 🌊 Uangku (Financial Daily Breath)

**Uangku** adalah aplikasi manajemen keuangan pribadi yang cerdas dan minimalis. Berbeda dengan aplikasi pencatat keuangan biasa, Uangku menggunakan mesin **"Daily Breath"** untuk menghitung jatah harian Anda secara dinamis berdasarkan sisa budget dan sisa hari dalam sebulan.

**Status:** ✅ **Feature Complete** (35/35 User Stories)

---

## ✨ Fitur Utama

- **🌬️ Mesin "Daily Breath":** Kalkulasi otomatis jatah harian (`Sisa Budget / Sisa Hari`). Jika Anda boros hari ini, jatah esok hari akan menyesuaikan secara lembut tanpa merusak rencana bulanan Anda.
- **☁️ Cloud Sync & Recovery:** Sinkronisasi otomatis ke cloud (Firebase). Data Anda aman dan dapat dipulihkan secara instan saat berganti perangkat.
- **🔐 Privacy First:** **Global Privacy Mode** memungkinkan Anda menyembunyikan saldo seluruh dompet dengan satu ketukan untuk keamanan di ruang publik.
- **👛 Smart Wallet Carousel:** Tampilan dashboard yang dioptimalkan dengan carousel dompet (maks. 5 item teratas) untuk navigasi yang lebih bersih dan cepat.
- **⚡ Quick-Entry System:** Catat transaksi dalam hitungan detik dengan numpad yang responsif.
- **📊 Advanced Insights:** Analisis pengeluaran melalui diagram pie kategori, tren harian, dan perbandingan performa antar bulan.
- **🔄 Internal Transfer:** Pindahkan dana antar dompet tanpa memengaruhi budget pengeluaran Anda.
- **📈 Portfolio Tracking:** Pantau pertumbuhan aset dan alokasi dana melalui grafik interaktif.
- **📁 Riwayat & Deep Filter:** Telusuri transaksi dengan filter wallet, tanggal, kategori, dan tipe transaksi yang fleksibel.
- **🛡️ Robust Monitoring:** Terintegrasi dengan Firebase Crashlytics dan Analytics untuk menjamin stabilitas aplikasi.

---

## 🛠️ Tech Stack

- **Framework:** [Flutter](https://flutter.dev/)
- **Backend/Cloud:** [Firebase](https://firebase.google.com/) (Firestore, Auth, Crashlytics)
- **State Management:** [Riverpod](https://riverpod.dev/)
- **Database (Offline-First):** [Drift](https://drift.simonbinder.eu/) (SQLite)
- **Charts:** [fl_chart](https://pub.dev/packages/fl_chart)
- **Architecture:** Feature-based vertical slices

---

## 🚀 Memulai (Getting Started)

### Prasyarat

- Flutter SDK (v3.x+) + FVM (direkomendasikan)
- Proyek Firebase (Konfigurasi `google-services.json` di `android/app/src/[flavor]/`)

### Instalasi & Menjalankan

1. Clone repository ini.
2. Jalankan perintah untuk mengambil dependensi:
   ```bash
   fvm flutter pub get
   ```
3. Jalankan `build_runner` untuk menghasilkan file database (Drift):
   ```bash
   fvm dart run build_runner build --delete-conflicting-outputs
   ```
4. Jalankan aplikasi menggunakan **Flavors**:

   **Mode Development (Testing):**

   ```bash
   fvm flutter run --flavor dev -t lib/main_dev.dart
   ```

   **Mode Production (Asli):**

   ```bash
   fvm flutter run --flavor prod -t lib/main_prod.dart
   ```

---

## 📂 Dokumentasi Proyek

Informasi lebih detail mengenai desain dan perkembangan proyek dapat ditemukan di folder `docs/`:

- [Epic Breakdown](docs/epics.md) - Rencana pengembangan fase demi fase.
- [Technical Guide](docs/technical-guide.md) - Panduan rilis, flavors, dan optimasi.
- [Implementation Progress](docs/implementation-progress.md) - Status fitur saat ini (Story Breakdown).
- [CI/CD Setup Guide](docs/ci-cd-setup-guide.md) - Panduan otomatisasi deployment ke Firebase.
- [Tech Spec](docs/tech-spec.md) - Spesifikasi teknis dan struktur folder.

---

## 🎨 Branding & Design

Uangku mengusung tema **"Ocean Flow"** dengan palet warna Teal dan desain yang mengutamakan ketenangan mata. Antarmuka dibuat sebersih mungkin agar pengguna tidak merasa tertekan saat melihat angka keuangan mereka. Pada versi **Dev**, akan muncul banner merah di pojok layar sebagai penanda lingkungan testing.

---

## 👥 Kontribusi

Proyek ini dibangun sebagai alat bantu manajemen keuangan yang mengutamakan kemudahan penggunaan dan ketahanan data. Jika Anda menemukan bug atau memiliki saran fitur, silakan buka _issue_ atau kirimkan _pull request_.

**Happy Budgeting!** 🌊📉🚀
