
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:upnews/blocs/user_bloc.dart';
import 'package:upnews/validators/signup_validator.dart';
import '../utils.dart';


class ChangePasswordBloc extends BlocBase  with SignUpValidator{
   UserBloc _userBloc;

  final _passwordController = BehaviorSubject<String>();
  final _secondaryPasswordController = BehaviorSubject<String>();
  final _loginStateController = BehaviorSubject<LoginState>();
  final _savedSuccessController = BehaviorSubject<bool>();
  final _loginExceptionController = BehaviorSubject<ExceptionStrings>();


  Stream<String> get outPassword => _passwordController.stream.transform(validatePassword);
  Stream<String> get outSecondaryPassword => _secondaryPasswordController.stream.transform(validatePassword);

  Stream<LoginState> get outChangePasswordState => _loginStateController.stream;
  Stream<bool> get outSaved => _savedSuccessController.stream;
  Stream<ExceptionStrings> get outLoginException => _loginExceptionController.stream;


  void setUserBloc(UserBloc bloc){
    _userBloc = bloc;
  }

  Function(String) get changePassword => _passwordController.sink.add;
  Function(String) get changeSecondaryPassword => _secondaryPasswordController.sink.add;

 

  void enableAllButtons(){
    _loginStateController.sink.add(LoginState.IDLE);
  }

  Future<void> saveChanges() async{
    _loginStateController.sink.add(LoginState.LOADING);
    
    await Future.delayed(Duration(milliseconds: 500)); // AGUARDA ATÉ QUE TODOS OS DADOS CHEGUEM A STREAM
    

    final password = _passwordController.value;
    final secondaryPassword = _secondaryPasswordController.value;


    if (password != secondaryPassword) {
        enableAllButtons();
        _loginExceptionController.sink.add(ExceptionStrings.DIFFERENT_PASSWORDS);
        return;
    }

    if (!isValidPassword(password)){
        enableAllButtons();
        _loginExceptionController.sink.add(ExceptionStrings.PASSWORD_MUST_BE_LEAST_8);
        return;
    }

  
    bool hasInternet = await hasInternetConnection(false);

    if (!hasInternet) {
      //SEM CONEXÃO COM A INTERNET
      enableAllButtons();
      _loginExceptionController.sink.add(ExceptionStrings.NO_INTERNET_CONNECTION);
      return;
    }


    LoginState updatePasswordResult = await _userBloc.updatePassword(password);


      if (updatePasswordResult == LoginState.LOGIN_SUCCESSFULLY){
        _loginStateController.sink.add(LoginState.LOGIN_SUCCESSFULLY);
        
      }
      else {

        _loginExceptionController.sink.add(ExceptionStrings.FAILED);
        await Future.delayed(Duration(milliseconds: 300));
        _loginStateController.sink.add(LoginState.IDLE);
    } 
    
  }


  void sendSuccessLogin(){
    _savedSuccessController.sink.add(true);
  }

  bool isValidPassword(String password){
       if (password.length > 7)
        return true;
      else
        return false;
  }


  @override
  void dispose(){
    _passwordController.close();
    _secondaryPasswordController.close();
    _loginStateController.close();
    _savedSuccessController.close();
    _loginExceptionController.close();
   
    super.dispose();
  }
}
