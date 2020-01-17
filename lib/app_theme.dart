import 'package:flutter/material.dart';

final Color backgroundColor = Color(0xff0F1020);
final Color secondaryBackgroundColor = Color(0xff202030);
final Color secondaryText = Color(0xff6B717E);
final Color primaryText = Color(0xffF0EDEE);
final Color primaryAccent =  Color(0xffE8142A);
final Color secondaryAccent =  Color(0xffF5087F);
final Color iconColor =  Color(0xffCCC5C8);
final Color splashColor =  Color(0xff0F1020).withOpacity(.5);
final Color dividerColorPrimary =   Color(0xff202030);
final Color dividerColorSecondary =   Color(0xff1C1C24);

final LinearGradient gradientAccent = LinearGradient(
  colors: [
    Color(0xffE8142A),
    Color(0xffF5087F),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

final TextStyle selectedCategoryStyle = TextStyle(
  color: primaryText,
  fontSize: 18,
  fontWeight: FontWeight.bold
);

final TextStyle unselectedCategoryStyle =TextStyle(
  color: secondaryText,
  fontSize: 21,
  fontWeight: FontWeight.bold
);

final TextStyle newsTitleStyle = TextStyle(
  color: primaryText,
  fontSize: 16,
  fontWeight: FontWeight.w500,
);

final TextStyle newsDescriptionStyle = TextStyle(
  color: secondaryText,
  fontSize: 14,

);