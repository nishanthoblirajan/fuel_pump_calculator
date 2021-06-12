class SavedData {
  final int id;
  final String time;
  final String credits;
  final String extras;
  final String readings;

  SavedData({ this.id,required this.time,required this.credits,required this.extras, required this.readings});
  Map<String, dynamic> toMap() {
    print('savedData in toMap() is $time');
    return {
      'id': id,
      'time':time,
      'credits': credits,
      'extras': extras,
      'readings':readings,
    };
  }

  @override
  String toString() {
    return '$id,$time,$credits,$extras,$readings';
  }

}