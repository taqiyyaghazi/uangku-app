# Story 4.1: Budget Configuration & Storage

**Status:** Ready for Implementation
**Epic:** 4 - Post-Launch Refinements
**Story Point:** 2 (Estimated 2-3 hours)

---

## User Story

**As a** user,
**I want** to be able to set and update my total monthly budget,
**so that** the "Daily Breath" engine has a baseline to calculate my daily allowance.

---

## Acceptance Criteria

**AC #1: Budget Input UI**

* **Given** Dashboard utama,
* **When** user menekan area "Daily Breath" atau tombol "Set Budget",
* **Then** tampilkan modal/bottom sheet yang memungkinkan user menginput angka budget bulanan.

**AC #2: Persistent Storage**

* **Given** user memasukkan angka budget (misal: Rp 5.000.000),
* **When** tombol "Save" ditekan,
* **Then** angka tersebut harus tersimpan secara permanen di database (Tabel `Settings`) atau menggunakan `shared_preferences`.

**AC #3: Immediate Recalculation**

* **Given** budget baru telah disimpan,
* **When** modal ditutup,
* **Then** widget "Daily Breath" harus langsung melakukan *re-render* dan menunjukkan jatah harian yang baru secara akurat.

**AC #4: Validation**

* **Given** input budget,
* **When** user memasukkan angka 0 atau negatif,
* **Then** tampilkan pesan error dan cegah proses penyimpanan.

---

## Implementation Details

### Tasks / Subtasks

* [ ] **Database Update:**
* Tambahkan tabel `AppSettings` di Drift: `id (int), key (string), value (double)`.
* Masukkan entry `monthly_budget`.


* [ ] **State Management (Riverpod):**
* Buat `monthlyBudgetProvider` (StateNotifierProvider) untuk mengelola state budget secara global.


* [ ] **UI Component:**
* Buat `BudgetSettingModal` dengan `TextField(keyboardType: TextInputType.number)`.
* Tambahkan tombol "Set Budget" di Dashboard (Gunakan icon ⚙️ atau ✏️ di pojok widget Daily Breath).


* [ ] **Logic Integration:**
* Update `BudgetService` agar mengambil nilai `monthly_budget` dari database, bukan lagi angka *hardcoded*.



### Technical Summary

Masalah sebelumnya adalah kita memiliki "mesin" hitung tapi tidak memiliki "tangki bensin" (angka budget). Dengan menyimpan angka ini di tabel `AppSettings`, kita memastikan bahwa setiap kali aplikasi dibuka, kalkulasi `Daily Breath` selalu merujuk pada angka yang Anda tentukan sendiri.

---

## Context References

**Tech-Spec Update:**

* Tambahkan `AppSettings` ke `local_db.dart`.

**UX-Spec Update:**

* Gunakan warna **Teal** untuk tombol simpan dan pastikan input menggunakan format mata uang agar mudah dibaca.
