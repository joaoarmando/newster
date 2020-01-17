import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:upnews/app_theme.dart';
import 'package:upnews/blocs/home_bloc.dart';
import 'package:upnews/models/categories.dart';
import 'package:upnews/utils.dart';
//import 'package:upnews/widgets/home_widgets/news_tile.dart';

class NewsList extends StatefulWidget {
  final CategoryData category;
  final List<CategoryData> categoriesList;
  /*final Stream outCourseListRefresh;
  final Function retryLoad;
  final Stream outCourses;
  final Function nextPage;
  final Function tryAgainNextPage;

  NewsList({@required this.outCourseListRefresh, @required this.retryLoad, 
    @required this.outCourses, this.nextPage, this.tryAgainNextPage}); */

  NewsList({@required this.category, @required this.categoriesList});  

  @override
  _NewsListState createState() => _NewsListState();
}

class _NewsListState extends State<NewsList> with TickerProviderStateMixin {
  final HomeBloc _homeBloc = HomeBloc();
  AnimationController _controller;
  Animation<Offset> _offsetFloat; 
  Animation<double> opacityTween;
  Future<bool> getInternetConnection;
  Animation<Offset> ignoreAnimation;

  @override
  initState() {
    super.initState();

    _homeBloc.setCategoriesList(widget.categoriesList);
    _homeBloc.getNews(widget.category.categoryId, false);
    
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
      stream: _homeBloc.outCourseListRefresh,
      initialData: LoadingCoursesState.IDLE,
      builder: (context, snapshot) {
        if (snapshot.data == LoadingCoursesState.NO_INTERNET_CONNECTION){

          //return NoInternet(widget.retryLoad);
          return Text("Sem internet",style: TextStyle(color: Colors.red),);
          
        }
        else if (snapshot.data == LoadingCoursesState.LOADING)
          return _buildShimmerList(context);
        else   
          return StreamBuilder<Map<String,dynamic>>(
            stream: _homeBloc.outCourses,
            builder: (context, snapshot) {
              
              if (snapshot.data == null) return Container();
              var itemCount = snapshot.data["news"].length + 1;
                //if (snapshot.data["canAnimate"]) 
                _controller.forward();

                return Opacity(
                  opacity: opacityTween.value,
                  child: ListView.builder(
                      key: new PageStorageKey('myListView${widget.category.categoryId}'),
                      itemCount: itemCount,
                      shrinkWrap: true,
                      itemBuilder: (context,index){
                        if (index < snapshot.data["news"].length){
                          //return NewsTile(
                          //  news: snapshot.data["news"][index],
                          //);
                          return Container();
                        }
                        else if (snapshot.data["hasMore"]){
                          return FutureBuilder(
                            future: hasInternetConnection(true),
                            builder: (context, snapshot) {

                              bool isLoading = snapshot.connectionState == ConnectionState.waiting;
                              if (!isLoading && snapshot.data != null) isLoading = snapshot.data;
                              if (isLoading){
                                //tem net
                                if (snapshot.connectionState == ConnectionState.done) _homeBloc.nextPage();
                                return Container(
                                  width: 40,
                                  height: 40,
                                  margin: EdgeInsets.symmetric(vertical: 12,horizontal: 0),
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(secondaryAccent), strokeWidth: 2),
                                );
                              }
                              else {
                                // na tem internet
                              /* return CourseTileNoInternet((){
                                  widget.tryAgainNextPage();
                                }); */
                                return Text("Sem internet",style: TextStyle(color: Colors.yellowAccent,fontSize: 21),);
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