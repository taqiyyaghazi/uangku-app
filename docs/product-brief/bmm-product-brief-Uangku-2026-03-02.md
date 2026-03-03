# Product Brief: Uangku (Personal Finance Command Center)

**Status:** Finalized | **Date:** 2026-03-02
**Author:** John (Product Manager)

---

## 1. Executive Summary

**Uangku** adalah aplikasi manajemen keuangan pribadi *offline-first* yang dirancang khusus untuk penggunaan individu. Aplikasi ini menggabungkan kecepatan pencatatan transaksi dengan logika *budgeting* yang disiplin dan pemantauan portfolio investasi yang komprehensif.

## 2. Problem Statement

* **Financial Fragmentation:** Aset tersebar di berbagai dompet, bank, dan portfolio investasi, membuat sulit untuk melihat total kekayaan (*Net Worth*).
* **Budgeting Indiscipline:** Sulit untuk tetap patuh pada budget bulanan karena tidak adanya umpan balik langsung (harian) yang menyesuaikan dengan perilaku belanja.
* **Friction:** Pencatatan keuangan seringkali terasa lambat dan merepotkan, terutama saat sedang *offline*.

## 3. Goals & Solution Vision

* **The Single Source of Truth:** Menjadi pusat data untuk seluruh wallet dan investasi.
* **The "Daily Breath" Concept:** Mengubah budget bulanan menjadi jatah harian yang dinamis. Jika hari ini boros, sistem secara otomatis "menyesuaikan" jatah hari esok agar rencana bulanan tetap aman.
* **Frictionless Entry:** Antarmuka yang mengutamakan kecepatan (target <3 detik per transaksi).

## 4. Key Features (MVP Scope)

1. **Multi-Wallet System:** Manajemen akun (Cash, Bank, Investasi) dengan saldo terpisah namun total terakumulasi.
2. **Dynamic Daily Budgeting:** Logika otomatis yang menghitung ulang sisa budget harian setiap kali transaksi dicatat.
3. **Portfolio Tracker:** Visualisasi pertumbuhan aset jangka panjang melalui grafik tren bulanan.
4. **Offline-First Utility:** Kecepatan maksimal tanpa ketergantungan pada koneksi internet.

## 5. Success Metrics (For Personal Use)

* **Visibility:** User mengetahui total asetnya secara akurat dalam satu kali buka aplikasi.
* **Discipline:** User tetap berada dalam koridor budget bulanan di akhir bulan berkat penyesuaian harian.
* **Habit Formation:** Kecepatan aplikasi membuat user tidak pernah melewatkan pencatatan transaksi harian.

## 6. Constraints & Strategy

* **Platform:** Mobile (Flutter).
* **Privacy:** Data 100% tersimpan secara lokal (Privasi Total).
* **Vibe:** "Ocean Flow" - Tenang, profesional, namun tetap ramah dan suportif (Gentle Adjustment).
