# Epic 7.3: Export Transactions to CSV

## Tasks

- [x] Data Access Layer
  - [x] Define `TransactionWithDetails` model (combining Transaction, Category, Wallet).
  - [x] Add `getAllTransactionsWithDetails` method in `TransactionRepository` and `DriftTransactionRepository`.
  - [x] Add unit tests for the new query.
- [x] Business Logic & Export Service
  - [x] Create `ExportService` with pure CSV formatting logic (`generateCsv`).
  - [x] Implement file writing using `path_provider`.
  - [x] Add unit tests for `generateCsv`.
- [x] File & Share Integration
  - [x] Integrate with `share_plus` to trigger the Share Sheet.
  - [x] Handle permissions and error flows gracefully.
- [x] UI
  - [x] Add "Export to CSV" button in Settings/Insights screen.
  - [x] Add Loading indicator state while generating CSV.
  - [x] Show success/error snackbars after sharing.
  - [x] Fixed: Migrate deprecated `Share.shareXFiles` to `SharePlus.instance.share()` in `export_provider.dart`.
