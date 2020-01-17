import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:upnews/blocs/change_password_bloc.dart';
import 'package:upnews/blocs/user_bloc.dart';
import 'package:upnews/generated/i18n.dart';
import 'package:upnews/widgets/input_text_field.dart';
import 'package:upnews/widgets/login_widgets/login_button.dart';
import 'package:upnews/utils.dart';

import '../app_theme.dart';


class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {

  final ChangePasswordBloc _changePasswordBloc = ChangePasswordBloc();
  final UserBloc _userBloc = BlocProvider.getBloc();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Timer timerPassword, timerSecodnaryPassword;
  
  @override
  void initState() {

    _changePasswordBloc.setUserBloc(_userBloc);

    _changePasswordBloc.outLoginException.listen((code){
      String message;
      if (code == ExceptionStrings.DIFFERENT_PASSWORDS)
          message = S.of(context).different_passwords;
      else if (code == ExceptionStrings.PASSWORD_MUST_BE_LEAST_8)
        message = S.of(context).password_length;
      else if (code == ExceptionStrings.NO_INTERNET_CONNECTION)
         message = S.of(context).no_internet;
      else if (code == ExceptionStrings.FAILED)
        message = S.of(context).password_change_failed;
      else return;
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

    _changePasswordBloc.outSaved.listen((_){
      Navigator.pop(context);
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
            padding: const EdgeInsets.all(12),
            children: <Widget>[
              _buildAppBar(context),
              _buildInputTexts(),
              
              

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.close,color: primaryText,size: 35,),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        SizedBox(width: 12),
        Text(S.of(context).change_password,
          style: TextStyle(
            color: primaryText,
            fontWeight: FontWeight.w500,
            fontSize: 21
          ),
        )
      ],
    );
  }
  
  Widget _buildInputTexts(){
    return Column(
      children: <Widget>[
          InputTextField(
            hint: S.of(context).password,
            errorStream: _changePasswordBloc.outPassword,
            changed: (s){
              if (timerPassword != null) timerPassword.cancel();
              timerPassword = new Timer(Duration(milliseconds: 500), () => _changePasswordBloc.changePassword(s));
            },
            obscure: true,
            keyboardType: TextInputType.visiblePassword,
            inputFormatter:  WhitelistingTextInputFormatter(RegExp('[A-Za-z0-9@#]'))
          ),

          InputTextField(
            hint: S.of(context).confirm_password,
            errorStream: _changePasswordBloc.outSecondaryPassword,
            changed: (s){
              if (timerSecodnaryPassword != null) timerSecodnaryPassword.cancel();
              timerSecodnaryPassword = new Timer(Duration(milliseconds: 500), () => _changePasswordBloc.changeSecondaryPassword(s));
            },
            obscure: true,
            keyboardType: TextInputType.visiblePassword,
            inputFormatter:  WhitelistingTextInputFormatter(RegExp('[A-Za-z0-9@#]'))
          ),

          SizedBox(height: 60),

          LoginButton(
            text: S.of(context).conclude,
            gradient: gradientAccent,
            splashColor: splashColor,
            textColor: primaryText,
            function: _changePasswordBloc.saveChanges,
            successFunction: _changePasswordBloc.sendSuccessLogin,
            shadowColor: secondaryAccent,
            loginState: _changePasswordBloc.outChangePasswordState
          ),
      ],
    );
  }

  void changePassword(){
   // _myAccountBloc.saveChanges();
  }

 
}