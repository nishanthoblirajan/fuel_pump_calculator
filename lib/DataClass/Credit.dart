import 'dart:convert';

class Credit {
  String description;
  num litre;
  num rate;
  Credit({
    this.description,
    this.litre,
    this.rate,
  });

  Credit copyWith({
    String description,
    num litre,
    num rate,
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
    if (map == null) return null;

    return Credit(
      description: map['description'],
      litre: map['litre'],
      rate: map['rate'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Credit.fromJson(String source) => Credit.fromMap(json.decode(source));

  @override
  String toString() =>
      'Credit(description: $description, litre: $litre, rate: $rate)';

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
