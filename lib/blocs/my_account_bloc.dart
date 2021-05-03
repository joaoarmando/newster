import 'dart:io';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:upnews/blocs/user_bloc.dart';
import 'package:upnews/validators/signup_validator.dart';
import 'package:http/http.dart' as http;

import '../utils.dart';



class MyAccountBloc extends BlocBase  with SignUpValidator{
   UserBloc _userBloc;

   String initialUserName,initialEmail;

  final _nameController = BehaviorSubject<String>();
  final _emailController = BehaviorSubject<String>();
  final _pictureController = BehaviorSubject<File>();
  final _loginStateController = BehaviorSubject<LoginState>();
  final _deleteAccountStateController = BehaviorSubject<LoginState>();
  final _logoutAccountStateController = BehaviorSubject<LoginState>();
  final _savedSuccessController = BehaviorSubject<bool>();
  final _loginExceptionController = BehaviorSubject<ExceptionStrings>();


  Stream<String> get outName => _nameController.stream.transform(validateName);
  Stream<String> get outEmail => _emailController.stream.transform(validateEmail);
  Stream<File> get outPicture => _pictureController.stream;

  Stream<LoginState> get outEditState => _loginStateController.stream;
  Stream<LoginState> get outDeleteState => _deleteAccountStateController.stream;
  Stream<LoginState> get outLogoutState => _logoutAccountStateController.stream;
  Stream<bool> get outSaved => _savedSuccessController.stream;
  Stream<ExceptionStrings> get outLoginException => _loginExceptionController.stream;


  void setUserBloc(UserBloc bloc){
    _userBloc = bloc;
  }
  void setInitialData(String username, String email){
    initialUserName = username;
    initialEmail = email;
  } 
  

  Function(String) get changeName => _nameController.sink.add;
  Function(String) get changeEmail => _emailController.sink.add;

 

  void enableAllButtons(){
    _loginStateController.sink.add(LoginState.IDLE);
  }

  Future<void> saveChanges() async{
    _loginStateController.sink.add(LoginState.LOADING);
    
    await Future.delayed(Duration(milliseconds: 500)); // AGUARDA ATÉ QUE TODOS OS DADOS CHEGUEM A STREAM
    

    final name = _nameController.value;
    final email = _emailController.value;
    final picture = _pictureController.value;

    if (name == initialUserName && email == initialEmail && picture == null) {
        sendSuccessLogin();
        return;
    }


    if (name != initialUserName && !isValidName(name)) {
        enableAllButtons();
        _loginExceptionController.sink.add(ExceptionStrings.CHECK_NAME);
        return;
    }
    if (email != initialEmail && !isValidEmail(email)){
        enableAllButtons();
        _loginExceptionController.sink.add(ExceptionStrings.CHECK_EMAIL);
        return;
    }

  
    bool hasInternet = await hasInternetConnection(false);

    if (!hasInternet) {
      //SEM CONEXÃO COM A INTERNET
      enableAllButtons();
      _loginExceptionController.sink.add(ExceptionStrings.NO_INTERNET_CONNECTION);
      return;
    }


    LoginState signUpResult = await _userBloc.updateProfile(name??"", email??"", picture);


      if (signUpResult == LoginState.LOGIN_SUCCESSFULLY){
        _loginStateController.sink.add(LoginState.LOGIN_SUCCESSFULLY);
      }
      else {
        if (signUpResult == LoginState.EMAIL_ALREADY_USED){
          _emailController.sink.addError(ExceptionStrings.EMAIL_ALREADY_USED);
          _loginExceptionController.sink.add(ExceptionStrings.EMAIL_ALREADY_USED);
        } 
        else _loginExceptionController.sink.add(ExceptionStrings.FAILED);
        
        await Future.delayed(Duration(milliseconds: 300));
        _loginStateController.sink.add(LoginState.IDLE);
    } 
    
  }

  void setNewPicture(File picture){
    _pictureController.sink.add(picture);
  }

  void getUserPicture() async{
    if (_userBloc.getUserPictureUrl() == null) {
       _pictureController.sink.add(null);
       return;
    }
    var response = await http.get(Uri.parse(_userBloc.getUserPictureUrl()));
    File picture = await _userBloc.createFileFromString(response);
    _pictureController.sink.add(picture);
  }
  
  bool isValidName(String name){
    if (name.length == 0)
        return false;
      else if (name.length > 5 && name.split(" ").length > 1 && name.split(" ")[1].length > 0)
        return true;
      else if (name.length > 0  && name.split(" ").length < 2 || name.split(" ")[1].length == 0)
       return false;
       
     return false;  
  }

  bool isValidEmail(String email){
    bool emailValid = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
      if (emailValid)
        return true;
      else
        return false;  
  }

  void sendSuccessLogin(){
    _savedSuccessController.sink.add(true);
  }

  void deleteAccount() async{
    _deleteAccountStateController.sink.add(LoginState.LOADING);
    await Future.delayed(Duration(milliseconds: 500));

    bool isDeleted = await _userBloc.deleteAccount();

    if (isDeleted) _deleteAccountStateController.sink.add(LoginState.LOGIN_SUCCESSFULLY);
    else  _deleteAccountStateController.sink.add(LoginState.LOGIN_FAIL);
    
  }
  void logout() async{
    _logoutAccountStateController.sink.add(LoginState.LOADING);
    await Future.delayed(Duration(milliseconds: 500));

    bool logoutSuccess = await _userBloc.logout();

    if (logoutSuccess) _logoutAccountStateController.sink.add(LoginState.LOGIN_SUCCESSFULLY);
    else  _logoutAccountStateController.sink.add(LoginState.LOGIN_FAIL);
    
  }

  void deletedSuccess(){
    _deleteAccountStateController.sink.add(LoginState.DELETED_ACCOUNT);
  }

  @override
  void dispose(){
    _nameController.close();
    _emailController.close();
    _pictureController.close();
    _loginStateController.close();
    _deleteAccountStateController.close();
    _savedSuccessController.close();
    _loginExceptionController.close();
    _logoutAccountStateController.close();
   
    super.dispose();
  }
}
