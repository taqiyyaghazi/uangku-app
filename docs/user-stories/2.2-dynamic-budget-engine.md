# Story 2.2: Dynamic Budget Engine

**Status:** Ready for Implementation
**Epic:** 2 - The "Daily Breath" Budgeting System
**Story Point:** 5 (Complex Logic)

---

## User Story

**As a** user,
**I want** my daily budget to be recalculated automatically every time I spend,
**so that** I always know exactly how much I can spend "aman" hari ini tanpa merusak rencana bulanan saya.

---

## Acceptance Criteria

**AC #1: The Daily Breath Algorithm**

* **Given** total budget bulanan dan total pengeluaran bulan ini,
* **When** sistem menghitung sisa jatah,
* **Then** rumusnya harus: `(Limit_Bulanan - Total_Spent) / Sisa_Hari_di_Bulan_Ini`.

**AC #2: Real-time "Breath" Progress Bar**

* **Given** dashboard utama,
* **When** ada transaksi baru,
* **Then** indikator visual (progress bar) harus diperbarui secara instan dengan animasi halus.

**AC #3: Amber Alert (Gentle Adjustment)**

* **Given** pengeluaran hari ini melebihi `Daily_Allowance`,
* **When** dashboard dimuat,
* **Then** warna indikator berubah dari **Teal** menjadi **Amber**, dan menampilkan pesan koreksi otomatis untuk hari esok.

**AC #4: Month-End Reset**

* **Given** pergantian bulan (tanggal 1),
* **When** aplikasi dibuka,
* **Then** sistem harus mengarsipkan data bulan lalu dan mereset perhitungan budget ke angka awal bulan baru.

---

## Implementation Details

### Tasks / Subtasks

* [ ] Create `BudgetService` (Logic Class):
* Method `calculateDailyAllowance()`: Ambil total pengeluaran bulan berjalan dari Drift DB.
* Hitung sisa hari menggunakan `DateTime` (termasuk penanganan tahun kabisat).


* [ ] Implement `DailyBreathProvider` (Riverpod):
* Gunakan `StreamProvider` yang mendengarkan setiap perubahan di tabel `Transactions`.


* [ ] UI Component: `DailyBreathWidget`:
* Gunakan `TweenAnimationBuilder` untuk animasi progress bar yang "bernapas".
* Terapkan logika warna: Teal (< 100% daily), Amber (> 100% daily).


* [ ] Logic Koreksi:
* Jika hari ini *overspend* Rp 50.000, pastikan sisa Rp 50.000 tersebut terbagi rata ke jumlah hari yang tersisa di bulan tersebut.



### Technical Summary

Ini adalah fitur *reactive*. Kita tidak ingin user melakukan *refresh* manual. Dengan Drift, kita bisa membuat `Watch` query pada total pengeluaran bulan ini. Setiap kali `Story 2.1` (Input Transaksi) dijalankan, `Story 2.2` akan otomatis menghitung ulang dan memperbarui UI.

### Project Structure Notes

* **Files to create:**
* `lib/features/dashboard/logic/budget_service.dart`
* `lib/features/dashboard/widgets/daily_breath_bar.dart`


* **Prerequisites:** **Story 1.1** (Database) and **Story 2.1** (Transaction Entry).

---

## Context References

**Tech-Spec:** [tech-spec.md](https://www.google.com/search?q=../tech-spec.md)

* Logic: `(Monthly Budget - Total Spent) / Sisa Hari`.
* Theme: Ocean Flow (Teal & Amber).

**UX-Spec:** [ux-design-specification.md](https://www.google.com/search?q=../ux-design-specification.md)

* Feeling: "Gentle Adjustment" (Non-judgmental feedback).
