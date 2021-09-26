import 'package:shared_preferences/shared_preferences.dart';

class HelperFunction {
  static String sharedPreferenceUserLoggedInKey = 'ISLOGGEDIN';
  static String sharedPreferenceUserNameKey = 'USERNAMEKEY';
  static String sharedPreferenceUserEmailKey = 'USEREMAILKEY';

  ///saving data to shared preferences
  static Future<bool> saveuserLoggedInSharedPreference(bool isloggedin) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(sharedPreferenceUserLoggedInKey, isloggedin);
  }

  static Future<bool> saveUserNameSharedPreference(String userName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(sharedPreferenceUserNameKey, userName);
  }

  static Future<bool> saveUserEmailSharedPreference(String userEmail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(sharedPreferenceUserEmailKey, userEmail);
  }

  ///geeting data from shared preferences

  static Future<bool?> getuserLoggedInSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.getBool(sharedPreferenceUserLoggedInKey);
  }

  static Future<String?> getuserNameSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.getString(sharedPreferenceUserNameKey);
  }

  static Future<String?> getuserEmailSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.getString(sharedPreferenceUserEmailKey);
  }
}
