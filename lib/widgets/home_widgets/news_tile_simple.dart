
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:upnews/models/news.dart';
import 'package:upnews/screens/news_screen.dart';
import '../../app_theme.dart';

class NewsTileSimple extends StatelessWidget {
  final NewsData news;
  NewsTileSimple({@required this.news});
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
            constraints: BoxConstraints(
              minHeight: 150,
              minWidth: 150
            ),
            height: MediaQuery.of(context).size.height * .2,
            width: MediaQuery.of(context).size.height * .2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
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
                constraints: BoxConstraints(
                  minHeight: 150,
                  minWidth: 150
                ),
                height: MediaQuery.of(context).size.height * .2,
                width: MediaQuery.of(context).size.height * .2,
              ),
            ),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ); 
  }

  Widget buildCategoryTag(BuildContext context, String category){
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6,horizontal: 12),
        constraints: BoxConstraints(
           maxWidth: MediaQuery.of(context).size.height * .2,
        ),
        decoration: BoxDecoration(
          gradient: gradientAccent,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(10),bottomRight: Radius.circular(20)),
        ),
        child: Text(category,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: primaryText
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget buildTitle(BuildContext context, String title){
    return Container(
      padding: const EdgeInsets.all(12),
      height: MediaQuery.of(context).size.height * .2,
      child: Text(title,
        style: TextStyle(
          color: primaryText,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 6,
      ),
    );
  }

  Widget buildNewsTile(BuildContext context){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Stack(
          children: <Widget>[
            buildImage(context,news.thumbnail),
            news.mainTag != null ? buildCategoryTag(context,news.mainTag) : Container(),
          ],
        ),
        Expanded(
          child: buildTitle(context,news.title),
        )
      ],
    );
  }
  
  void _launchURL(BuildContext context, String url) async {
    /*try {
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
    }*/
  } 
}