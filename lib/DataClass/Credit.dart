import 'dart:convert';

class Credit {
  String description;
  num litre;
  num rate;
  Credit({
    required this.description,
    required this.litre,
    required this.rate,
  });

  Credit copyWith({
    required String description,
    required num litre,
    required num rate,
  }) {
    return Credit(
      description: description ?? this.description,
      litre: litre ?? this.litre,
      rate: rate ?? this.rate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'litre': litre,
      'rate': rate,
    };
  }

  factory Credit.fromMap(Map<String, dynamic> map) {
    // ignore: unnecessary_null_comparison
    if (map == null) {
      return Credit(
        description: '',
        litre: 0,
        rate: 0,
      );
    }

    return Credit(
      description: map['description'],
      litre: map['litre'],
      rate: map['rate'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Credit.fromJson(dynamic json){
    Credit credit = new Credit(description: json["description"] as String, rate: json["rate"] as num,litre: json["litre"] as num);
    return credit;
  }

  num credit(num litre, num rate) {
    return litre * rate;
  }

  @override
  String toString() =>
      'Credit:\n Description: $description\n Litre: $litre\n Rate: $rate\n Amount:${credit(litre, rate).toStringAsFixed(2)}\n';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Credit &&
        o.description == description &&
        o.litre == litre &&
        o.rate == rate;
  }

  @override
  int get hashCode => description.hashCode ^ litre.hashCode ^ rate.hashCode;
}
