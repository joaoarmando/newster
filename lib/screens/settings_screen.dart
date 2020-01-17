import 'package:cached_network_image/cached_network_image.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:upnews/app_theme.dart';
import 'package:upnews/generated/i18n.dart';
import 'package:upnews/models/countries.dart';
import 'package:upnews/widgets/custom_dialog.dart' as customDialog;
import 'package:upnews/widgets/loading_widget.dart';


import '../utils.dart';
class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int feedStyle;
  


   var countryCode = "";
   var countryName = "";

  @override
  void initState() { 
    feedStyle = getFeedStyle();
    Future.delayed(Duration(milliseconds: 1)).then((a) async{
      countryCode =  await getCountry();
      countryName = getCountryName(countryCode);
      setState(() {});

    });
   
   
   
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        unselectedWidgetColor: secondaryAccent,
      ),
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: ListView(
            children: <Widget>[
              _preloadFlareActor(),
              _buildAppBar(context),
              _buildFeedStyle(context),
              _buildCountry(),
              _buildSendEmail(context),
            
            ],
          ),
        ),
        
      ),
    );
  }

  Widget _buildAppBar(BuildContext context){
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.5),
            offset: Offset(0,2),
            blurRadius: 2
          )
        ]
      ),
      child: Row(
        children: <Widget>[
          SizedBox(width:12),
          InkWell(
            child: Icon(Icons.close,color:primaryText,size: 35,),
            borderRadius: BorderRadius.circular(99),
            onTap: () async{   
                Navigator.pop(context);
            },
          ),
          SizedBox(width: 12),
          Text(S.of(context).settings,
            style:TextStyle(
              color: primaryText,
              fontWeight: FontWeight.bold,
              fontSize: 21
            )
          )
          
        ],
      ),
    );
  }

  Widget _buildFeedStyle(BuildContext context){
    return Container(
      padding: EdgeInsets.all(12),
      alignment: Alignment.topLeft,
      margin: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: secondaryBackgroundColor,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Color(0xff343651),width: 2)
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(S.of(context).feed_type,
            style: TextStyle(
              color: primaryText,
              fontSize: 16,
              fontWeight: FontWeight.bold
            ),
            textAlign: TextAlign.left,
          ),
          _buildButtonFeedStyle(context,
            S.of(context).highlighted,
            0,
            feedStyle == 0 ? "assets/images/feed_highlight_enabled.png" :"assets/images/feed_highlight_disabled.png"
          ),
          _buildButtonFeedStyle(context,
            S.of(context).simple,
            1,
            feedStyle == 1 ? "assets/images/feed_simple_enabled.png" :"assets/images/feed_simple_disabled.png"
          ),
        ],
      ),
    );
    
  }

  Widget _buildButtonFeedStyle(BuildContext context, String text, int feedStyle, String imagePath){
    bool isSelected = this.feedStyle == feedStyle;
    return AnimatedContainer(
      margin: EdgeInsets.symmetric(vertical:6),
      width: MediaQuery.of(context).size.width,
      height: 55,
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isSelected ? backgroundColor : Color(0xff1A1B29),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: (){
            if (!isSelected) {
              setState(() => this.feedStyle = feedStyle);
              saveFeedStyle(feedStyle);
            }
          },
          borderRadius: BorderRadius.circular(5),
          child: Container(
            padding: EdgeInsets.all(12),
            child: Row(
              children: <Widget>[
                Text(text,
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w500
                  ),
                ),
                Expanded(
                  child: Align(alignment: Alignment.centerRight, child: Image.asset(imagePath,height: 45,width: 45)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSendEmail(BuildContext context){
    return Container(
      padding: EdgeInsets.all(12),
      alignment: Alignment.topLeft,
      margin: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: secondaryBackgroundColor,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Color(0xff343651),width: 2)
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(S.of(context).having_problems,
            style: TextStyle(
              color: primaryText,
              fontSize: 16,
              fontWeight: FontWeight.bold
            ),
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 6),
          Text(S.of(context).you_need_help_or_would_like_to_send_your_feedback,
            style: TextStyle(
              color: secondaryText,
              fontSize: 14,
            ),
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 12),
          Align( alignment: Alignment.center,child: _buildSendEmailButton(context)),
        ],
      ),
    );
    
  }

  Widget _buildSendEmailButton(BuildContext context){
      return Container(
        margin: EdgeInsets.symmetric(vertical:12),
        decoration: BoxDecoration(
          color:backgroundColor ,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(5),
            onTap: (){
              Navigator.pushNamed(context, "/sendFeedback");
            },
            child: Container(
              padding: EdgeInsets.all(12),
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width * .7,
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.send,
                    color: primaryText,
                    size: 15,
                  ),
                  SizedBox(width: 12),
                  Text(S.of(context).contact_us,
                    style: TextStyle(
                      color: primaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.w500
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
  }

  Widget _buildCountry(){
    return Container(
      padding: EdgeInsets.all(12),
      alignment: Alignment.topLeft,
      margin: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: secondaryBackgroundColor,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Color(0xff343651),width: 2)
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(S.of(context).country_news,
            style: TextStyle(
              color: primaryText,
              fontSize: 16,
              fontWeight: FontWeight.bold
            ),
            textAlign: TextAlign.left,
          ),
          Text(S.of(context).choose_your_country_for_news,
            style: TextStyle(
              color: secondaryText,
              fontSize: 14,
              fontWeight: FontWeight.w500
            ),
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 12),
          Container(
            height: 50,
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: secondaryBackgroundColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () => showDialogSelectCountry(context),
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Color(0xff343651),width: 2)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(width:12),
                      Expanded(
                        child: Text("$countryName",
                            style: TextStyle(
                            color: primaryText,
                            fontWeight: FontWeight.w500,
                            fontSize: 16
                          ),
                          textAlign: TextAlign.left
                        ),
                      ),
                      SizedBox(width:12),
                      _buildFlagIcon(countryCode),
                    ],
                  ),
                ),
              ),
            ),
          )

        ],
      ),
    );
  }

  void showDialogSelectCountry(BuildContext context) async{
     return showDialog<void>(
        context: context,
        barrierDismissible: true, 
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
              child: FutureBuilder<List<Map<String,dynamic>>>(
                future: getAvaliableCountries(),
                builder: (context,snapshot){
                  if (snapshot.connectionState == ConnectionState.done){
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(S.of(context).available_contries,
                            style: TextStyle(
                              color: primaryText,
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        SizedBox(height: 12),
                        Container(
                          height: 250,
                          width: MediaQuery.of(context).size.width,
                          child: Scrollbar(
                            child: ListView.builder(
                              itemCount: snapshot.data.length,
                              shrinkWrap: true,
                              itemBuilder: (context,index){
                               
                                var country = snapshot.data[index];
                                var _countryCode = country["country"];
                                var _countryName = getCountryName(_countryCode);
                                bool isSelected = countryCode == _countryCode;
                                return Material(
                                  type: MaterialType.transparency,
                                  child: InkWell(
                                    onTap: () async{
                                      Navigator.pop(context);
                                      saveCountry(_countryCode);
                                      countryCode =  _countryCode;
                                      countryName = _countryName;
                                      setState(() {});
                                    },
                                    splashColor: Colors.black,
                                    child: Container(
                                      margin: EdgeInsets.symmetric(vertical: 6),
                                      child: Row(
                                        children: <Widget>[
                                          SizedBox(width: 12,),
                                          _buildFlagIcon(country["country"]),
                                          SizedBox(width: 12,),
                                          Text(_countryName,
                                            style: TextStyle(
                                              color: primaryText,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 15
                                            ),
                                          ),
                                          SizedBox(width: 12,),
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: SizedBox(
                                                height: 35,
                                                width: 35,
                                                child: IgnorePointer(
                                                  ignoring: true,
                                                  child: FlareActor(
                                                    "assets/animations/check_animation_filled.flr",
                                                    animation: isSelected ? "check_filled_no_anim"
                                                    : "unchecked"
                                                  )
                                                ),
                                              ),
                                            ),
                                          )

                                        ],
                                      )
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                      ],
                    );
                  }
                  else return Container(height:80,child: LoadingWidget());
                },
              ),
            ),

          );
        },
      );

  } 

  Widget _buildFlagIcon(String countryCode){
    return Container(
      margin: EdgeInsets.only(right: 12),
      alignment: Alignment.centerRight,
      child: CachedNetworkImage(
        imageUrl:"https://www.countryflags.io/$countryCode/flat/64.png",
        height: 45,
        width: 45,
      )
    );
  }

    Widget _preloadFlareActor(){
    return Row(
      children: <Widget>[
        Container(height:0,width:0,child: FlareActor("assets/animations/check_animation_filled.flr",animation: "unchecked")),
        Container(height:0,width:0,child: FlareActor("assets/animations/check_animation_filled.flr",animation: "check_filled_no_anim")),
      ],
    );
  }

}