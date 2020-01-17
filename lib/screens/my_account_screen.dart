import 'dart:async';
import 'dart:io';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:upnews/app_theme.dart';
import 'package:upnews/blocs/my_account_bloc.dart';
import 'package:upnews/blocs/user_bloc.dart';
import 'package:upnews/generated/i18n.dart';
import 'package:upnews/utils.dart';
import 'package:upnews/widgets/input_text_field.dart';
import 'package:upnews/widgets/custom_dialog.dart' as customDialog;
import 'change_password_screen.dart';

class MyAccountScreen extends StatefulWidget {

  @override
  _MyAccountScreenState createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final MyAccountBloc _myAccountBloc = MyAccountBloc();
  final UserBloc _userBloc = BlocProvider.getBloc();

  Timer timerUserName;
  Timer timerEmail;

  @override
  void initState() {

    _myAccountBloc.setUserBloc(_userBloc);
    _myAccountBloc.getUserPicture();

      _myAccountBloc.outLoginException.listen((code){
        String message;
        switch(code){
          case ExceptionStrings.CHECK_NAME:
            message = S.of(context).check_the_name;
            break;
          case ExceptionStrings.CHECK_EMAIL:
            message = S.of(context).check_the_email;
            break;
          case ExceptionStrings.EMAIL_ALREADY_USED:
            message = S.of(context).email_already_used;
            break;
          case ExceptionStrings.FAILED:
            message = S.of(context).login_fail;
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
      _myAccountBloc.outDeleteState.listen((state){
        if (state == LoginState.LOGIN_FAIL){
          Navigator.pop(context);
          _scaffoldKey.currentState.showSnackBar(
            new SnackBar(
                content:  Text(S.of(context).we_couldnt_delete_your_account_now,
                  style: TextStyle(
                    color: primaryText,
                    fontWeight: FontWeight.w500
                  ),
                ),
                backgroundColor: Colors.red
            )
          );
        }
        else if (state == LoginState.DELETED_ACCOUNT){
          Navigator.pushNamedAndRemoveUntil(context, "/", ModalRoute.withName("/"));
        }
      });

      _myAccountBloc.outSaved.listen((_){
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
              SizedBox(height: 35,),
              _buildAvatar(),
              SizedBox(height: 24),
              _buildUserInfo(),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.close,color: primaryText,size: 35,),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        SizedBox(width: 12),
        Text(S.of(context).edit_profile,
          style: TextStyle(
            color: primaryText,
            fontWeight: FontWeight.w500,
            fontSize: 21
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: StreamBuilder<LoginState>(
              stream: _myAccountBloc.outEditState,
              builder: (context, snapshot) {
                print("Snapshot: ${snapshot.data}");
                if (snapshot.data == LoginState.LOADING || snapshot.data == LoginState.LOGIN_SUCCESSFULLY){
                  return Container(
                    alignment: Alignment.center,
                    height: 25,
                    width: 25,
                    margin:EdgeInsets.only(right:6),
                    child: snapshot.data == LoginState.LOADING ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(secondaryAccent),
                      strokeWidth: 1,
                    ) : FlareActor("assets/animations/check_animation.flr", 
                          alignment:Alignment.center,
                          fit:BoxFit.contain, 
                          animation: "checked" ,
                          callback: (s){
                            _myAccountBloc.sendSuccessLogin();
                          },
                        ),
                  );
                }
                else
                  return IconButton(
                    icon: Icon(Icons.check,color: primaryText,size: 35,),
                    onPressed: _myAccountBloc.saveChanges,
                  );
              }
            ),
          ),
        )
      ],
    );
  }

  Widget _buildAvatar(){
    return Container(
      alignment: Alignment.center,
      child: Stack(
        children: <Widget>[
           ClipRRect(
             borderRadius: BorderRadius.circular(999),
             child: StreamBuilder<File>(
                  stream: _myAccountBloc.outPicture,
                  builder: (context, snapshot){

                    if (snapshot.data == null) return Icon(Icons.account_circle, color: secondaryText, size: 110);

                    else
                      return Image.file(snapshot.data,height: 110,width: 110,fit: BoxFit.cover);

 
                    
                  },
                ),
           ),
           Positioned(
             bottom: 0,
             right: 0,
             child: Container(
               height: 40,
               width: 40,
               decoration: BoxDecoration(
                 shape: BoxShape.circle,
                 gradient: gradientAccent
               ),
               child: Icon(Icons.edit,color: primaryText, size: 30),
             ),
           ),
           Positioned(
             bottom: 0,
             right: 0,
             child: Material(
               type: MaterialType.transparency,
               child: Container(
                 height: 40,
                 width: 40,
                 decoration: BoxDecoration(
                   shape: BoxShape.circle,
                 ),
                 child: InkWell(
                   onTap:getImage,
                   splashColor: splashColor,
                   borderRadius: BorderRadius.circular(999)
                 ),
               ),
             ),
           ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(){
    return Column(
      children: <Widget>[
        InputTextField(hint: S.of(context).name,
            obscure: false,
            changed:(s){
              if (timerUserName != null) timerUserName.cancel();
              timerUserName = new Timer(Duration(milliseconds: 500), () => _myAccountBloc.changeName(s));       
            },
            initialValue: _userBloc.userName,
            errorStream:_myAccountBloc.outName,
            inputFormatter: BlacklistingTextInputFormatter.singleLineFormatter,
           ),
          InputTextField(
            hint: S.of(context).email,
            errorStream: _myAccountBloc.outEmail,
            changed: (s){
              if (timerEmail != null) timerEmail.cancel();
              timerEmail = new Timer(Duration(milliseconds: 500), () => _myAccountBloc.changeEmail(s));
            },
            initialValue: _userBloc.userEmail,
            obscure: false,
            keyboardType: TextInputType.emailAddress,
            inputFormatter:  WhitelistingTextInputFormatter(RegExp('[A-Za-z0-9@.]'))
          ),
          _buildChangePasswordButton(),
          SizedBox(height: 20),
          FlatButton(
            child: Text(S.of(context).logout,
              style: TextStyle(
                color: Colors.red,
              ),
            ),
            onPressed: logout,
          ),
          SizedBox(height: 100),
          FlatButton(
            child: Text(S.of(context).delete_account,
              style: TextStyle(
                color: secondaryText,
              ),
            ),
            onPressed: deleteAccount,
          )
      ],
    );
  }

  Widget _buildChangePasswordButton(){
    return Container(
      margin: EdgeInsets.only(top: 12),
      constraints: BoxConstraints(
        minWidth: 150,
        maxWidth:250
      ),
      height: 55,
      decoration: BoxDecoration(
        color: secondaryBackgroundColor,
        borderRadius: BorderRadius.circular(5)
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => Navigator.push(context, CupertinoPageRoute(builder: (context) => ChangePasswordScreen())),
          borderRadius: BorderRadius.circular(5),
          child: IgnorePointer(
            ignoring: true,
            child: TextFormField(
              initialValue: S.of(context).change_password,
              decoration: InputDecoration(
                border: OutlineInputBorder( borderRadius: BorderRadius.circular(5)),
              ),
              style: TextStyle(
                color: primaryText,
                fontWeight: FontWeight.w500,
                fontSize: 16
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  void deleteAccount() async{

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
                    child: Text(S.of(context).delete_account,
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(S.of(context).are_you_sure_about_delete_your_account,
                    style: TextStyle(
                      color: primaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.w500
                    ),
                    textAlign: TextAlign.left,
                  ),
                  StreamBuilder<LoginState>(
                    stream: _myAccountBloc.outDeleteState,
                    builder: (context, snapshot) {

                      if (snapshot.data == LoginState.LOADING || snapshot.data == LoginState.LOGIN_SUCCESSFULLY) 
                            return Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                height: 25,
                                width: 25,
                                margin: EdgeInsets.only(top:12,right:12,bottom: 12),
                                child: snapshot.data == LoginState.LOADING ? 
                                CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(secondaryAccent),strokeWidth: 1)
                                : FlareActor("assets/animations/check_animation.flr", 
                                    alignment:Alignment.center,
                                    fit:BoxFit.contain, 
                                    animation: "checked" ,
                                    callback: (s){
                                      _myAccountBloc.deletedSuccess();
                                    },
                                  ),
                              ),
                            );
                      else      
                        return Row(
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
                              },
                            ),
                            FlatButton(
                              child: Text(S.of(context).delete,
                                style: TextStyle(
                                  color: secondaryAccent,
                                  fontSize: 18
                                ),
                              ),
                              onPressed: () async{
                                //Navigator.pop(context);
                              _myAccountBloc.deleteAccount();
                              },
                            ),
                          ],
                        );
                    }
                  )
                ],
              ),
            ),

          );
        },
      );

  } 
  
  void getImage() async{
    try{
      File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
      imageSelected(imageFile);
    }catch (ex){

    }
    
  }

  void imageSelected(File image) async{
    if (image != null){
     File croppedImage = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatio: CropAspectRatio(
          ratioX: 1.0,
          ratioY: 1.0
        ),
        maxWidth: 250,
        maxHeight: 250,
        androidUiSettings: AndroidUiSettings(
          toolbarColor: backgroundColor,
          toolbarTitle: S.of(context).edit_picture,
          statusBarColor: backgroundColor,
          toolbarWidgetColor: primaryText,
          activeControlsWidgetColor: secondaryAccent,
          backgroundColor: backgroundColor,
          activeWidgetColor: secondaryAccent,
        )
       );
       if (croppedImage == null) return;

       _myAccountBloc.setNewPicture(croppedImage);
      
    }
  }

