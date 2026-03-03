/// Default transaction categories for quick selection.
///
/// Organized by transaction type. This is a pure constant — no I/O.
class TransactionCategories {
  TransactionCategories._();

  static const List<String> expense = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Entertainment',
    'Health',
    'Education',
    'Other',
  ];

  static const List<String> income = [
    'Salary',
    'Freelance',
    'Investment',
    'Gift',
    'Other',
  ];

  static const List<String> transfer = ['Transfer'];
}
