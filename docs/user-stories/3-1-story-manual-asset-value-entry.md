# Story 3.1: Manual Asset Value Entry

**Status:** Ready for Implementation
**Epic:** 3 - Portfolio & Growth Visualization
**Story Point:** 2 (Estimated 3-4 hours)

---

## User Story

**As a** user,
**I want** to manually update the total value of my investment wallets (Stocks, Crypto, Gold),
**so that** I can track my net worth growth without having to record every single buy or sell transaction.

---

## Acceptance Criteria

**AC #1: Portfolio Update Interface**

- **Given** sebuah Wallet dengan tipe "Investment",
- **When** user membuka detail wallet atau tab Portfolio,
- **Then** harus tersedia tombol "Update Current Value".

**AC #2: Snapshot Creation**

- **Given** user memasukkan angka nilai aset baru (misal: Nilai Saham saat ini),
- **When** tombol "Save" ditekan,
- **Then** sistem harus menyimpan record baru di tabel `Investment_Snapshots` dengan _timestamp_ saat ini.

**AC #3: Wallet Balance Synchronization**

- **Given** nilai aset baru disimpan,
- **When** proses simpan berhasil,
- **Then** saldo di tabel `Wallets` untuk akun tersebut harus otomatis terupdate sesuai nilai terbaru.

**AC #4: History Logs**

- **Given** tab Portfolio,
- **When** user ingin melihat riwayat,
- **Then** tampilkan daftar pembaruan nilai terakhir (log) agar user tahu kapan terakhir kali mereka melakukan _update_.

---

## Implementation Details

### Tasks / Subtasks

- [ ] UI Component: `AssetUpdateModal`:
- Input field sederhana dengan format mata uang.
- Menampilkan nilai sebelumnya sebagai referensi.

- [ ] Database Logic (Drift):
- Definisikan tabel `InvestmentSnapshots`: `id`, `wallet_id`, `amount`, `created_at`.
- Buat fungsi DAO: `recordAssetSnapshot(int walletId, double newAmount)`.

- [ ] Logic Update:
- Gunakan Drift `transaction` untuk memastikan `InvestmentSnapshots` bertambah DAN `Wallets.balance` berubah secara atomik.

- [ ] State Management:
- Invalidasi `portfolioProvider` (Riverpod) agar grafik di Story 3.2 otomatis menggambar ulang titik terbaru.

### Technical Summary

Strategi ini disebut **"Snapshot Pattern"**. Kita tidak menghitung saldo dari ribuan transaksi, melainkan mengambil "foto" nilai aset Anda pada waktu tertentu. Ini sangat efisien untuk performa aplikasi dan sangat mudah bagi user (hanya butuh 5 detik untuk update nilai portfolio seminggu sekali).

### Project Structure Notes

- **Files to create/modify:**
- `lib/data/local_db.dart` (Tambah tabel snapshots).
- `lib/features/portfolio/widgets/asset_update_modal.dart`.

- **Prerequisites:** **Story 1.1** (Database Foundation) dan **Story 1.2** (Wallet Management).

---

## Context References

**Tech-Spec:** [tech-spec.md](https://www.google.com/search?q=../tech-spec.md)

- Stack: Drift + SQLite.
- Pattern: Manual "Current Value" update.

**UX-Spec:** [ux-design-specification.md](https://www.google.com/search?q=../ux-design-specification.md)

- Layout: Dedicated Tab (Strategy Zone).
- Vibe: Professional & Reliable.
