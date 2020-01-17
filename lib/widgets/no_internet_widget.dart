import 'package:flutter/material.dart';
import 'package:upnews/generated/i18n.dart';

import '../app_theme.dart';

class NoInternetConnection extends StatelessWidget {

  final Function function;

  NoInternetConnection(this.function);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(S.of(context).no_internet,style: newsTitleStyle,textAlign: TextAlign.center,),
          ),
          Container(
            margin: EdgeInsets.all(12),
            child: InkWell(
              onTap: function,
              borderRadius: BorderRadius.circular(5),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: secondaryAccent)
                ),
                child: Text(S.of(context).try_again, style: TextStyle(color: secondaryAccent,fontSize: 15))
              ),
            ),
          ),
          
        ],
      ),
    );
  }
}