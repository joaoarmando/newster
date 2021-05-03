import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

import 'package:upnews/validators/signup_validator.dart';

import '../utils.dart';


class RecoveryPasswordBloc extends BlocBase with SignUpValidator{

  final _emailController = BehaviorSubject<String>();
  final _recoveryPasswordStateController = BehaviorSubject<LoginState>.seeded(LoginState.IDLE);
  final _enabledButtonStateController = BehaviorSubject<bool>();
  final _emailHasSendedBefore = BehaviorSubject<ExceptionStrings>();
  List<String> sendedToThisEmails = [];


 
  Stream<String> get outEmail => _emailController.stream.transform(validateEmail);
  Stream<LoginState> get outRecoveryPasswordState => _recoveryPasswordStateController.stream;
  Stream<bool> get outSubmitValid => _enabledButtonStateController.stream;
  Stream<ExceptionStrings> get outSendedBefore => _emailHasSendedBefore.stream;


  
  

  void changeEmail(String email){
    _emailController.sink.add(email);
    verifyEmail();
  }

  void verifyEmail(){
    if (_emailController.value.length > 0) {

      int index = getIndex(_emailController.value);
      if (index == -1) {
        _enabledButtonStateController.sink.add(true);
        _emailHasSendedBefore.sink.addError(ExceptionStrings.IDLE);
      }
      else {
        _emailHasSendedBefore.sink.add(ExceptionStrings.EMAIL_ALREADY_SENDED);
        _enabledButtonStateController.sink.addError("");
      }

    }
    else {
      _enabledButtonStateController.sink.addError("");
      _emailHasSendedBefore.sink.addError(ExceptionStrings.IDLE);
    }
  }

  void sendPasswordEmail() async{
    var email = _emailController.value;
    _recoveryPasswordStateController.sink.add(LoginState.LOADING);

    ParseUser user = ParseUser("","",email);
    ParseResponse apiResponse = await user.requestPasswordReset();
    await Future.delayed(Duration(milliseconds:1500));
    if (apiResponse.success){
      sendedToThisEmails.add(email);
      _recoveryPasswordStateController.sink.add(LoginState.LOGIN_SUCCESSFULLY);
      _enabledButtonStateController.sink.addError("");
      _emailHasSendedBefore.sink.add(ExceptionStrings.IDLE);
    }else {
      _recoveryPasswordStateController.sink.add(LoginState.LOGIN_FAIL);
    } 
    


  }

  int getIndex(String email){
    for ( var i = 0; i < sendedToThisEmails.length; i++){
      if (email == sendedToThisEmails[i]) return i;
    }
    return -1;
  }
  



  @override
  void dispose(){
    _emailController.close();
    _recoveryPasswordStateController.close();
    _enabledButtonStateController.close();
    _emailHasSendedBefore.close();
    super.dispose();
  }
}
