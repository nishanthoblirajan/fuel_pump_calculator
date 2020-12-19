import 'dart:convert';

class Reading {
  String description;
  num startingReading;
  num endingReading;
  num rate;
  Reading({
    this.description,
    this.startingReading,
    this.endingReading,
    this.rate,
  });

  Reading copyWith({
    String description,
    num startingReading,
    num endingReading,
    num rate,
  }) {
    return Reading(
      description: description ?? this.description,
      startingReading: startingReading ?? this.startingReading,
      endingReading: endingReading ?? this.endingReading,
      rate: rate ?? this.rate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'startingReading': startingReading,
      'endingReading': endingReading,
      'rate': rate,
    };
  }

  factory Reading.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Reading(
      description: map['description'],
      startingReading: map['startingReading'],
      endingReading: map['endingReading'],
      rate: map['rate'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Reading.fromJson(String source) =>
      Reading.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Reading(description: $description, startingReading: $startingReading, endingReading: $endingReading, rate: $rate)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Reading &&
        o.description == description &&
        o.startingReading == startingReading &&
        o.endingReading == endingReading &&
        o.rate == rate;
  }

  @override
  int get hashCode {
    return description.hashCode ^
        startingReading.hashCode ^
        endingReading.hashCode ^
        rate.hashCode;
  }
}
