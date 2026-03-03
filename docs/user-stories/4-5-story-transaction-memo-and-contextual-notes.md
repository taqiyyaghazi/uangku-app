# Story 4.5: Transaction Memo & Contextual Notes

**Status:** Ready for Implementation
**Epic:** 4 - Post-Launch Refinements
**Story Point:** 2 (Estimated 2-3 hours)

---

## User Story

**As a** user,
**I want** to add a short note or memo to each transaction,
**so that** I can remember specific details about my spending and income beyond just the category and amount.

---

## Acceptance Criteria

**AC #1: Database Schema Expansion (Migration)**

* **Given** tabel `Transactions` yang sudah ada di Drift,
* **When** aplikasi diperbarui,
* **Then** kolom baru `notes` (String/Text, nullable) harus ditambahkan tanpa menghapus data transaksi yang sudah ada.

**AC #2: Memo Field in Quick Entry**

* **Given** Bottom Sheet "Quick Entry" (Story 2.1),
* **When** user menginput transaksi,
* **Then** sediakan sebuah `TextField` opsional berlabel "Add Note..." di bawah pemilihan kategori/wallet.

**AC #3: Contextual Display**

* **Given** sebuah transaksi yang memiliki catatan,
* **When** ditampilkan di Dashboard atau All Transactions,
* **Then** tampilkan cuplikan catatan tersebut (max 1 baris) dengan gaya teks yang lebih kecil dan halus (Italic/Grey) di bawah nama kategori.

**AC #4: Edit Memo Capability**

* **Given** user membuka layar Edit Transaksi (Story 4.3),
* **When** detail transaksi dimuat,
* **Then** user harus bisa mengubah atau menghapus catatan yang sudah ada dan menyimpannya kembali.

---

## Implementation Details

### Tasks / Subtasks

* [ ] **Drift Migration:**
* Tambahkan `TextColumn get notes => text().nullable()();` di tabel `Transactions`.
* Naikkan `schemaVersion` di database class (misal dari `1` ke `2`).
* Override method `migration` untuk menangani penambahan kolom secara aman.


* [ ] **UI Update (Entry Form):**
* Tambahkan `TextFormField` dengan `decoration: InputDecoration(hintText: 'Notes (Optional)')`.
* Batasi panjang karakter (misal: 100 karakter) agar tetap minimal.


* [ ] **UI Update (List Tiles):**
* Update `ListTile` agar menggunakan properti `subtitle` untuk menampilkan `transaction.notes`.


* [ ] **Logic Sync:**
* Pastikan fungsi `insert` dan `update` di DAO menyertakan field `notes`.



### Technical Summary

Tantangan utama di sini adalah **Migration**. Karena Anda sudah punya data, kita tidak boleh melakukan `delete-conflicting-outputs`. Kita harus menggunakan `MigrationStrategy` di Drift agar kolom `notes` ditambahkan ke tabel SQLite yang sudah ada di HP Anda tanpa merusak saldo wallet atau history yang sudah tercatat.

---

## Context References

**UX-Spec Update:**

* **Visual:** Catatan tidak boleh mendominasi tampilan. Gunakan font size yang lebih kecil (12pt) dan warna **Slate Grey** agar hirarki visual tetap fokus pada angka nominal (Amount).
* **Interaction:** Fokuskan kursor ke field Amount terlebih dahulu, biarkan Notes tetap opsional agar tidak memperlambat proses input < 3 detik.
