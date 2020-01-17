import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:upnews/app_theme.dart';

import '../../utils.dart';

class LoginButton extends StatefulWidget {
  final String text;
  final Widget icon;
  final Color textColor,color,splashColor;
  final Stream<LoginState> loginState;
  final LinearGradient gradient;
  final Function function;
  final Function successFunction;
  final Color shadowColor;
  LoginButton({this.text,this.textColor,this.color,this.gradient,this.function, this.successFunction, this.splashColor,this.icon,this.loginState, this.shadowColor});
  @override
  _LoginButtonState createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
  @override
  Widget build(BuildContext context) {
    LinearGradient gradient = widget.gradient;
    if (widget.gradient == null) gradient = LinearGradient( colors: [widget.color,widget.color]  );
    double height = 50;
    double width;
    return StreamBuilder<LoginState>(
      stream: widget.loginState,
      initialData: LoginState.IDLE,
      builder: (context, snapshot) {
        bool isLoading = false;
        Function function = widget.function;

        if (snapshot.data == LoginState.LOADING) {
          isLoading = true;
          function = null;
        }
        else if (snapshot.data == LoginState.TEMPORARY_DISABLED) function = null;
        
          width = isLoading || snapshot.data == LoginState.LOGIN_SUCCESSFULLY ? 50 : MediaQuery.of(context).size.width * 0.8;
          return AnimatedContainer(
            width: width,
            height: height,
            duration: Duration(milliseconds: 300),
            child: Material(
              shadowColor: widget.shadowColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999)
                ),
              elevation: 6.0,
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: gradient
                ),
                child: Material(
                  type: MaterialType.transparency,
                  elevation: 6.0,
                  color: Colors.transparent,
                  shadowColor: widget.shadowColor,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    splashColor: widget.splashColor,
                    onTap: function,
                    child: Row(
                      children: <Widget>[
                        widget.icon != null && snapshot.data != LoginState.LOADING && snapshot.data != LoginState.LOGIN_SUCCESSFULLY ?
                        Container(
                          height: 20,
                          margin: EdgeInsets.symmetric(horizontal: 35),
                          alignment: Alignment.centerLeft,
                          child: widget.icon,
                        ) : Container(),
                        Expanded(
                          child: isLoading  || snapshot.data == LoginState.LOGIN_SUCCESSFULLY ? Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.all(12),
                            child: isLoading ? Container(
                              height: 25,
                              width:25,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(widget.textColor),
                                strokeWidth: 1.0,
                              )  
                            ) : Container(
                              height: 50,
                              width: 50,
                              child: FlareActor("assets/animations/check_animation.flr", 
                                alignment:Alignment.center,
                                fit:BoxFit.contain, 
                                animation: widget.textColor == primaryText ? "checked" : "checked_black",
                                callback: (s){
                                  widget.successFunction();
                                },
                              ),
                            )
                          )
                          : Text( widget.text,
                              style: TextStyle(
                                color: widget.textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              textAlign: widget.icon == null ? TextAlign.center : TextAlign.left,
                              maxLines: 1,
                          )  
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        
      }
    );
  }

}