# Story 3.2: Investment Trends & Allocations (Charts)

**Status:** Ready for Implementation
**Epic:** 3 - Portfolio & Growth Visualization
**Story Point:** 3 (Data Visualization)

---

## User Story

**As a** user,
**I want** to see my net worth growth and asset distribution through interactive charts,
**so that** I can analyze my financial health over time and ensure my asset allocation is on track.

---

## Acceptance Criteria

**AC #1: Net Worth Growth Line Chart**

- **Given** data dari tabel `Investment_Snapshots`,
- **When** user membuka tab Portfolio,
- **Then** tampilkan grafik garis yang menunjukkan tren total aset selama 6 bulan terakhir menggunakan **Ocean Flow Teal**.

**AC #2: Asset Allocation Donut Chart**

- **Given** saldo saat ini dari semua Wallet,
- **When** tab Portfolio dimuat,
- **Then** tampilkan diagram donat yang mengelompokkan aset berdasarkan tipe (misal: 40% Tabungan, 40% Saham, 20% Cash).

**AC #3: Dynamic Tooltips**

- **Given** grafik garis,
- **When** user menekan atau menahan (_long press_) pada titik di grafik,
- **Then** tampilkan label (_tooltip_) yang menunjukkan nilai nominal tepat pada tanggal tersebut.

**AC #4: Chart Legend & Summary**

- **Given** diagram donat,
- **When** ditampilkan,
- **Then** sertakan legenda warna yang jelas dan ringkasan teks total Net Worth saat ini di bagian tengah donat atau di bawahnya.

---

## Implementation Details

### Tasks / Subtasks

- [ ] Setup `fl_chart` Library:
- Tambahkan dependency ke `pubspec.yaml`.

- [ ] Data Aggregation Logic:
- Buat provider `portfolioChartProvider` yang menggabungkan data histori dari snapshots.
- Kelompokkan saldo wallet berdasarkan kategori (Bank, Cash, Investment).

- [ ] UI Component: `GrowthLineChart`:
- Implementasi `LineChart` dengan kurva yang halus (_curved lines_).
- Gunakan gradien Teal di bawah garis untuk estetika **Ocean Flow**.

- [ ] UI Component: `AllocationDonutChart`:
- Implementasi `PieChart` dengan lubang di tengah (_donut style_).
- Berikan warna yang kontras namun tetap dalam palet yang disepakati (Teal, Navy, Grey).

- [ ] Interaction:
- Tambahkan `LineTouchData` untuk menangani interaksi sentuhan pada grafik.

### Technical Summary

Kita akan menggunakan library **fl_chart** karena fleksibilitasnya. Tantangan teknisnya adalah memastikan data dari SQLite dikonversi menjadi format `FlSpot` (untuk Line Chart) secara efisien. Kita akan menggunakan Riverpod `FutureProvider` agar grafik tidak membuat aplikasi _lag_ saat memproses data histori yang banyak.

### Project Structure Notes

- **Files to create:**
- `lib/features/portfolio/widgets/growth_chart.dart`
- `lib/features/portfolio/widgets/allocation_chart.dart`
- `lib/features/portfolio/screens/portfolio_screen.dart`

- **Prerequisites:** **Story 1.1** (Database), **Story 1.2** (Wallets), dan **Story 3.1** (Snapshots Data).

---

## Context References

**Tech-Spec:** [tech-spec.md](https://www.google.com/search?q=../tech-spec.md)

- Library: `fl_chart`.
- Data Source: `Investment_Snapshots` & `Wallets`.

**UX-Spec:** [ux-design-specification.md](https://www.google.com/search?q=../ux-design-specification.md)

- Theme: Ocean Flow (Teal Gradients).
- Layout: Dedicated Tab (The Strategy Zone).
