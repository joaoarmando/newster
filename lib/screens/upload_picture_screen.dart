import 'dart:io';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:upnews/app_theme.dart';
import 'package:upnews/blocs/user_bloc.dart';
import 'package:upnews/generated/i18n.dart';
enum ProfilePictureState{IDLE,LOADING,COMPLETED}
class CompleteAccountCreation extends StatefulWidget {

  @override
  _CompleteAccountCreationState createState() => _CompleteAccountCreationState();
}

class _CompleteAccountCreationState extends State<CompleteAccountCreation> {
  File userPicture;
  ProfilePictureState profilePictureState = ProfilePictureState.IDLE;
  UserBloc _userBloc = UserBloc();
  @override
  Widget build(BuildContext context) {
    LinearGradient transparentGradient = LinearGradient(colors: [Colors.transparent, Colors.transparent]);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: profilePictureState == ProfilePictureState.IDLE ? FlatButton(
                  child: Text(S.of(context).skip ,
                    style: TextStyle(
                      color: secondaryAccent,
                      fontSize: 21,
                    ),
                  ),
                  onPressed: (){
                    Navigator.pop(context);
                  },
                ) : Container(),
              ),
              SizedBox(height: 100),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: userPicture == null ? Icon(Icons.account_circle, color: secondaryText, size: 120)
                  : Stack(
                    children: <Widget>[
                     
                      Image.file(userPicture,width:120,height:120),

                       profilePictureState != ProfilePictureState.IDLE ? Container(
                        height: 120,
                        width: 120,
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: backgroundColor.withOpacity(.5)
                        ),
                        child: profilePictureState == ProfilePictureState.LOADING ?  CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(secondaryAccent),
                          strokeWidth: 2,
                        ) : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                height: 50,
                                width: 50,
                                child: FlareActor("assets/animations/check_animation.flr",animation: "checked"),
                              )
                            ],
                          ),
                      ) : Container(),
                    ],
                  ),
                )
              ),
              SizedBox(height: 12),
              Text(S.of(context).what_about_add_an_photo_of_yourself,
                style: TextStyle(
                  color: primaryText,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6),
              Text(S.of(context).only_you_will_see_your_beautiful_face,
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 36),
              InkWell(
                onTap: (){
                  if (profilePictureState == ProfilePictureState.COMPLETED) Navigator.pop(context);
                  else if (profilePictureState == ProfilePictureState.IDLE) getImage();

                },
                borderRadius: BorderRadius.circular(5),
                child: AnimatedContainer(
                  constraints: BoxConstraints(
                    minHeight: 50,
                    minWidth: 150,
                    maxWidth: 200
                  ),
                  duration: Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    gradient: profilePictureState == ProfilePictureState.COMPLETED ? gradientAccent : transparentGradient,
                    border: Border.all(color: profilePictureState != ProfilePictureState.COMPLETED ? secondaryAccent : Colors.transparent),
                    borderRadius:BorderRadius.circular(5), 
                  ),
                  alignment: Alignment.center,
                  child: Text(getButtonText(),
                    style: TextStyle(
                      color: primaryText,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
              
             
            ],
          ),
        ),
      ),
    );
  }

  String getButtonText(){
    if (profilePictureState == ProfilePictureState.COMPLETED) return S.of(context).continue_text;
    else if (profilePictureState == ProfilePictureState.LOADING) return S.of(context).saving_your_photo;
    else return S.of(context).add_photo;

  }

  void getImage() async{
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    imageSelected(imageFile);

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

      setState(() {
        profilePictureState = ProfilePictureState.LOADING;
        userPicture = croppedImage;
      });
      
      await _userBloc.setProfilePicture(croppedImage);
      setState(() => profilePictureState = ProfilePictureState.COMPLETED);
      
    }
  }
}