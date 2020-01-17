import 'dart:async';
import 'dart:ui';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:upnews/app_theme.dart';
import 'package:upnews/blocs/create_account_bloc.dart';
import 'package:upnews/blocs/user_bloc.dart';
import 'package:upnews/generated/i18n.dart';
import 'package:upnews/widgets/input_text_field.dart';
import 'package:upnews/widgets/login_widgets/login_button.dart';

import '../utils.dart';

class CreateAccountScreen extends StatefulWidget {

  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {

  final CreateAccountBloc _createAccountBloc = CreateAccountBloc();
  final UserBloc _userBloc = BlocProvider.getBloc();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Timer timerUserName;
  Timer timerEmail;
  Timer timerPassword;
  Timer timerSecondaryPassword;
  bool showingOptions = true;

  


  @override
  void initState() {
    _createAccountBloc.setUserBloc(_userBloc);
    _createAccountBloc.outLoginSuccess.listen((loginSuccessfully){
      
      if (loginSuccessfully) Navigator.pushNamedAndRemoveUntil(
          context,"/uploadPicture", ModalRoute.withName("/")
      );
    
    });

    _createAccountBloc.outLoginException.listen((code){
      String message = "";
      switch (code){

        case ExceptionStrings.DIFFERENT_PASSWORDS:
          message = S.of(context).different_passwords;
          break;
        case ExceptionStrings.EMAIL_ALREADY_USED:
          message = S.of(context).email_already_used;
          break;
        case ExceptionStrings.FAILED:
          message = S.of(context).login_fail;
          break;
        case ExceptionStrings.CANCELED:
          message = S.of(context).login_canceled;
          break;
        default:
          break;
      }
      if (message == null) return;
      _scaffoldKey.currentState.showSnackBar(
       new SnackBar(
          content:  Text(message,
            style: TextStyle(
              color: primaryText,
              fontWeight: FontWeight.w500
            ),
          ),
          backgroundColor: Colors.red
       )
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
   
    return Theme(
      data: Theme.of(context),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: ListView(
            children: <Widget>[
               Row(
                 crossAxisAlignment: CrossAxisAlignment.center,
                 children: <Widget>[
                   SizedBox(width: 12,), // padding left
                   Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(Icons.close, color: primaryText, size: 35),
                      onPressed: (){
                        Navigator.pop(context);
                      },
                    ),
                  ),
                   Align(
                    alignment: Alignment.centerLeft,
                    child: Text(S.of(context).create_account,
                      style: TextStyle(
                        color: primaryText,
                        fontWeight: FontWeight.bold,
                        fontSize: 21
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: 12,), // padding right
                 ],
               ),
               _buildCreateAccount(),
               
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateAccount(){
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: <Widget>[

          InputTextField(hint: S.of(context).name,
            obscure: false,
            changed:(s){
              if (timerUserName != null) timerUserName.cancel();
              timerUserName = new Timer(Duration(milliseconds: 500), () => _createAccountBloc.changeName(s));       
            },
            errorStream:_createAccountBloc.outName,
            inputFormatter: BlacklistingTextInputFormatter.singleLineFormatter,
           ),
          InputTextField(
            hint: S.of(context).email,
            errorStream: _createAccountBloc.outEmail,
            changed: (s){
              if (timerEmail != null) timerEmail.cancel();
              timerEmail = new Timer(Duration(milliseconds: 500), () => _createAccountBloc.changeEmail(s));
            },
            obscure: false,
            keyboardType: TextInputType.emailAddress,
            inputFormatter:  WhitelistingTextInputFormatter(RegExp('[A-Za-z0-9@.]'))
          ),
          InputTextField(
            hint: S.of(context).password,
            errorStream: _createAccountBloc.outPassword,
            changed: (s){
              if (timerPassword != null) timerPassword.cancel();
              timerPassword = new Timer(Duration(milliseconds: 500), () => _createAccountBloc.changePassword(s));
            },
            obscure: true,
            inputFormatter:  WhitelistingTextInputFormatter(RegExp('[A-Za-z0-9@#]'))
          ),

          InputTextField(
            hint: S.of(context).confirm_password,
            errorStream: _createAccountBloc.outSecondaryPassword,
            changed: (s){
              if (timerSecondaryPassword != null) timerSecondaryPassword.cancel();
              timerSecondaryPassword = new Timer(Duration(milliseconds: 500), () => _createAccountBloc.changeSecondaryPassword(s));
            },
            obscure: true,
            inputFormatter:  WhitelistingTextInputFormatter(RegExp('[A-Za-z0-9@#]'))
          ),

          SizedBox(height: 36),
          LoginButton(
            text: S.of(context).create_account,
            gradient: gradientAccent,
            splashColor: splashColor,
            textColor: primaryText,
            function: _createAccountBloc.signUp,
            successFunction: _createAccountBloc.sendSuccessLogin,
            shadowColor: secondaryAccent,
            loginState: _createAccountBloc.outLoginState,
          ),
        ],
      ),
    );
  }

 

}


