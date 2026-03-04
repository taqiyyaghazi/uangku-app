# Story 4.8: Internal Wallet Transfer (Double-Entry Fix)

**Status:** Ready for Implementation (Bug-Fix Integrated)
**Epic:** 4 - Post-Launch Refinements
**Story Point:** 3 (Complex Database Logic)

---

## User Story

**As a** user,
**I want** to move money between my own wallets without categorizing it as an expense,
**so that** my wallet balances stay accurate while my "Daily Breath" budget remains unaffected.

---

## Acceptance Criteria

**AC #1: Dual-Wallet UI Mode**

- **Given** layar Quick Entry (Story 2.1) pada mode "Transfer",
- **When** diaktifkan,
- **Then** sembunyikan kolom "Category" dan tampilkan dua pemilih wallet: **"From Wallet"** dan **"To Wallet"**.

**AC #2: Nullable Category for Transfers**

- **Given** transaksi bertipe `TRANSFER`,
- **When** disimpan ke database,
- **Then** kolom `category_id` diperbolehkan bernilai **NULL** (Boleh kosong), sehingga tidak memicu error validasi database.

**AC #3: Atomic Balance Swap**

- **Given** nominal transfer (misal: Rp 500.000),
- **When** tombol "Save" ditekan,
- **Then** jalankan transaksi database tunggal yang:

1. Mengurangi Rp 500.000 dari **Wallet Asal**.
2. Menambah Rp 500.000 ke **Wallet Tujuan**.
3. Menyimpan satu record di tabel `Transactions` dengan `type: 'TRANSFER'`.

**AC #4: Budget Neutrality**

- **Given** sistem menghitung "Daily Breath" atau "Spending Report",
- **When** menemukan transaksi tipe `TRANSFER`,
- **Then** transaksi tersebut **diabaikan** (tidak mengurangi jatah harian).

---

## Implementation Details

### Tasks / Subtasks

- [ ] **Database Migration (Drift):**
- Ubah `categoryId` di tabel `Transactions` menjadi `.nullable()`.
- Tambahkan kolom `to_wallet_id` (int, nullable) di tabel yang sama.
- Naikkan `schemaVersion` dan tambahkan `MigrationStrategy`.

- [ ] **DAO Logic:**
- Buat method `performTransfer(int fromId, int toId, double amount, DateTime date, String? notes)`.
- Pastikan menggunakan `db.transaction(() async { ... })` untuk keamanan saldo.

- [ ] **UI Logic:**
- Di dalam `QuickEntrySheet`, gunakan kondisi: `if (selectedType != TransactionType.transfer) validateCategory()`.

### Technical Summary

Kita menerapkan **Double-Entry Bookkeeping**. Transaksi ini adalah "Zero-Sum Game" bagi kekayaan total Anda, namun sangat penting untuk akurasi saldo masing-masing akun (misal: memindahkan uang dari Bank ke Dompet untuk pegangan tunai).

---

## Context References

**UX-Spec Update:**

- **Icon:** Gunakan icon `Icons.swap_horiz` (⇄) untuk mode Transfer.
- **Validation:** Cegah user memilih wallet asal dan tujuan yang sama (Source != Destination).
