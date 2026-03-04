# Story 4.3: Transaction Management (Edit & Delete)

**Status:** Ready for Implementation
**Epic:** 4 - Post-Launch Refinements
**Story Point:** 3 (Complex Logic)

---

## User Story

**As a** user,
**I want** to edit or delete existing transactions,
**so that** I can correct input mistakes and ensure my wallet balances and "Daily Breath" remain accurate.

---

## Acceptance Criteria

**AC #1: Interaction Point**

- **Given** daftar transaksi di Dashboard (dari Story 4.2),
- **When** user menekan (_tap_) salah satu baris transaksi,
- **Then** buka Bottom Sheet yang menampilkan detail transaksi dan tombol aksi **"Edit"** serta **"Delete"**.

**AC #2: Atomic Deletion (The Reversal)**

- **Given** user memilih "Delete",
- **When** konfirmasi disetujui,
- **Then** sistem harus menjalankan transaksi database tunggal yang:

1. Menghapus baris transaksi tersebut.
2. Menghitung balik saldo Wallet (Contoh: Menghapus pengeluaran Rp 50rb akan menambah saldo Wallet Rp 50rb).

**AC #3: Smart Editing**

- **Given** user memilih "Edit",
- **When** user mengubah angka (misal dari Rp 50rb ke Rp 70rb),
- **Then** sistem harus menyesuaikan saldo Wallet berdasarkan _selisihnya_ (Rp 20rb dikurangi dari Wallet).

**AC #4: Breath Recalculation**

- **Given** transaksi dihapus atau diubah,
- **When** proses database selesai,
- **Then** widget "Daily Breath" harus langsung memperbarui jatah harian berdasarkan total pengeluaran bulan ini yang sudah terkoreksi.

---

## Implementation Details

### Tasks / Subtasks

- [ ] **Database Logic (Drift DAO):**
- Implementasi `deleteTransactionAtomic(Transaction t)`:

```dart
return transaction(() async {
  await (delete(transactions)..where((tbl) => tbl.id.equals(t.id))).go();
  final wallet = await (select(wallets)..where((tbl) => tbl.id.equals(t.walletId))).getSingle();
  final newBalance = t.type == 'expense' ? wallet.balance + t.amount : wallet.balance - t.amount;
  await (update(wallets)..where((tbl) => tbl.id.equals(t.walletId))).write(WalletsCompanion(balance: Value(newBalance)));
});

```

- [ ] **UI Component:**
- Buat `TransactionDetailSheet` yang menampilkan informasi lengkap (Tanggal, Jam, Wallet, Kategori, Catatan).

- [ ] **Confirmation Dialog:**
- Tambahkan "Alert Dialog" sebelum menghapus untuk mencegah klik yang tidak sengaja.

### Technical Summary

Sangat penting untuk menggunakan fitur `transaction` di Drift. Kita tidak ingin record transaksi terhapus tapi saldo wallet gagal terupdate (atau sebaliknya). Dengan `atomic update`, jika satu proses gagal, seluruh rangkaian akan dibatalkan untuk menjaga keakuratan uang Anda.

---

## Context References

**Tech-Spec Update:**

- **Logic:** Selalu gunakan saldo wallet saat ini sebagai basis kalkulasi ulang.

**UX-Spec Update:**

- **Color:** Tombol "Delete" harus berwarna merah lembut (Soft Red) untuk memberi peringatan visual, namun tetap dalam palet **Ocean Flow**.
