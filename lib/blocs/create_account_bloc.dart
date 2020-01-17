import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:upnews/blocs/user_bloc.dart';
import 'package:upnews/validators/signup_validator.dart';

import '../utils.dart';


class CreateAccountBloc extends BlocBase  with SignUpValidator{
   UserBloc _userBloc;


  final _nameController = BehaviorSubject<String>();
  final _emailController = BehaviorSubject<String>();
  final _passwordController = BehaviorSubject<String>();
  final _secondaryPasswordController = BehaviorSubject<String>();
  final _loginStateController = BehaviorSubject<LoginState>();
  final _loginSuccessController = BehaviorSubject<bool>();
  final _loginExceptionController = BehaviorSubject<ExceptionStrings>();


  Stream<String> get outName => _nameController.stream.transform(validateName);
  Stream<String> get outEmail => _emailController.stream.transform(validateEmail);
  Stream<String> get outPassword => _passwordController.stream.transform(validatePassword);
  Stream<String> get outSecondaryPassword => _secondaryPasswordController.stream.transform(validatePassword);
  Stream<LoginState> get outLoginState => _loginStateController.stream;
  Stream<bool> get outLoginSuccess => _loginSuccessController.stream;
  Stream<ExceptionStrings> get outLoginException => _loginExceptionController.stream;


  void setUserBloc(UserBloc bloc){
    _userBloc = bloc;
  } 
  

  Function(String) get changeName => _nameController.sink.add;
  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changePassword => _passwordController.sink.add;
  Function(String) get changeSecondaryPassword => _secondaryPasswordController.sink.add;
 

  void enableAllButtons(){
    _loginStateController.sink.add(LoginState.IDLE);
  }

  Future<void> signUp() async{
    final name = _nameController.value;
    final email = _emailController.value;
    final password = _passwordController.value;
    final secondaryPassword = _secondaryPasswordController.value;

    _loginStateController.sink.add(LoginState.LOADING);

    bool hasInternet = await hasInternetConnection(true);
    if (!hasInternet) {
      //SEM CONEXÃO COM A INTERNET
      enableAllButtons();
      _loginExceptionController.sink.add(ExceptionStrings.NO_INTERNET_CONNECTION);
      return;
    }
    LoginState signUpResult = await _userBloc.signUp(name, email, password, secondaryPassword);

      if (signUpResult == LoginState.DIFFERENT_PASSWORD){
        await Future.delayed(Duration(milliseconds: 600));
          _secondaryPasswordController.sink.addError(ExceptionStrings.DIFFERENT_PASSWORDS);
          _loginStateController.sink.add(LoginState.IDLE);
          return;
      }

      else if (signUpResult == LoginState.IDLE){
        _loginStateController.sink.add(LoginState.IDLE);
      }


      else if (signUpResult == LoginState.LOGIN_SUCCESSFULLY){
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
  


   void sendSuccessLogin(){
    _loginSuccessController.sink.add(true);
  }

  @override
  void dispose(){
    _nameController.close();
    _emailController.close();
    _passwordController.close();
    _loginStateController.close();
    _loginSuccessController.close();
    _secondaryPasswordController.close();
    _loginExceptionController.close();
   
    super.dispose();
  }
}
