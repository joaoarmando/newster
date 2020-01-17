import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:upnews/app_theme.dart';
import 'package:upnews/blocs/user_bloc.dart';
import 'package:upnews/screens/create_account_options_screen.dart';
import 'package:upnews/screens/create_account_screen.dart';
import 'package:upnews/screens/feedback_screen.dart';
import 'package:upnews/screens/home_screen.dart';
import 'package:upnews/screens/login_screen.dart';
import 'package:upnews/screens/my_account_screen.dart';
import 'package:upnews/screens/recovery_password_screen.dart';
import 'package:upnews/screens/saved_news_screen.dart';
import 'package:upnews/screens/settings_screen.dart';
import 'package:upnews/screens/upload_picture_screen.dart';
import 'package:upnews/utils.dart';

import 'generated/i18n.dart';


void main() {
 // Set `enableInDevMode` to true to see reports while in debug mode
  // This is only to be used for confirming that reports are being
  // submitted as expected. It is not intended to be used for everyday
  // development.
  Crashlytics.instance.enableInDevMode = true;
  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
   runApp(MyApp());
}



class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final UserBloc _userBloc = UserBloc();
  final FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  Widget build(BuildContext context) {


    return BlocProvider(
      blocs: [
         Bloc((i) => _userBloc),
      ],
      child: FutureBuilder(
        future: initializeParseServer(),
        builder: (context,snapshot){
          if (snapshot.connectionState == ConnectionState.done){
            return MaterialApp(
                title: 'Newster',
                localizationsDelegates: [S.delegate, GlobalMaterialLocalizations.delegate],
                supportedLocales: S.delegate.supportedLocales,
                //localeResolutionCallback: S.delegate.resolution(fallback: Locale('en','')),
                theme: ThemeData(
                  primaryColor: secondaryAccent,
                  cursorColor: secondaryAccent,
                  accentColor: backgroundColor,
                  backgroundColor: backgroundColor,
                  inputDecorationTheme: InputDecorationTheme(
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xff343651),width: 2)),
                    labelStyle: TextStyle(
                        color: secondaryText,
                        fontWeight: FontWeight.w500,
                        fontSize: 16
                    ),
                  ),
                  fontFamily: "Montserrat",
                ),
                navigatorObservers: [
                  FirebaseAnalyticsObserver(analytics: analytics),
                ],
                routes: {
                  "/": (context) => HomeScreen(),
                  //"/": (context) => HomeScreen(),
                  "/createAccountOptions": (context) => CreateAccountOptionsScreen(),
                  "/loginScreen": (context) => LoginScreen(),
                  "/createAccount": (context) => CreateAccountScreen(),
                  "/uploadPicture": (context) => CompleteAccountCreation(),
                  "/sendFeedback": (context) => SendFeedbackScreen(),
                  "/myAccount": (context) => MyAccountScreen(),
                  "/recoveryPassword": (context) => RecoveryPasswordScreen(),
                  "/settingsScreen": (context) => SettingsScreen(),
                  "/savedNewsScreen": (context) => SavedNewsScreen(),
                }
            );
          }
          else return Container();
        },
      ),
    );
  }
 


  
  Future<bool> initializeParseServer() async {
    await Parse().initialize(
      "kfasBMvmrpiAh510E8Wz",
      "http://newsappbr.herokuapp.com/parse",
      autoSendSessionId: true,
    );
     _userBloc.getSharedPreferences();
     _userBloc.checkLogin();
     getSharedPreferences();

 
    return true;

  }
}
