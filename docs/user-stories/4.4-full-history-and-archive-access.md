# Story 4.4: Full History & Archive Access

**Status:** Ready for Implementation
**Epic:** 4 - Post-Launch Refinements
**Story Point:** 2 (Estimated 2-4 hours)

---

## User Story

**As a** user,
**I want** to access a dedicated screen for my entire transaction history,
**so that** I can review, edit, or delete transactions that are older than the "Recent 10" shown on the dashboard.

---

## Acceptance Criteria

**AC #1: The "See All" Entry Point**

* **Given** section "Recent Activity" di Dashboard,
* **When** user menekan tombol teks "See All" atau icon panah di pojok kanan atas,
* **Then** aplikasi harus menavigasi user ke layar **All Transactions**.

**AC #2: Infinite / Full List View**

* **Given** layar All Transactions,
* **When** dimuat,
* **Then** tampilkan seluruh transaksi dalam database tanpa batasan jumlah, diurutkan dari yang paling baru (**Newest First**).

**AC #3: Date Grouping (Sticky Headers)**

* **Given** daftar transaksi yang panjang,
* **When** user melakukan scroll,
* **Then** kelompokkan transaksi berdasarkan tanggal (misal: "March 2026", "February 2026") agar navigasi data lama lebih manusiawi.

**AC #4: Full Management Integration**

* **Given** sebuah transaksi lama di dalam daftar arsip,
* **When** user melakukan *tap* pada transaksi tersebut,
* **Then** jalankan fungsi **Story 4.3** (Bottom Sheet Edit/Delete) yang sama untuk memungkinkan koreksi data masa lalu.

---

## Implementation Details

### Tasks / Subtasks

* [ ] **Data Query (Drift):**
* Buat query di DAO: `watchAllTransactions()`.
* *Opsional:* Jika data sudah sangat banyak, gunakan `limit` dan `offset` (Pagination) agar scroll tetap mulus.


* [ ] **UI Component:**
* Buat `TransactionsArchiveScreen`.
* Gunakan `ListView.builder` untuk efisiensi memori.
* Tambahkan "Sticky Headers" menggunakan package `sticky_headers` atau kustom `SliverPersistentHeader` agar bulan/tahun tetap terlihat saat scroll.


* [ ] **Navigation:**
* Tambahkan rute baru di `GoRouter` atau `Navigator` untuk halaman history ini.


* [ ] **Empty State:**
* Jika user menghapus semua transaksi, tampilkan pesan: *"Riwayat kosong. Mulai mencatat hari ini!"*



### Technical Summary

Kita memisahkan "Recent Activity" (yang ringan dan cepat di Dashboard) dengan "Full History" (yang memuat data berat). Dengan cara ini, Dashboard tetap *snappy* (cepat), tapi Anda tidak kehilangan kemampuan untuk mengaudit data dari berbulan-bulan yang lalu.

---

## Context References

**UX-Spec Update:**

* **Layout:** Gunakan *Search Bar* sederhana di bagian atas layar History jika Anda ingin mencari transaksi berdasarkan nama (misal: "Starbucks").
* **Theme:** Tetap gunakan palet **Ocean Flow**. Gunakan warna teks yang lebih pudar untuk transaksi yang sudah sangat lama agar fokus tetap pada bulan berjalan.
