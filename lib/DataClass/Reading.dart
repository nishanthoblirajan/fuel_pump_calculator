import 'dart:convert';

class Reading {
  String description;
  num startingReading;
  num endingReading;
  num rate;
  Reading({
    required this.description,
    required this.startingReading,
    required this.endingReading,
    required this.rate,
  });

  Reading copyWith({
    required String description,
    required num startingReading,
    required num endingReading,
    required num rate,
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
    if (map == null) return Reading(
      description: '',
      startingReading: 0,
      endingReading: 0,
      rate: 0,
    );

    return Reading(
      description: map['description'],
      startingReading: map['startingReading'],
      endingReading: map['endingReading'],
      rate: map['rate'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Reading.fromJson(dynamic json) {
    Reading reading = new Reading(description: json["description"] as String,
    startingReading: json["startingReading"] as num,
    endingReading: json["endingReading"] as num,
    rate: json["rate"] as num);
    return reading;
  }

  num reading(num starting, num ending, num rate) {
    return (ending - starting) * rate;
  }

  num readingLitre(num starting, num ending) {
    return (ending - starting);
  }

  @override
  String toString() {
    return 'Readings:\n Description: $description\n Starting: $startingReading\n Ending: $endingReading\n Litres: ${readingLitre(startingReading, endingReading).toStringAsFixed(2)}\n Rate: $rate\n Amount: ${reading(startingReading, endingReading, rate).toStringAsFixed(2)}\n';
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
