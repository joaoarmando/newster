
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:upnews/app_theme.dart';
import 'package:upnews/blocs/recovery_password_bloc.dart';
import 'package:upnews/generated/i18n.dart';
import 'package:upnews/utils.dart';
import 'package:upnews/widgets/input_text_field.dart';
import 'package:upnews/widgets/login_widgets/login_button.dart';

class RecoveryPasswordScreen extends StatefulWidget {
  
  @override
  _RecoveryPasswordScreenState createState() => _RecoveryPasswordScreenState();
}

class _RecoveryPasswordScreenState extends State<RecoveryPasswordScreen> {
  RecoveryPasswordBloc _bloc = RecoveryPasswordBloc();

  @override
  void initState() {
    _bloc.outRecoveryPasswordState.listen((state){
      if (state == LoginState.LOGIN_SUCCESSFULLY){

        Future.delayed(Duration(seconds: 8)).then((_){
          if (context != null) Navigator.pop(context);
        });
       
      }
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    
    return Theme(
      data: ThemeData(
        primaryColor: secondaryAccent,
        cursorColor: secondaryAccent,
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
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 55,
                child: Row(
                  children: <Widget>[
                    Align(
                      alignment:Alignment.centerLeft,
                      child: IconButton(
                        icon: Icon(
                          Icons.close,
                          color: primaryText,
                          size: 35,
                        ),
                        onPressed: (){
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(width:12),
                    Text(
                      S.of(context).recover_password,
                      style: TextStyle(color: primaryText, fontSize: 21,fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: InputTextField(hint: S.of(context).email,
                  obscure: false,
                  changed:(s){
                     _bloc.changeEmail(s);
                    _bloc.verifyEmail();
                  },
                  errorStream:_bloc.outEmail,
                  inputFormatter:  WhitelistingTextInputFormatter(RegExp('[A-Za-z0-9@.]')),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(S.of(context).type_your_email_above_to_recover_password,
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 14,
                  ),
                ),
              ),
              SizedBox(height: 50),
              StreamBuilder<LoginState>(
                stream: _bloc.outRecoveryPasswordState,
                builder: (context, snapshot) {
                  return Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        snapshot.data == LoginState.LOGIN_SUCCESSFULLY ? Container() : signUpButton(),
                        snapshot.data == LoginState.LOGIN_SUCCESSFULLY ? Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  height: 150,
                                  width: 150,
                                  child: FlareActor("assets/animations/check_animation_filled.flr",animation:"check_filled"),
                                ),
                                SizedBox(height: 12),
                                Text(S.of(context).email_sended,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 21,
                                    color: primaryText
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(S.of(context).you_will_receive_an_email_password_request,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: secondaryText
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ) : Container()

                      ],
                    ),
                  );
                }
              )

              
            ],
          ),
        ),
      ),
    );
  }


  Widget signUpButton(){
    return StreamBuilder<bool>(
      stream: _bloc.outSubmitValid,
      builder: (context, snapshot) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            LoginButton(
              text: S.of(context).login,
              gradient: gradientAccent,
              splashColor: splashColor,
              textColor: primaryText,
              function: (){
                  _bloc.sendPasswordEmail();
                FocusScope.of(context).unfocus();
              },
              successFunction: (){},
              shadowColor: secondaryAccent,
              loginState: _bloc.outRecoveryPasswordState
            ),
            
            StreamBuilder<ExceptionStrings>(
              stream: _bloc.outSendedBefore,
              builder: (context, snapshot) {
                String errorMessage = "";
                if (snapshot.data != null){
                  errorMessage = S.of(context).email_already_sended;
                }
                return Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.all(12),
                  child: Text(errorMessage,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }
            )
          ],
        );
      }
    );
  }
}