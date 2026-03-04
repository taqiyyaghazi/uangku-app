# Story 4.8: Internal Wallet Transfer Logic

**Status:** Ready for Implementation
**Epic:** 4 - Post-Launch Refinements
**Story Point:** 3 (Complex Database Logic)

---

## User Story

**As a** user,
**I want** to record a transfer between two of my own wallets,
**so that** my individual wallet balances remain accurate without affecting my monthly spending budget.

---

## Acceptance Criteria

**AC #1: Transfer-Specific UI**

* **Given** layar Quick Entry (Story 2.1) pada mode "Transfer",
* **When** user mengisi data,
* **Then** tampilkan dua pemilih wallet: **"From Wallet"** dan **"To Wallet"**.

**AC #2: Balanced Transaction (Atomic)**

* **Given** input transfer (misal: Rp 1.000.000 dari Tabungan ke Cash),
* **When** tombol "Save" ditekan,
* **Then** sistem harus menjalankan satu transaksi database yang:
1. Mengurangi Rp 1.000.000 dari Wallet Asal.
2. Menambah Rp 1.000.000 ke Wallet Tujuan.
3. Mencatat record di tabel `Transactions` dengan tipe `TRANSFER`.



**AC #3: Exclusion from Budgeting**

* **Given** sebuah transaksi bertipe `TRANSFER`,
* **When** "Daily Breath" atau "Spending Chart" dihitung,
* **Then** transaksi ini **harus diabaikan** karena bukan merupakan pengeluaran riil.

**AC #4: Validation**

* **Given** input transfer,
* **When** Wallet Asal dan Wallet Tujuan adalah akun yang sama,
* **Then** tampilkan pesan error: *"Source and Destination cannot be the same."*

---

## Implementation Details

### Tasks / Subtasks

* [ ] **Database Logic (Drift DAO):**
* Buat method `performInternalTransfer(int fromId, int toId, double amount, DateTime date)`.
* Gunakan `db.transaction` untuk memastikan kedua wallet terupdate secara sinkron.


* [ ] **UI Update (Entry Sheet):**
* Gunakan `Visibility` widget untuk menyembunyikan "Category" dan menampilkan "To Wallet" hanya jika mode **Transfer** dipilih.


* [ ] **Logic Sync (Budget Service):**
* Update query di `BudgetService` agar hanya menghitung transaksi dengan `type == 'EXPENSE'`.



### Technical Summary

Ini adalah penerapan prinsip **Akuntansi Berpasangan** (*Double-Entry*). Sangat penting untuk melabeli transaksi ini sebagai `TRANSFER` di database agar saat kita membuat laporan keuangan nanti, uang yang "pindah saku" ini tidak membuat Anda panik karena disangka pengeluaran besar.

---

## Context References

**UX-Spec Update:**

* **Visual:** Gunakan icon panah dua arah (⇄) untuk mode Transfer.
* **Feedback:** Tampilkan pesan sukses seperti *"Rp 1.000.000 moved to Cash"* untuk mempertegas bahwa uangnya tidak hilang.
