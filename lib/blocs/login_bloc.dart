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
  final _loginSuccessController = BehaviorSubject<bool>();
  final _loginExceptionController = BehaviorSubject<ExceptionStrings>();



  Stream<dynamic> get outEmail => _emailController.stream.transform(validateEmail);
  Stream<String> get outPassword => _passwordController.stream.transform(validatePassword);
  Stream<LoginState> get outLoginState => _loginStateController.stream;
  Stream<bool> get outLoginSuccess => _loginSuccessController.stream;
  Stream<ExceptionStrings> get outLoginException => _loginExceptionController.stream;


  void setUserBloc(UserBloc bloc){
    _userBloc = bloc;
  } 
  

  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changePassword => _passwordController.sink.add;


  
  Future<void> signIn() async{
    _loginStateController.sink.add(LoginState.LOADING);

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
  }




   void sendSuccessLogin(){
    _loginSuccessController.sink.add(true);
  }

  @override
  void dispose(){
    _emailController.close();
    _passwordController.close();
    _loginStateController.close();
    _loginSuccessController.close();
    _loginExceptionController.close();
   
    super.dispose();
  }
}
