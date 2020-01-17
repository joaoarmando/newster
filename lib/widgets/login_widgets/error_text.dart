import 'package:flutter/material.dart';
import 'package:upnews/generated/i18n.dart';
import 'package:upnews/utils.dart';

class ErrorText extends StatelessWidget {
  
  final stream;
  ErrorText(this.stream);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<dynamic>(
      stream: stream,
      builder: (context, snapshot) {
        String errorMessage = "";
        print(snapshot.hasError);
        if (snapshot.hasError){
          ExceptionStrings exception = snapshot.error;
          errorMessage = getErrorMessage(context,exception);
          print(exception);
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          child: Text(errorMessage,
            style: TextStyle(
              color: Colors.red,
              fontSize: 14
            ),
          ),
        );
      }
    );
  }

  String getErrorMessage(BuildContext context, ExceptionStrings exception){
    String message = "";
    switch (exception){
      case ExceptionStrings.TYPE_A_VALID_EMAIL:
        message = S.of(context).type_valid_email;
        break;
      case ExceptionStrings.WRONG_EMAIL_OR_PASSWORD:
        message = S.of(context).wrong_email_or_password;
        break;
      case ExceptionStrings.TYPE_NAME_AND_LAST_NAME:
        message = S.of(context).type_name_and_last_name;
        break;
      case ExceptionStrings.INVALID_NAME:
        message = S.of(context).invalid_name;
        break;
      case ExceptionStrings.PASSWORD_MUST_BE_LEAST_8:
        message = S.of(context).password_length;
        break;
      case ExceptionStrings.DIFFERENT_PASSWORDS:
        message = S.of(context).different_passwords;
        break;
      case ExceptionStrings.EMAIL_ALREADY_USED:
        message = S.of(context).email_already_used;
        break;
      case ExceptionStrings.INSUFFICIENT_CHARACTERS:
        message = S.of(context).insufficient_characters_feedback;
        break;
      default:
        break;
    }

    return message;
  }
}