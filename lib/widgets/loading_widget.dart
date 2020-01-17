import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final double width,heigth;

  LoadingWidget({this.width,this.heigth});

  @override
  Widget build(BuildContext context) {
    double width = this.width == null ? 40 : this.width; 
    double heigth = this.heigth == null ? 40 : this.heigth; 
    return Center(
      child: Container(
        width: width,
        height: heigth,
        child: FlareActor(
          "assets/animations/splash_screen_animation.flr",
          animation:"loading"
        ),
      ),
    );
  }
}