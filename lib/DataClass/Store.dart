import 'dart:convert';

class Store {
  int id;
  String date;
  String value;
  Store({
    this.id,
    this.date,
    this.value,
  });

  Store copyWith({
    int id,
    String date,
    String value,
  }) {
    return Store(
      id: id ?? this.id,
      date: date ?? this.date,
      value: value ?? this.value,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'value': value,
    };
  }

  factory Store.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Store(
      id: map['id'],
      date: map['date'],
      value: map['value'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Store.fromJson(String source) => Store.fromMap(json.decode(source));

  @override
  String toString() => 'Store(id: $id, date: $date, value: $value)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Store && o.id == id && o.date == date && o.value == value;
  }

  @override
  int get hashCode => id.hashCode ^ date.hashCode ^ value.hashCode;
}
