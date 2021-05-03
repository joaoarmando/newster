import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:upnews/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';



enum DialogState{DIALOG_OPTIONS,LOGIN_STATE,LOGIN_SUCCESSFULLY}
class UserBloc extends BlocBase{


  UserBloc() {
    getSharedPreferences();
  }

  String userEmail, userName, urlPicture;
  SharedPreferences prefs;

  final _userController = BehaviorSubject<ParseUser>();
  final _pictureController = BehaviorSubject<String>();
  final _dialogStateController = BehaviorSubject<DialogState>();
  
  ParseUser user;

  Stream get outUser => _userController.stream;
  Stream get outProfilePicture => _pictureController.stream;
  Stream<DialogState> get outDialogState => _dialogStateController.stream;

  
  Future<Null> checkLogin() async {
    user = await ParseUser.currentUser();
    if (user != null) print("user = ${user.sessionToken}");
    if (prefs == null) await getSharedPreferences();
    if (user == null) {
       saveUrlPictureSharedPreferences(null);
      _pictureController.sink.add(urlPicture);
      return;
    }

    var response = await ParseUser.getCurrentUserFromServer(user.sessionToken);
    if (response == null) return;
    if (response.success) {
      user = response.result;
      userName = user.get("name");
      userEmail = user.get("email");
      if (user.get("picture") != null) {
        urlPicture = user.get("picture")["url"];
      saveUrlPictureSharedPreferences(user.get("picture")["url"]);
      }
      _pictureController.sink.add(urlPicture);
      
    }else {
      if (response.error.code == 209){
        user.logout();
        setUser(null);
      }
    }
    return;
  }

  String getUserPictureUrl() => urlPicture;

  void setUser(ParseUser u){
    user = u;
    _userController.add(user);
  }

  String getUrlPictureFromSharedPreferences(){
    if (prefs != null) urlPicture = (prefs.getString('urlPicture') ?? null);
    _pictureController.sink.add(urlPicture);
    return urlPicture;

  }

  void saveUrlPictureSharedPreferences(String url) async{
      if (url == null) {
          await prefs.remove("urlPicture");
      }
      else await prefs.setString('urlPicture', url);
  }

  Future<Null> getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    await checkLogin();
    return;
  }

  bool verifySignIn () => user != null;

  Future<bool> logout() async{
    ParseResponse apiResponse = await user.logout();
    if (apiResponse.success){
        setUser(null);
        saveUrlPictureSharedPreferences(null);
        _pictureController.sink.add(null);
        checkLogin();
        return true;
    }
    else return false;
   
  }
  
  Future<bool> deleteAccount() async{
    if (user != null){
      ParseResponse apiResponse = await user.destroy();
      if (apiResponse.success){
        saveUrlPictureSharedPreferences(null);
        user.logout();
        setUser(null);
        _pictureController.sink.add(null);
        checkLogin();
        return true;
      }
      else {
        print(apiResponse.error.message);
        return false;
      }
    }
   return true; 
  }

  void goToSignIn() async{
    await Future.delayed(Duration(milliseconds: 150));
    _dialogStateController.add(DialogState.LOGIN_STATE);
  }

  void backToDefaultDialog() async{
    await Future.delayed(Duration(milliseconds: 300));
    _dialogStateController.add(DialogState.DIALOG_OPTIONS);
  }

  Future<LoginState> signUp(String name, String email, String password, String secondaryPassword) async{


    if ( password != secondaryPassword){
        await Future.delayed(Duration(milliseconds: 600));
        return LoginState.DIFFERENT_PASSWORD;
    }

    var user = ParseUser(_randomUserName(usernameLength: 10), password, email)
            ..set("name", name);
    var response = await user.signUp();

    if (response == null) {
       return LoginState.IDLE;
    }

    if (response.success){
      user = response.result; 
      setUser(user);
      checkLogin();
      await Future.delayed(Duration(milliseconds: 300));
      return LoginState.LOGIN_SUCCESSFULLY;
    }
    else {
      if (response.error.code == 203){
       return LoginState.EMAIL_ALREADY_USED;
      } 
      return LoginState.LOGIN_FAIL;
    } 
    
}



  
  Future<LoginState> signIn(String username, String password) async{
    

    if (username == null || username.trim().length == 0 ||  password == null || password.trim().length == 0) {
        return LoginState.WRONG_PASSWORD;
    }

    var user = ParseUser(username, password,"");
    var response = await user.login();
    await Future.delayed(Duration(seconds: 1));
    if (response.success){
        user = response.result;
        setUser(user);
        checkLogin();
       return LoginState.LOGIN_SUCCESSFULLY;
    }
    else if (response.error.code == 101)
      return LoginState.WRONG_PASSWORD;

    else{
      setUser(user);
      await Future.delayed(Duration(seconds: 1));
      return LoginState.LOGIN_FAIL;
    }
    
  }

  
  Future<Null> getImage(String urlPicture, {bool shouldAwait}) async{
    if (shouldAwait == null) shouldAwait = false;

    var response = await http.get(Uri.parse(urlPicture));

    File imageFile = await createFileFromString(response);
    if (shouldAwait) await setProfilePicture(imageFile);
    else setProfilePicture(imageFile);
    return;
 
  }

  Future<Null> setProfilePicture(File imageFile) async{
    //await Future.delayed(Duration(seconds:2));

    if (imageFile != null){
      ParseUser user = await ParseUser.currentUser();
      if (user != null){
        user.set("picture", ParseFile(imageFile));
        await user.save();
        saveUrlPictureSharedPreferences(user.get("picture")["url"]);
        checkLogin();
        return null;
      }
    } 
    return null;
  }

  Future<LoginState> updateProfile(String name, String email, File picture) async{


      if (name.trim().length > 0) user.set("name",name.trim());
      if (email.trim().length > 0) user.set("email",email.trim());

      var response = await user.save();

      if (response.success){
        user = response.result;
        setUser(user);
        if (picture != null) await setProfilePicture(picture);
        return LoginState.LOGIN_SUCCESSFULLY;
      }
      else if (response.error.code == 203)
        return LoginState.EMAIL_ALREADY_USED;
      else{
        setUser(user);
        await Future.delayed(Duration(seconds: 1));
        return LoginState.LOGIN_FAIL;
      }

  }

  Future<LoginState> updatePassword(String password) async{
      user.set("password",password);
      var response = await user.save();

      if (response.success){
        checkLogin();
        return LoginState.LOGIN_SUCCESSFULLY;
      }
      else{
        print(response.error.message);
        setUser(user);
        await Future.delayed(Duration(seconds: 1));
        return LoginState.LOGIN_FAIL;
      }

  }

  String _randomUserName({int usernameLength}) {
    const chars = "abcdefghijklmnopqrstuvwxyz0123456789";
    Random rnd = new Random(new DateTime.now().millisecondsSinceEpoch);
    String result = "";
    for (var i = 0; i < usernameLength; i++) {
      result += chars[rnd.nextInt(chars.length)];
    }
    return result;
}

  Future<File> createFileFromString(dynamic response) async {

  if (response.bodyBytes == null) return null;

  final encodedStr = base64.encode(response.bodyBytes);
  Uint8List bytes = base64.decode(encodedStr);
  String dir = (await getApplicationDocumentsDirectory()).path;
  File file = File(
      "$dir/" + DateTime.now().millisecondsSinceEpoch.toString() + ".png");
  await file.writeAsBytes(bytes);
  return file;
 }
  


@override
void dispose(){
  _userController.close();
  _pictureController.close();
  _dialogStateController.close();
  super.dispose();
}

}