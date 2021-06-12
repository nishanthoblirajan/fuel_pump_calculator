import 'dart:convert';

class Extra {
  String description;
  num amount;
  Extra({
    required this.description,
    required this.amount,
  });

  Extra copyWith({
    required String description,
    required num amount,
  }) {
    return Extra(
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

  factory Extra.fromMap(Map<String, dynamic> map) {
    if (map == null) return Extra(
      description: '',
      amount:0,
    );

    return Extra(
      description: map['description'],
      amount: map['amount'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Extra.fromJson(dynamic json){
    Extra extra = new Extra(description: json["description"] as String,amount: json["amount"] as num);
    return extra;


  }

  @override
  String toString() =>
      'Extras:\n $description: ${amount.toStringAsFixed(2)}\n';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Extra && o.description == description && o.amount == amount;
  }

  @override
  int get hashCode => description.hashCode ^ amount.hashCode;
}
