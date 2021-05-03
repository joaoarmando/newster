import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
enum LoadingCoursesState{IDLE,LOADING,NO_INTERNET_CONNECTION,SUCCESS,EMPTY_SEARCH}
enum LoginState{IDLE,LOGIN_SUCCESSFULLY,
TEMPORARY_DISABLED, LOADING, DIFFERENT_PASSWORD,EMAIL_ALREADY_USED,
LOGIN_FAIL,LOGIN_CANCELED, WRONG_PASSWORD,DELETED_ACCOUNT}
enum ExceptionStrings{IDLE,DIFFERENT_PASSWORDS,EMAIL_ALREADY_USED,FAILED,
INVALID_NAME,TYPE_NAME_AND_LAST_NAME,TYPE_A_VALID_EMAIL,PASSWORD_MUST_BE_LEAST_8,
  NO_INTERNET_CONNECTION,WRONG_EMAIL_OR_PASSWORD,CANCELED,CHECK_NAME,CHECK_EMAIL,
  EMAIL_ALREADY_SENDED, INSUFFICIENT_CHARACTERS,INSUFFICIENT_CHARACTERS_FEEDBACK}
SharedPreferences prefs;
String country;
int feedStyle;



Future<bool> hasInternetConnection(bool useDelay) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          return true;
      }
    } on SocketException catch (_) {
      if (useDelay) await Future.delayed(Duration(milliseconds:600));
      return false;
    }
    return false;
  }

  int getFeedStyle(){
    feedStyle = (prefs.getInt('feedStyle') ?? 0);
    return feedStyle;
  }

  void saveFeedStyle(int feedStyle) async{
     await prefs.setInt('feedStyle', feedStyle);
  }

  Future<Null> getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<String> getCountry() async{
    if (prefs == null) await getSharedPreferences();
    country = prefs.getString('country');
    if (country == null) country = await getCountryFromIP();
    if (country == null) country = "US"; // default country;
    return country.toUpperCase();
  }

  void saveCountry(String _country) async{
     await prefs.setString('country', _country);
    getCountry();
  }

  Future<String> getCountryFromIP() async{
    final response = await http.get(Uri.parse("https://geo.qualaroo.com/json/"));
    final location = json.decode(response.body);
    country = "${location["country_code"]}";
    saveCountry(country);
    return country;
  }

  Future<List<Map<String,dynamic>>> getAvaliableCountries() async{

    List<Map<String,dynamic>> countries = [];
    var queryBuilder = QueryBuilder(ParseObject("Categories"));
    ParseResponse avaliableCountries = await queryBuilder.query();
    if (avaliableCountries.success){

        for (ParseObject avaliableCountry in avaliableCountries.results){
          Map<String,dynamic> country = {
            "country": avaliableCountry.get("country"),
            "categories": avaliableCountry.get("categories")
          };
          countries.add(country);
        }
    }
    return countries;
  }
    