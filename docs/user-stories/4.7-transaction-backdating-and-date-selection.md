# Story 4.7: Transaction Backdating & Date Selection

**Status:** Ready for Implementation
**Epic:** 4 - Post-Launch Refinements
**Story Point:** 2 (Estimated 2-3 hours)

---

## User Story

**As a** user,
**I want** to select a specific date when adding or editing a transaction,
**so that** I can accurately record expenses that occurred in the past.

---

## Acceptance Criteria

**AC #1: Date Picker Trigger**

- **Given** layar Quick Entry (Story 2.1),
- **When** user sedang mengisi data,
- **Then** tampilkan sebuah tombol atau chip yang menunjukkan tanggal (Default: "Today").

**AC #2: Calendar Interface**

- **Given** tombol tanggal ditekan,
- **When** kalender muncul,
- **Then** user harus bisa memilih tanggal mana pun di masa lalu (Tanggal di masa depan harus dinonaktifkan untuk mencegah kesalahan).

**AC #3: Data Integrity**

- **Given** transaksi dengan tanggal terpilih (misal: 2 hari lalu),
- **When** disimpan,
- **Then** kolom `date` di tabel `Transactions` harus menyimpan _timestamp_ dari tanggal pilihan tersebut, bukan waktu saat tombol simpan ditekan.

**AC #4: Dynamic Breath Impact**

- **Given** pengeluaran dicatat mundur ke bulan yang sama,
- **When** disimpan,
- **Then** "Daily Breath" harus langsung menghitung ulang sisa jatah harian berdasarkan total pengeluaran bulan tersebut yang baru saja bertambah.

---

## Implementation Details

### Tasks / Subtasks

- [ ] **UI Update (Quick Entry):**
- Tambahkan `ActionChip` atau `OutlinedButton` dengan icon 📅.
- Gunakan fungsi bawaan Flutter `showDatePicker()`.

- [ ] **State Management:**
- Buat variabel state `selectedDate` di dalam form (Default: `DateTime.now()`).

- [ ] **Logic Sync:**
- Pastikan saat memanggil `insertTransaction`, parameter `date` menggunakan `selectedDate` tersebut.

- [ ] **Formatting:**
- Gunakan package `intl` untuk menampilkan format tanggal yang manusiawi (misal: "Mon, 2 Mar" bukan "2026-03-02").

### Technical Summary

Ini adalah perubahan kecil pada UI tapi besar dampaknya pada data. Kita harus memastikan bahwa `DateTime` yang disimpan tetap menyertakan informasi waktu (jam/menit) jika memungkinkan, atau setidaknya diatur ke jam 12 siang pada tanggal terpilih agar urutan kronologis di Story 4.2 tetap rapi.

---

## Context References

**UX-Spec Update:**

- **Visual:** Letakkan pemilih tanggal di dekat kolom nominal agar user sadar bahwa mereka bisa mengubahnya sebelum menekan "Save".
- **Theme:** Gunakan warna **Teal** untuk tanggal yang terpilih.
