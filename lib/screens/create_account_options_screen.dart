import 'dart:ui';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:upnews/app_theme.dart';
import 'package:upnews/blocs/login_bloc.dart';
import 'package:upnews/blocs/user_bloc.dart';
import 'package:upnews/generated/i18n.dart';
import 'package:upnews/up_news_icons_icons.dart';
import 'package:upnews/widgets/login_widgets/login_button.dart';

import '../utils.dart';

class CreateAccountOptionsScreen extends StatefulWidget {

  @override
  _CreateAccountOptionsScreen createState() => _CreateAccountOptionsScreen();
}

class _CreateAccountOptionsScreen extends State<CreateAccountOptionsScreen> {

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
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 600),
            child: ListView(
              padding: EdgeInsets.all(12),
              children: <Widget>[
                _buildLoginOptions()
              ],
            ),
          ),
        ),
      ),
    );
  }

 

  Widget _buildLoginOptions(){
    return Column(
      children: <Widget>[
        Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            icon: Icon(Icons.close, color: primaryText, size: 35),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
        ),
                
        _buildLogin(context),
        _buildOtherOptions(context),
        SizedBox(height: 25),
      ],
    );
  }

  Widget _buildLogin(BuildContext context){
    return Column(
      children: <Widget>[
      SizedBox(height: 80),
      Text(S.of(context).create_account,
        style: TextStyle(
          color: primaryText,
          fontWeight: FontWeight.bold,
          fontSize: 38
        ),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 6),
      Text(S.of(context).lets_create_your_account_now,
        style: TextStyle(
          color: secondaryText,
          fontWeight: FontWeight.bold,
          fontSize: 18
        ),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 36),
      LoginButton(
        text: S.of(context).use_email_and_password,
        gradient: gradientAccent,
        splashColor: splashColor,
        textColor: primaryText,
        function: (){
          Navigator.pushNamed(context, "/createAccount");
        },
        successFunction: null,
        shadowColor: secondaryAccent,
        loginState: null,
        icon: Icon(UpNewsIcons.ic_email,color: primaryText,size: 20),

      ),
      
      ],
    );
  }

  Widget _buildOtherOptions(BuildContext context){
    return Column(
      children: <Widget>[
        SizedBox(height: 36),
        Row(
          children: <Widget>[
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal:12),
                decoration: BoxDecoration(
                  color: secondaryText,
                  borderRadius: BorderRadius.circular(99)
                ),
              ),
            ),
            Text(S.of(context).or,
              style: TextStyle(
                color: secondaryText,
                fontWeight: FontWeight.w500,
                fontSize: 16
              ),
            ),
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal:12),
                decoration: BoxDecoration(
                  color: secondaryText,
                  borderRadius: BorderRadius.circular(99)
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 36),
        LoginButton(
          text: S.of(context).sign_in_with_facebook,
          color: Color(0xff1877F2),
          splashColor: splashColor,
          textColor: primaryText,
          function: _loginBloc.signInWithFacebook,
          loginState: _loginBloc.outLoginFacebookState,
          successFunction: _loginBloc.sendSuccessLogin,
          icon: Icon(UpNewsIcons.ic_facebook,color: Colors.white,size: 20,),
          shadowColor: Colors.transparent,
        ),
        SizedBox(height: 36),
       /* LoginButton(
          text: S.of(context).sign_in_with_google,
          color: Colors.white,
          splashColor: splashColor,
          textColor: secondaryText,
          loginState: _loginBloc.outLoginGoogleState,
          function: _loginBloc.signInWithGoogle,
          successFunction: _loginBloc.sendSuccessLogin,
          icon: Image.asset("assets/images/ic_google.png",height: 21,),
          shadowColor: Colors.transparent,
        ), */
      ],
    );
  }

}


