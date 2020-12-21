import 'package:shared_preferences/shared_preferences.dart';

class Preferences{
  Future<String> getReadings() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('readings');
  }

  Future<bool> setReadings(String jewellersName) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.setString('readings', jewellersName);
  }
  Future<String> getCredits() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('credits');
  }

  Future<bool> setCredits(String goldRate) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.setString('credits', goldRate);
  }
  Future<String> getExtras() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('extras');
  }

  Future<bool> setExtras(String silverRate) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.setString('extras', silverRate);
  }

}