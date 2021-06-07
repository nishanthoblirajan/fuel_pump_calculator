class SavedData {
  final int id;
  final String time;
  final String credits;
  final String extras;
  final String readings;

  SavedData({this.id,this.time,this.credits,this.extras, this.readings});
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