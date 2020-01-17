
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:shimmer/shimmer.dart';
import 'package:upnews/models/news.dart';
import 'package:upnews/screens/news_screen.dart';
import '../../app_theme.dart';
import 'package:url_launcher/url_launcher.dart' as urlLaunch;

class NewsTileBigger extends StatelessWidget {
  final NewsData news;
  NewsTileBigger({@required this.news});
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 6,horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: secondaryBackgroundColor,
        ),
        child: Stack(
          children: <Widget>[
            buildNewsTile(context),
            Positioned.fill(
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  splashColor: splashColor,
                  borderRadius: BorderRadius.circular(10),
                  onTap: (){
                    FocusScope.of(context).unfocus();
                    Navigator.push(context, CupertinoPageRoute(builder: (context) => NewsScreen(news)));
                     //_launchURL(context,news.url);
                  },
                ),
              )
            )
          ],
        ),
      );
  }
  

  Widget buildImage(BuildContext context,String url){

    return CachedNetworkImage(
          imageUrl: url,
          imageBuilder: (context, imageProvider) => Container(
            height: MediaQuery.of(context).size.height * .3,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
              ),
            ),
          ),
          placeholder: (context, url) => Shimmer.fromColors(
              baseColor: secondaryBackgroundColor,
              highlightColor: backgroundColor,
              child: Container(
                height: MediaQuery.of(context).size.height * .3,
                width: MediaQuery.of(context).size.width,
              ),
            ),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ); 
  }

  Widget buildCategoryTag(String category){
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6,horizontal: 12),
        decoration: BoxDecoration(
          gradient: gradientAccent,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(10),bottomRight: Radius.circular(20)),
        ),
        child: Text(category,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: primaryText
          ),
        ),
      ),
    );
  }

  Widget buildTitle(String title){
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12,vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(.3),
              Colors.black.withOpacity(.6),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        ),
        child: Text(title,
          style: TextStyle(
            color: primaryText,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 4,
        ),
      ),
    );
  }

  Widget buildNewsTile(BuildContext context){
    return Column(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height * .3,
          child: Stack(
            children: <Widget>[
              buildImage(context,news.thumbnail),
              news.mainTag != null ? buildCategoryTag(news.mainTag) : Container(),
              buildTitle(news.title),
              
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(12,6,12,12),
          alignment: Alignment.centerLeft,
          child: Text(news.description,
            style: newsDescriptionStyle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
          ),
        ) 
      ],
    );
  }

  void _launchURL(BuildContext context, String url) async {
   /* try {
      await launch(
        url,
        option: new CustomTabsOption(
          toolbarColor: backgroundColor,
          enableDefaultShare: true,
          enableUrlBarHiding: true,
          showPageTitle: true,
          animation: new CustomTabsAnimation.fade(),
          // or user defined animation.
          /*animation: new CustomTabsAnimation(
            startEnter: 'slide_up',
            startExit: 'android:anim/fade_out',
            endEnter: 'android:anim/fade_in',
            endExit: 'slide_down',
          ), */
          extraCustomTabs: <String>[
            // ref. https://play.google.com/store/apps/details?id=org.mozilla.firefox
            'org.mozilla.firefox',
            // ref. https://play.google.com/store/apps/details?id=com.microsoft.emmx
            'com.microsoft.emmx',
          ],        
        ),
      );
    } catch (e) {
      
         if (await urlLaunch.canLaunch(url)) {
            await urlLaunch.launch(url);
          } else {
            throw 'Could not launch $url';
          }

      debugPrint(e.toString());
    } */
  }
}