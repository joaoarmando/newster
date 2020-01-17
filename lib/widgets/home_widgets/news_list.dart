import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:upnews/app_theme.dart';
import 'package:upnews/generated/i18n.dart';
import 'package:upnews/utils.dart';
import 'package:upnews/widgets/home_widgets/news_tile_bigger.dart';
import 'package:upnews/widgets/loading_widget.dart';

import '../no_internet_widget.dart';
import 'news_tile_simple.dart';

class NewsList extends StatefulWidget {

  final Stream outCourseListRefresh;
  final Function retryLoad;
  final Stream outCourses;
  final Function nextPage;
  final Function tryAgainNextPage;
  final String singleKey;

  NewsList({@required this.outCourseListRefresh, @required this.retryLoad, 
    @required this.outCourses, this.nextPage, this.tryAgainNextPage, this.singleKey}); 

  //NewsList({@required this.outCourseListRefresh});  

  @override
  _NewsListState createState() => _NewsListState();
}

class _NewsListState extends State<NewsList> with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> _offsetFloat; 
  Animation<double> opacityTween;
  Future<bool> getInternetConnection;
  Animation<Offset> ignoreAnimation;

  @override
  initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
     opacityTween = Tween<double>(begin: 0.5,end: 1.0).animate(_controller);
    _offsetFloat = Tween<Offset>(begin: Offset(0.0, 0.1), end: Offset.zero)
        .animate(_controller);
    ignoreAnimation = Tween<Offset>(begin: Offset(0.0, 0.0), end: Offset.zero).animate(_controller);    

    _offsetFloat.addListener((){
      setState((){});
    }); 

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    return StreamBuilder<LoadingCoursesState>(
      stream: widget.outCourseListRefresh,
      builder: (context, snapshot) {

        if (snapshot.data == LoadingCoursesState.NO_INTERNET_CONNECTION){

          return NoInternetConnection(widget.retryLoad);
          //return Text("Sem internet",style: TextStyle(color: Colors.red),);
          
        }
        else if (snapshot.data == LoadingCoursesState.EMPTY_SEARCH){
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset("assets/images/img_search.png",width:200),
              SizedBox(height: 6),
              Text("Procure por alguma coisa...",
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 18
                ),
              )
            ],
          );
        }
        else if (snapshot.data == LoadingCoursesState.LOADING)
          return _buildShimmerList(context);
        else   
          return StreamBuilder<Map<String,dynamic>>(
            stream: widget.outCourses,
            builder: (context, snapshot) {
              
              if (snapshot.data == null) return Container();
              else if (snapshot.data["news"].length == 0){
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset("assets/images/img_not_found.png",width:200),
                      SizedBox(height: 6),
                      Text(S.of(context).nothing_here,
                        style: TextStyle(
                          color: secondaryText,
                          fontSize: 18
                        ),
                        textAlign: TextAlign.center,
                      )
                    ],
                  );
              }
              var itemCount = snapshot.data["news"].length + 1;
                //if (snapshot.data["canAnimate"]) 
                _controller.forward();

                return Opacity(
                  opacity: opacityTween.value,
                  child: ListView.builder(
                      key: new PageStorageKey('myListView${widget.singleKey}'),
                      itemCount: itemCount,
                      shrinkWrap: true,
                      itemBuilder: (context,index){
                        if (index < snapshot.data["news"].length){
                          return getFeedStyle() == 0 ? NewsTileBigger(
                             news: snapshot.data["news"][index],
                          ): NewsTileSimple(
                            news: snapshot.data["news"][index],
                          );
                        }
                        else if (snapshot.data["hasMore"]){
                          return FutureBuilder(
                            future: hasInternetConnection(true),
                            builder: (context, snapshot) {

                              bool isLoading = snapshot.connectionState == ConnectionState.waiting;
                              if (!isLoading && snapshot.data != null) isLoading = snapshot.data;
                              if (isLoading){
                                //tem net
                                if (snapshot.connectionState == ConnectionState.done) widget.nextPage();
                                return LoadingWidget(
                                  width: 60,
                                  heigth: 60,
                                );
                              }
                              else {
                                // na tem internet
                                return NoInternetConnection(widget.tryAgainNextPage); 
                            //  return NewsTileNoInternetConnection( ); 
                               // return Text("Sem internet",style: TextStyle(color: Colors.yellowAccent,fontSize: 21),);
                              }
                            },
                          );
                          
                        }
                        else return Container();
                      },
                    ),
                ); 

            }
          );
      }
    );
  }
}

Widget _buildShimmerList(BuildContext context){
  return ListView(
    children: <Widget>[
      _buildListTile(context),
      _buildListTile(context),
      _buildListTile(context),
    ],
  );
}

Widget _buildListTile(BuildContext context){
  return Shimmer.fromColors(
      baseColor: secondaryBackgroundColor,
      highlightColor: backgroundColor,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6,horizontal: 12),
        height: MediaQuery.of(context).size.height * .3,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: secondaryBackgroundColor,
        )
      ),
    );

}