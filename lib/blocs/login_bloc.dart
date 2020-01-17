import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:upnews/blocs/user_bloc.dart';
import 'package:upnews/validators/signup_validator.dart';

import '../utils.dart';



class LoginBloc extends BlocBase  with SignUpValidator{
   UserBloc _userBloc;


  final _emailController = BehaviorSubject<String>();
  final _passwordController = BehaviorSubject<String>();
  final _loginStateController = BehaviorSubject<LoginState>();
  final _loginFacebookStateController = BehaviorSubject<LoginState>();
  final _loginGoogleStateController = BehaviorSubject<LoginState>();
  final _loginSuccessController = BehaviorSubject<bool>();
  final _loginExceptionController = BehaviorSubject<ExceptionStrings>();



  Stream<dynamic> get outEmail => _emailController.stream.transform(validateEmail);
  Stream<String> get outPassword => _passwordController.stream.transform(validatePassword);
  Stream<LoginState> get outLoginState => _loginStateController.stream;
  Stream<LoginState> get outLoginFacebookState => _loginFacebookStateController.stream;
  Stream<LoginState> get outLoginGoogleState => _loginGoogleStateController.stream;
  Stream<bool> get outLoginSuccess => _loginSuccessController.stream;
  Stream<ExceptionStrings> get outLoginException => _loginExceptionController.stream;


  void setUserBloc(UserBloc bloc){
    _userBloc = bloc;
  } 
  

  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changePassword => _passwordController.sink.add;


  
  Future<void> signIn() async{
    _loginStateController.sink.add(LoginState.LOADING);
    _loginFacebookStateController.sink.add(LoginState.TEMPORARY_DISABLED);
    _loginGoogleStateController.sink.add(LoginState.TEMPORARY_DISABLED);

    final username = _emailController.value;
    final password = _passwordController.value;
   
    bool hasInternet = await hasInternetConnection(true);
    if (!hasInternet) {
      //SEM CONEXÃO COM A INTERNET
      enableAllButtons();
      _loginExceptionController.sink.add(ExceptionStrings.NO_INTERNET_CONNECTION);
      return;
    }

    LoginState signInResult = await _userBloc.signIn(username, password);

    if (signInResult == LoginState.LOGIN_SUCCESSFULLY){
      _loginStateController.sink.add(LoginState.LOGIN_SUCCESSFULLY);
    }
    else if (signInResult == LoginState.WRONG_PASSWORD){
       _passwordController.sink.addError(ExceptionStrings.WRONG_EMAIL_OR_PASSWORD);
      enableAllButtons();
    }
    else if (signInResult == LoginState.LOGIN_FAIL){
       enableAllButtons();
      _loginExceptionController.sink.add(ExceptionStrings.FAILED);
    }

    
  }
 

  void enableAllButtons(){
    _loginStateController.sink.add(LoginState.IDLE);
    _loginFacebookStateController.sink.add(LoginState.IDLE);
    _loginGoogleStateController.sink.add(LoginState.IDLE);
  }



  Future<void> signInWithFacebook() async {
      _loginStateController.sink.add(LoginState.TEMPORARY_DISABLED);
      _loginGoogleStateController.sink.add(LoginState.TEMPORARY_DISABLED);
      _loginFacebookStateController.sink.add(LoginState.LOADING);

      bool hasInternet = await hasInternetConnection(true);
      if (!hasInternet) {
        //SEM CONEXÃO COM A INTERNET
        enableAllButtons();
        _loginExceptionController.sink.add(ExceptionStrings.NO_INTERNET_CONNECTION);
        return;
      }

       LoginState signInFacebookResult = await _userBloc.signInWithFacebook();
     
      if (signInFacebookResult == LoginState.LOGIN_SUCCESSFULLY){
        _loginFacebookStateController.sink.add(LoginState.LOGIN_SUCCESSFULLY);
      }
      else if (signInFacebookResult == LoginState.LOGIN_CANCELED){
          _loginExceptionController.sink.add(ExceptionStrings.CANCELED);
          enableAllButtons();
      }
      else {
         _loginExceptionController.sink.add(ExceptionStrings.FAILED);
          enableAllButtons();
      }

  }


  void signInWithGoogle() async{
   /* _loginGoogleStateController.sink.add(LoginState.LOADING);
    _loginFacebookStateController.sink.add(LoginState.TEMPORARY_DISABLED);
    _loginStateController.sink.add(LoginState.TEMPORARY_DISABLED);

    bool hasInternet = await hasInternetConnection(true);
    if (!hasInternet) {
      //SEM CONEXÃO COM A INTERNET
      enableAllButtons();
      _loginExceptionController.sink.add("Sem conexão com a internet");
      return;
    }

    LoginState signInGoogleResult = await _userBloc.signInWithGoogle();

    if (signInGoogleResult == LoginState.LOGIN_SUCCESSFULLY){
        _loginGoogleStateController.sink.add(LoginState.LOGIN_SUCCESSFULLY);
      }
      else if (signInGoogleResult == LoginState.LOGIN_CANCELED){
          _loginExceptionController.sink.add("Login Cancelado.");
          enableAllButtons();
      }
      else {
         _loginExceptionController.sink.add("Não foi possível fazer login agora.");
          enableAllButtons();
      } */

  }

   void sendSuccessLogin(){
    _loginSuccessController.sink.add(true);
  }

  @override
  void dispose(){
    _emailController.close();
    _passwordController.close();
    _loginStateController.close();
    _loginFacebookStateController.close();
    _loginGoogleStateController.close();
    _loginSuccessController.close();
    _loginExceptionController.close();
   
    super.dispose();
  }
}
