# 🌊 Uangku (Financial Daily Breath)

**Uangku** adalah aplikasi manajemen keuangan pribadi yang cerdas dan minimalis. Berbeda dengan aplikasi pencatat keuangan biasa, Uangku menggunakan mesin **"Daily Breath"** untuk menghitung jatah harian Anda secara dinamis berdasarkan sisa budget dan sisa hari dalam sebulan.

---

## ✨ Fitur Utama

- **🌬️ Mesin "Daily Breath":** Kalkulasi otomatis jatah harian (`Sisa Budget / Sisa Hari`). Jika Anda boros hari ini, jatah esok hari akan menyesuaikan secara lembut tanpa merusak rencana bulanan Anda.
- **👛 Multi-Wallet Core:** Kelola berbagai dompet (Cash, Bank, E-Wallet, atau Investasi) dalam satu tampilan grid yang elegan.
- **⚡ Quick-Entry System:** Catat transaksi dalam hitungan detik dengan numpad yang responsif dan fokus otomatis.
- **🔄 Internal Transfer:** Pindahkan dana antar dompet tanpa memengaruhi budget pengeluaran Anda (logic double-entry).
- **📈 Portfolio Tracking:** Pantau pertumbuhan aset dan alokasi dana melalui grafik interaktif.
- **📁 Arsip Transaksi:** Riwayat lengkap dengan filter tanggal dan kategori yang dapat dikustomisasi.

---

## 🛠️ Tech Stack

- **Framework:** [Flutter](https://flutter.dev/)
- **State Management:** [Riverpod](https://riverpod.dev/) (Reactive & Testable)
- **Database:** [Drift](https://drift.simonbinder.eu/) (SQLite with Type-Safe persistence)
- **Analytics:** [fl_chart](https://pub.dev/packages/fl_chart)
- **Architecture:** Feature-based vertical slices (Clean Architecture principles)

---

## 🚀 Memulai (Getting Started)

### Prasyarat

- Flutter SDK (v3.41.2+)
- Dart (v3.11.0+)

### Instalasi

1. Clone repository ini.
2. Jalankan perintah untuk mengambil dependensi:
   ```bash
   flutter pub get
   ```
3. Jalankan `build_runner` untuk menghasilkan file database (Drift):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
4. Jalankan aplikasi:
   ```bash
   flutter run
   ```

---

## 📂 Dokumentasi Proyek

Informasi lebih detail mengenai desain dan perkembangan proyek dapat ditemukan di folder `docs/`:

- [Epic Breakdown](docs/epics.md) - Rencana pengembangan fase demi fase.
- [Technical Guide](docs/technical-guide.md) - Panduan build, signing, dan optimasi.
- [Implementation Progress](docs/implementation-progress.md) - Status fitur saat ini.
- [Product Brief](docs/product-brief/branding-philosophy-and-market-fit.md) - Visi dan filosofi brand.

---

## 🎨 Branding & Design

Uangku mengusung tema **"Ocean Flow"** dengan palet warna Teal dan desain yang mengutamakan ketenangan mata (Eye-comfort). Antarmuka dibuat sebersih mungkin agar pengguna tidak merasa tertekan saat melihat angka keuangan mereka.

---

## 👥 Kontribusi

Proyek ini dibangun sebagai alat bantu manajemen keuangan yang mengutamakan kemudahan penggunaan dan ketahanan data offline. Jika Anda menemukan bug atau memiliki saran fitur, silakan buka _issue_ atau kirimkan _pull request_.

**Happy Budgeting!** 🌊📉🚀
