import 'dart:convert';

class Expense {
  String description;
  num amount;
  Expense({
    this.description,
    this.amount,
  });

  Expense copyWith({
    String description,
    num amount,
  }) {
    return Expense(
      description: description ?? this.description,
      amount: amount ?? this.amount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'amount': amount,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Expense(
      description: map['description'],
      amount: map['amount'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Expense.fromJson(String source) =>
      Expense.fromMap(json.decode(source));

  @override
  String toString() => 'Expense(description: $description, amount: $amount)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Expense && o.description == description && o.amount == amount;
  }

  @override
  int get hashCode => description.hashCode ^ amount.hashCode;
}
