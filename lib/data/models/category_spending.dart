class CategorySpending {
  final String categoryName;
  final String colorCode;
  final double totalAmount;

  CategorySpending({
    required this.categoryName,
    required this.colorCode,
    required this.totalAmount,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategorySpending &&
          runtimeType == other.runtimeType &&
          categoryName == other.categoryName &&
          colorCode == other.colorCode &&
          totalAmount == other.totalAmount;

  @override
  int get hashCode =>
      categoryName.hashCode ^ colorCode.hashCode ^ totalAmount.hashCode;

  @override
  String toString() {
    return 'CategorySpending{categoryName: $categoryName, colorCode: $colorCode, totalAmount: $totalAmount}';
  }
}
