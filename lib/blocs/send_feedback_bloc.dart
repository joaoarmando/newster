import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:upnews/validators/signup_validator.dart';
import '../utils.dart';

class SendFeedbackBloc extends BlocBase  with SignUpValidator{

  final _feedBackController = BehaviorSubject<String>();
  final _emailController = BehaviorSubject<String>();
  final _feedbackStateController = BehaviorSubject<LoginState>();
  final _loginSuccessController = BehaviorSubject<bool>();
  final _showDialogInvalidEmailController = BehaviorSubject<bool>();
  final _loginExceptionController = BehaviorSubject<ExceptionStrings>();

  String userEmail;

  Stream<String> get outFeedback => _feedBackController.stream;
  Stream<String> get outEmail => _emailController.stream.transform(validateEmail);
  Stream<LoginState> get outFeedbackState => _feedbackStateController.stream;
  Stream<bool> get outLoginSuccess => _loginSuccessController.stream;
  Stream<bool> get outDialogInvalidEmail => _showDialogInvalidEmailController.stream;
  Stream<ExceptionStrings> get outLoginException => _loginExceptionController.stream;

  Function(String) get changeEmail => _emailController.sink.add;

  void changedText(String text){
    if (text.trim().length > 10){
      _feedBackController.sink.add(text);
      enableButton();
    } else {
      //disableButton();
      _feedBackController.sink.addError(ExceptionStrings.INSUFFICIENT_CHARACTERS);
    }
  }


  Future<Null> getUserEmail() async{
    ParseUser user = await ParseUser.currentUser();
    if (user != null) {
      userEmail = "";
      if (userEmail != null) changeEmail(userEmail);
      return;
    }
    else return;
  }

  bool checkEmail(String email){
     bool emailValid = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
      if (emailValid) return true;
      else return false;
  }

  void sendFeedback(bool forceSend) async{

    if (_feedBackController.value == null){
      _loginExceptionController.sink.add(ExceptionStrings.INSUFFICIENT_CHARACTERS_FEEDBACK);
      return;
    }
    
    if (!checkEmail(_emailController.value) && !forceSend){
      _showDialogInvalidEmailController.sink.add(true);
      // _loginExceptionController.sink.add("Você digitou um email inválido! Se você não precisar de resposta pode remover o email inserido.");
        return;
    }

    
    loadingButton();

    bool hasInternet = await hasInternetConnection(false);

    if (!hasInternet){
      _loginExceptionController.sink.add(ExceptionStrings.NO_INTERNET_CONNECTION);
      return;
    }

    ParseUser user = await ParseUser.currentUser();
    ParseACL acl = ParseACL();
    acl.setPublicReadAccess(allowed: false);
    acl.setPublicWriteAccess(allowed: false);

    ParseObject feedback = ParseObject("Feedback");

    feedback.set("message",_feedBackController.value);
    if (user != null) feedback.set("user",user);
    if (_emailController.value.trim().length > 0) feedback.set("userEmail",_emailController.value);
    feedback.setACL(acl);
    ParseResponse response = await feedback.save();

    if (response.success) sendedButton();
    else _loginExceptionController.sink.add(ExceptionStrings.FAILED);

  }
 

  void enableButton(){
    _feedbackStateController.sink.add(LoginState.IDLE);
  }
  void disableButton(){
    _feedbackStateController.sink.add(LoginState.TEMPORARY_DISABLED);
  }
  void loadingButton(){
    _feedbackStateController.sink.add(LoginState.LOADING);
  }
  void sendedButton(){
    _feedbackStateController.sink.add(LoginState.LOGIN_SUCCESSFULLY);
  }
  void sendSuccessFeedback(){
    _loginSuccessController.sink.add(true);
  }

  @override
  void dispose(){
    _showDialogInvalidEmailController.close();
    _feedBackController.close();
    _emailController.close();
    _feedbackStateController.close();
    _loginSuccessController.close();
    _loginExceptionController.close();
   
    super.dispose();
  }
}
