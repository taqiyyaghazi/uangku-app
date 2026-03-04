# Story 4.2: Recent Transactions Feed

**Status:** Ready for Implementation
**Epic:** 4 - Post-Launch Refinements
**Story Point:** 2 (Estimated 2-3 hours)

---

## User Story

**As a** user,
**I want** to see a list of my most recent transactions on the dashboard,
**so that** I can quickly verify if I have already recorded an expense and spot any input errors immediately.

---

## Acceptance Criteria

**AC #1: The "Activity" Section**

- **Given** Dashboard utama,
- **When** user melakukan scroll ke bawah (di bawah Wallet Grid & Daily Breath),
- **Then** tampilkan bagian bernama "Recent Activity" yang berisi maksimal 10 transaksi terakhir.

**AC #2: Transaction Row Visualization**

- **Given** sebuah transaksi dalam daftar,
- **When** ditampilkan,
- **Then** harus menyertakan:
- **Icon Kategori** (misal: 🍔 untuk Food).
- **Nama Wallet** asal/tujuan.
- **Label Waktu** (misal: "Today, 14:30" atau "Yesterday").
- **Amount** dengan warna Teal untuk Income dan Soft Red/Grey untuk Expense.

**AC #3: Empty State**

- **Given** user baru yang belum memiliki transaksi,
- **When** membuka Dashboard,
- **Then** tampilkan ilustrasi atau teks halus: _"Belum ada transaksi. Tap + untuk memulai."_

**AC #4: Real-time Sync**

- **Given** user baru saja menambah transaksi via Story 2.1,
- **When** kembali ke Dashboard,
- **Then** transaksi tersebut harus muncul di urutan paling atas secara otomatis.

---

## Implementation Details

### Tasks / Subtasks

- [ ] **Data Fetching (Drift):**
- Buat query di DAO: `watchRecentTransactions(int limit)`.
- Gunakan `orderBy([ (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc) ])`.

- [ ] **State Management (Riverpod):**
- Buat `recentTransactionsProvider` yang mendengarkan stream dari Drift.

- [ ] **UI Component:**
- Buat widget `TransactionItem` (Stateless): Gunakan `ListTile` dengan `leading: CircleAvatar` untuk icon kategori.
- Buat widget `RecentActivityList`: Gunakan `ListView.separated` agar ada garis pembatas antar transaksi.

- [ ] **Formatting:**
- Gunakan package `intl` untuk format mata uang dan tanggal agar rapi.

### Technical Summary

Kunci dari fitur ini adalah **Reaktivitas**. Karena kita menggunakan `watchRecentTransactions`, setiap kali Anda menambah, mengedit, atau menghapus transaksi (di Story 4.3 nanti), daftar ini akan beranimasi dan memperbarui dirinya sendiri tanpa perlu _pull-to-refresh_.

---

## Context References

**UX-Spec Update:**

- **Typography:** Gunakan ukuran font yang lebih kecil untuk "Wallet Name" dan "Timestamp" agar kontras dengan angka nominal.
- **Color:** Expense tidak perlu merah menyala (agar tidak menghakimi), gunakan **Slate Grey** atau **Deep Amber**.
