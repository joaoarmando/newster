import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:upnews/app_theme.dart';
import 'package:upnews/blocs/user_bloc.dart';
import 'package:upnews/screens/create_account_screen.dart';
import 'package:upnews/screens/feedback_screen.dart';
import 'package:upnews/screens/home_screen.dart';
import 'package:upnews/screens/login_screen.dart';
import 'package:upnews/screens/my_account_screen.dart';
import 'package:upnews/screens/recovery_password_screen.dart';
import 'package:upnews/screens/saved_news_screen.dart';
import 'package:upnews/screens/settings_screen.dart';
import 'package:upnews/screens/upload_picture_screen.dart';

import 'generated/i18n.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarBrightness: Brightness.dark));
  await Parse().initialize(
      "kfasBMvmrpiAh510E8Wz",
      "https://newsappbr.herokuapp.com/parse",
      autoSendSessionId: true,
    );
  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  final UserBloc _userBloc = UserBloc();
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      blocs: [
         Bloc((i) => _userBloc),
      ],
      child: MaterialApp(
          title: 'Newster',
          localizationsDelegates: [S.delegate, GlobalMaterialLocalizations.delegate],
          supportedLocales: S.delegate.supportedLocales,
          //localeResolutionCallback: S.delegate.resolution(fallback: Locale('en','')),
          theme: ThemeData(
            primaryColor: secondaryAccent,
            cursorColor: secondaryAccent,
            accentColor: backgroundColor,
            backgroundColor: backgroundColor,
            brightness: Brightness.dark,
            inputDecorationTheme: InputDecorationTheme(
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: secondaryAccent,width: 2)),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xff343651),width: 2)),
              labelStyle: TextStyle(
                  color: secondaryText,
                  fontWeight: FontWeight.w500,
                  fontSize: 16
              ),
            ),
            fontFamily: "Montserrat",
          ),
          routes: {
            "/": (context) => HomeScreen(),
            "/loginScreen": (context) => LoginScreen(),
            "/createAccount": (context) => CreateAccountScreen(),
            "/uploadPicture": (context) => CompleteAccountCreation(),
            "/sendFeedback": (context) => SendFeedbackScreen(),
            "/myAccount": (context) => MyAccountScreen(),
            "/recoveryPassword": (context) => RecoveryPasswordScreen(),
            "/settingsScreen": (context) => SettingsScreen(),
            "/savedNewsScreen": (context) => SavedNewsScreen(),
          }
      ),
    );
  }

}
