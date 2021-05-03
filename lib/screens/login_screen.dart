import 'dart:ui';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:upnews/app_theme.dart';
import 'package:upnews/blocs/login_bloc.dart';
import 'package:upnews/blocs/user_bloc.dart';
import 'package:upnews/generated/i18n.dart';
import 'package:upnews/up_news_icons_icons.dart';
import 'package:upnews/widgets/input_text_field.dart';
import 'package:upnews/widgets/login_widgets/login_button.dart';

import '../utils.dart';

class LoginScreen extends StatefulWidget {

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final LoginBloc _loginBloc = LoginBloc();
  final UserBloc _userBloc = BlocProvider.getBloc();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  @override
  void initState() {
    _loginBloc.setUserBloc(_userBloc);      
    _loginBloc.outLoginSuccess.listen((loginSuccessfully){
      if (loginSuccessfully) Navigator.popUntil(context,(route) => route.settings.name == "/");
    
    });

    _loginBloc.outLoginException.listen((code){
      String message;
      switch (code){
        case ExceptionStrings.NO_INTERNET_CONNECTION:
          message = S.of(context).no_internet;
          break;
        case ExceptionStrings.WRONG_EMAIL_OR_PASSWORD:
          message = S.of(context).wrong_email_or_password;
          break;
        case ExceptionStrings.NO_INTERNET_CONNECTION:
          message = S.of(context).no_internet;
          break;
        case ExceptionStrings.FAILED:
          message = S.of(context).login_fail;
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
            padding: EdgeInsets.all(12),
            children: <Widget>[
              
              Text("Newster",
                style: TextStyle(
                  color: primaryText,
                  fontWeight: FontWeight.bold,
                  fontSize: 35
                ),
              ),
              SizedBox(height: 12),
              Text(S.of(context).save_news_and_much_more,
                style: TextStyle(
                  color: secondaryText,
                  fontWeight: FontWeight.w500,
                  fontSize: 16
                ),
              ),
              SizedBox(height: 36),
              _buildLogin(context),
              SizedBox(height: 25),
              _buildCreateAnAccountOffer(),
              _preloadFlareActor(),
              
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogin(BuildContext context){
    return Column(
      children: <Widget>[
        InputTextField(hint: S.of(context).email,
          obscure: false,
          changed:_loginBloc.changeEmail,
          errorStream:_loginBloc.outEmail,
          inputFormatter:  WhitelistingTextInputFormatter(RegExp('[A-Za-z0-9@.]')),
          keyboardType: TextInputType.emailAddress,
         ),
        InputTextField(hint: S.of(context).password,
          obscure: true,
          changed:_loginBloc.changePassword,
          errorStream:_loginBloc.outPassword,
          inputFormatter:  WhitelistingTextInputFormatter(RegExp('[A-Za-z0-9@#]'))
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: FlatButton(
            child: Text(S.of(context).forgot_password,
              style: TextStyle(
                color: secondaryAccent,
              ),
            ),
            onPressed: (){
              Navigator.pushNamed(context, "/recoveryPassword");
            },
          ),
        ),
        SizedBox(height: 24),
        LoginButton(
          text: S.of(context).login,
          gradient: gradientAccent,
          splashColor: splashColor,
          textColor: primaryText,
          function: _loginBloc.signIn,
          successFunction: _loginBloc.sendSuccessLogin,
          shadowColor: secondaryAccent,
          loginState: _loginBloc.outLoginState,

        )
      ],
    );
  }

  Widget _buildCreateAnAccountOffer(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(S.of(context).dont_have_an_account,
          style: TextStyle(
            color: secondaryText,
            fontWeight: FontWeight.bold
          ),
        ),
        FlatButton(
          padding: const EdgeInsets.symmetric(vertical: 0,horizontal:6),
          child: Text(S.of(context).create_account,
            style: TextStyle(
              color: secondaryAccent,
              fontWeight: FontWeight.bold
            ),
          ),
          onPressed: (){
            Navigator.pushNamed(context, "/createAccount");
          },
        ),
      ],
    );
  }
  
  Widget _preloadFlareActor(){
    return Row(
      children: <Widget>[
        Container(height:0,width:0,child: FlareActor("assets/animations/check_animation.flr",animation: "checked")),
        Container(height:0,width:0,child: FlareActor("assets/animations/check_animation.flr",animation: "checked_black")),
        Container(height:0,width:0,child: FlareActor("assets/animations/check_animation_filled.flr",animation: "checked_filled")),
      ],
    );
  }

}


