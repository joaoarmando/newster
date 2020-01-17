import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:upnews/app_theme.dart';
import 'package:upnews/blocs/send_feedback_bloc.dart';
import 'package:upnews/generated/i18n.dart';
import 'package:upnews/utils.dart';
import 'package:upnews/widgets/input_text_field.dart';
import 'package:upnews/widgets/loading_widget.dart';
import 'package:upnews/widgets/login_widgets/error_text.dart';
import 'package:upnews/widgets/login_widgets/login_button.dart';
import 'package:upnews/widgets/custom_dialog.dart' as customDialog;

class SendFeedbackScreen extends StatefulWidget {

  @override
  _SendFeedbackScreenState createState() => _SendFeedbackScreenState();
}

class _SendFeedbackScreenState extends State<SendFeedbackScreen> {
  final focusNode = new FocusNode();
  final emailFocusNode = new FocusNode();

  SendFeedbackBloc _sendFeedbackBloc = SendFeedbackBloc();
  Future<Null> getUserEmail;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  @override
  void initState() {
    getUserEmail = _sendFeedbackBloc.getUserEmail();
    _sendFeedbackBloc.outLoginSuccess.listen((_){
      Navigator.pop(context);
    });

    _sendFeedbackBloc.outDialogInvalidEmail.listen((_){
      showDialogInvalidEmail(context);
    });

    _sendFeedbackBloc.outLoginException.listen((code){
      String message;

      switch(code){
        case ExceptionStrings.INSUFFICIENT_CHARACTERS:
          message = S.of(context).insufficient_characters_feedback;
          break;
        case ExceptionStrings.INSUFFICIENT_CHARACTERS_FEEDBACK:
          message = S.of(context).insufficient_characters_feedback_description;
          break;
          case ExceptionStrings.NO_INTERNET_CONNECTION:
          message = S.of(context).no_internet;
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

     /*Future.delayed(Duration(milliseconds: 300)).then((a){
       showDialogInvalidEmail(context);
    });  */
   

    return Theme(
      data: Theme.of(context),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: FutureBuilder(
            future: getUserEmail,
            builder: (context,snapshot){
              if (snapshot.connectionState != ConnectionState.done)
                return LoadingWidget();
              else
                return SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      _buildAppBar(context),
                      SizedBox(height: 24),
                      _buildFeedbackInput(),
                      _buildEmailContainer()
                    // _buildFeedbackInput()
                    ],
                  ),
                );   
            },
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
        Text(S.of(context).send_feedback,
          style: TextStyle(
            color: primaryText,
            fontSize: 21,
            fontWeight: FontWeight.w500
          ),
        )
      ],
    );
  }

  Widget _buildFeedbackInput(){
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:12),
      child: Stack(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
            ),
            child: TextFormField(
              focusNode: focusNode,
              style: TextStyle(
                color: primaryText,
                fontSize: 18,
              ),
              maxLines: 7,
              maxLength: 1000,
              onChanged: _sendFeedbackBloc.changedText,
               decoration: InputDecoration(
                  labelText: S.of(context).send_feedback,
                  border: OutlineInputBorder( borderRadius: BorderRadius.circular(5)),
                  fillColor: secondaryBackgroundColor,
                  filled: true
                ),
            ),
          ),
          Container(margin: EdgeInsets.only(top:200),child: ErrorText(_sendFeedbackBloc.outFeedback))
        ],
      ),
    );
  }

  Widget _buildEmailContainer(){
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(S.of(context).having_problems,
              style: TextStyle(
                color: primaryText,
                fontSize: 18,
                fontWeight: FontWeight.bold
              ),
              textAlign: TextAlign.left
            ),
          ),
          SizedBox(height: 6),
          Text(S.of(context).type_your_email_if_necessary,
            style: TextStyle(
              color: secondaryText,
              fontSize: 14,
              fontWeight: FontWeight.w500
            ),
            textAlign: TextAlign.left
          ),
          SizedBox(height: 6),
          InputTextField(hint: S.of(context).email,
            obscure: false,
            changed:_sendFeedbackBloc.changeEmail,
            errorStream:_sendFeedbackBloc.outEmail,
            initialValue: _sendFeedbackBloc.userEmail,
            inputFormatter:  WhitelistingTextInputFormatter(RegExp('[A-Za-z0-9@.]')),
            keyboardType: TextInputType.emailAddress,
            focusNode: emailFocusNode
          ),
          SizedBox(height:70),
          LoginButton(
            text: S.of(context).send,
            gradient: gradientAccent,
            splashColor: splashColor,
            textColor: primaryText,
            function:(){
              _sendFeedbackBloc.sendFeedback(false);
            },
            successFunction:_sendFeedbackBloc.sendSuccessFeedback,
            shadowColor: secondaryAccent,
            loginState: _sendFeedbackBloc.outFeedbackState,

          )
        ],
      ),
    );
  }

  void showDialogInvalidEmail(BuildContext context) async{

     return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return customDialog.AlertDialog(
            backgroundColor: Colors.transparent,
            contentPadding: const EdgeInsets.all(0),
            content: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                 color: secondaryBackgroundColor,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(S.of(context).invalid_email,
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(S.of(context).you_can_send_your_feedback_without_type_an_email,
                    style: TextStyle(
                      color: primaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.w500
                    ),
                    textAlign: TextAlign.left,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      FlatButton(
                        child: Text(S.of(context).cancel,
                          style: TextStyle(
                            color: primaryText,
                            fontSize: 18
                          ),
                        ),
                        onPressed: (){
                          Navigator.pop(context);
                          emailFocusNode.requestFocus();
                        },
                      ),
                      FlatButton(
                        child: Text(S.of(context).send,
                          style: TextStyle(
                            color: secondaryAccent,
                            fontSize: 18
                          ),
                        ),
                        onPressed: (){
                          Navigator.pop(context);
                          FocusScope.of(context).unfocus();
                          _sendFeedbackBloc.sendFeedback(true);
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),

          );
        },
      );

  } 

}