  void logout() async{

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
                    child: Text(S.of(context).logout,
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(S.of(context).are_you_sure_about_logout,
                    style: TextStyle(
                      color: primaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.w500
                    ),
                    textAlign: TextAlign.left,
                  ),
                  StreamBuilder<LoginState>(
                    stream: _myAccountBloc.outLogoutState,
                    builder: (context, snapshot) {

                      if (snapshot.data == LoginState.LOADING || snapshot.data == LoginState.LOGIN_SUCCESSFULLY) 
                            return Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                height: 25,
                                width: 25,
                                margin: EdgeInsets.only(top:12,right:12,bottom: 12),
                                child: snapshot.data == LoginState.LOADING ? 
                                CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(secondaryAccent),strokeWidth: 1)
                                : FlareActor("assets/animations/check_animation.flr", 
                                    alignment:Alignment.center,
                                    fit:BoxFit.contain, 
                                    animation: "checked" ,
                                    callback: (s){
                                      _myAccountBloc.deletedSuccess();
                                    },
                                  ),
                              ),
                            );
                      else      
                        return Row(
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
                              },
                            ),
                            FlatButton(
                              child: Text(S.of(context).logout,
                                style: TextStyle(
                                  color: secondaryAccent,
                                  fontSize: 18
                                ),
                              ),
                              onPressed: () async{
                              _myAccountBloc.logout();
                              },
                            ),
                          ],
                        );
                    }
                  )
                ],
              ),
            ),

          );
        },
      );

  } 
  
}