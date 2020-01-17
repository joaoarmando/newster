import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_theme.dart';
import 'login_widgets/error_text.dart';

class InputTextField extends StatelessWidget {
  final String hint;
  final bool obscure;
  final Function(String) changed;
  final Stream errorStream;
  final TextInputFormatter inputFormatter;
  final TextInputType keyboardType;
  final String initialValue;
  final FocusNode focusNode;
  final flagIcon;
  InputTextField({this.hint,this.obscure,this.changed, this.errorStream, this.focusNode, this.inputFormatter, this.initialValue, this.keyboardType, this.flagIcon});

  @override
  Widget build(BuildContext context) {
    TextInputType textInputType = TextInputType.text;
    if (keyboardType != null) textInputType = keyboardType; 

    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
            color: secondaryBackgroundColor,
            borderRadius: BorderRadius.circular(5)
          ),
          child: TextFormField(
            focusNode: focusNode,
            initialValue: initialValue?? "",
            obscureText: obscure,
            decoration: InputDecoration(
              labelText: hint,
              border: OutlineInputBorder( borderRadius: BorderRadius.circular(5)),
              suffixIcon: flagIcon?? Container(width: 0,height: 0),
            ),
            style: TextStyle(
              color: primaryText,
              fontWeight: FontWeight.w500,
              fontSize: 16
            ),
            onChanged: changed,
            keyboardType: textInputType,
            inputFormatters: <TextInputFormatter>[
              BlacklistingTextInputFormatter.singleLineFormatter,
              inputFormatter
            ],
          ),
        ),
        ErrorText(errorStream)
      ],
    );
  }
}