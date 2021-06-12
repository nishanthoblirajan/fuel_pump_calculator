import 'dart:convert';

class Store {
  int id;
  String date;
  String value;
  Store({
    required this.id,
    required this.date,
    required this.value,
  });

  Store copyWith({
    required int id,
    required String date,
    required String value,
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
    if (map == null) return Store(
      id: 0,
      date: '',
      value:'',
    );

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
