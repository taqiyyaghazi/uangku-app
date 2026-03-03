# Story 4.6: Custom Category Management

**Status:** Ready for Implementation
**Epic:** 4 - Post-Launch Refinements
**Story Point:** 3 (Complex Logic)

---

## User Story

**As a** user,
**I want** to create and manage my own transaction categories,
**so that** I can track my spending patterns more accurately according to my lifestyle.

---

## Acceptance Criteria

**AC #1: Category Database Table**

* **Given** database Drift,
* **When** sistem dimuat,
* **Then** harus ada tabel `Categories` yang menyimpan `name`, `icon_code` (Emoji atau ID Icon), dan `type` (Expense/Income).

**AC #2: Dynamic Category Selector**

* **Given** layar Quick Entry (Story 2.1),
* **When** user memilih kategori,
* **Then** daftar yang muncul harus diambil dari tabel `Categories` (bukan daftar statis lagi).

**AC #3: Create/Edit Category UI**

* **Given** menu Settings atau layar khusus Category,
* **When** user menekan tombol "+",
* **Then** tampilkan form untuk menginput Nama Kategori dan memilih Emoji sebagai icon-nya.

**AC #4: Category Deletion Logic**

* **Given** user ingin menghapus kategori,
* **When** kategori tersebut masih memiliki transaksi terkait,
* **Then** cegah penghapusan atau minta user memindahkan transaksi tersebut ke kategori "Other" agar data tidak hilang.

---

## Implementation Details

### Tasks / Subtasks

* [ ] **Database Migration:**
* Buat tabel `Categories`.
* Tambahkan kolom `category_id` di tabel `Transactions` (menggantikan kolom string `category` yang lama).


* [ ] **Data Seeding:**
* Buat fungsi `seedDefaultCategories()` yang dijalankan saat database pertama kali dibuat.


* [ ] **UI Component:**
* `CategoryListScreen`: Daftar kategori dengan opsi Edit/Delete.
* `AddCategoryModal`: Input teks untuk nama dan Emoji picker sederhana.


* [ ] **Logic Integration:**
* Update `QuickEntrySheet` agar menggunakan `categoryProvider` untuk menampilkan daftar pilihan.



### Technical Summary

Transisi dari *Hardcoded* ke *Dynamic Categories* membutuhkan perhatian pada **Foreign Key**. Setiap kali Anda menambah transaksi, kita sekarang menyimpan `category_id`. Ini memastikan jika Anda mengubah nama kategori "Makan" menjadi "Kuliner", semua transaksi lama Anda otomatis ikut terupdate namanya.

---

## Context References

**UX-Spec Update:**

* **Icons:** Gunakan Emoji sebagai icon kategori karena sangat ringan, tidak butuh aset gambar, dan sangat ekspresif bagi user.
* **Theme:** Tetap gunakan palet **Ocean Flow**.
