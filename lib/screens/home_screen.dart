import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';
import 'package:shimmer/shimmer.dart';
import 'package:upnews/app_theme.dart';
import 'package:upnews/blocs/home_bloc.dart';
import 'package:upnews/blocs/user_bloc.dart';
import 'package:upnews/generated/i18n.dart';
import 'package:upnews/models/categories.dart';
import 'package:upnews/screens/search_screen.dart';
import 'package:upnews/up_news_icons_icons.dart';
import 'package:upnews/widgets/home_widgets/category_content.dart';
import 'package:upnews/widgets/custom_dialog.dart' as customDialog;
import 'package:upnews/widgets/loading_widget.dart';
import 'package:upnews/widgets/no_internet_widget.dart';

import '../utils.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  final HomeBloc _homeBloc = HomeBloc();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final UserBloc _userBloc = BlocProvider.getBloc();
  String currentCountry;
  Function verifyInternet = hasInternetConnection;

    @override
  void initState() {
    _homeBloc.checkInternet();
    getCurrentCountry();
    super.initState();
  }

  void getCurrentCountry() async {
   currentCountry = await getCountry();
  }
  void validateCountry() async{
    if (currentCountry != null) {
       String _newCurrentCountry = await getCountry();
      if (currentCountry != _newCurrentCountry){
          //TROCOU DE PAIS
          setState(() {
            currentCountry = _newCurrentCountry;
            _homeBloc.getCategories();
          });
      }
    }
  }

  void tryAgain(){
    _homeBloc.checkInternet();
    getCurrentCountry();
  }

  @override
  Widget build(BuildContext context) {
    validateCountry();
    
    return Scaffold(
      drawerEdgeDragWidth: 0,
      key: _scaffoldKey,
      backgroundColor: backgroundColor,
      drawer: _buildDrawer(),
      body: StreamBuilder(
        stream: _homeBloc.outRebuild,
        initialData: LoadingState.HAS_INTERNET,
        builder: (context,snapshot){
          if (snapshot.data == LoadingState.LOADING) return LoadingWidget(
            width: 70,
            heigth: 70,
          );
          else if (snapshot.data == LoadingState.HAS_INTERNET){
            return StreamBuilder<List<CategoryData>>(
              stream: _homeBloc.outCategories,
              builder: (context, snapshot) {
                var categories = snapshot.data;
                if (categories == null) return LoadingWidget();

                return DefaultTabController(
                  length: categories.length,
                  child: SafeArea(
                    child: NestedScrollView(
                      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                        return _headerSliverBuilderContent(categories);
                      },
                      body: TabBarView(
                        children:  categories.map((c) => _buildListNews(c,categories)).toList(),
                      ),
                    ),
                  ),
                );
              }
            );
          }
          else return NoInternetConnection(tryAgain); 
        },

      ),
    );
  }

    
  Widget _buildAppBarHome(){
    
    return Container(
      height: 55,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          StreamBuilder<String>(
            stream: _userBloc.outProfilePicture,
            initialData: _userBloc.getUrlPictureFromSharedPreferences(),
            builder: (context, snapshot) {
              return _buildAvatar(snapshot.data);
            }
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildSearchContainer(),
          )
          
        ],
      ),
    );
  }

  Widget _buildCategories(List<CategoryData> categories){
    return Container(
      height: 55,
      child: TabBar(
        isScrollable: true,
        indicatorColor: Colors.transparent,
        labelColor: primaryText,
        unselectedLabelColor: secondaryText,
        labelStyle: TextStyle(
          color: secondaryText,
          fontSize: 21,
          fontWeight: FontWeight.bold
        ),
        indicatorPadding: EdgeInsets.symmetric(horizontal: 24),
        tabs: categories.map((c) => Tab(text: c.categoryName)).toList()
      ),
    );
  }

  Widget _buildListNews(CategoryData category, List<CategoryData> categories){
      return CategoryContent(
        category: category,
        categoriesList:categories
      );
  }


  Widget _buildAvatar(String url){


    return Stack(
      children: <Widget>[
        Container(
          height: 45,
          width: 45,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: url != null ? CachedNetworkImage(
              imageUrl: url,
              imageBuilder: (context, imageProvider) => Container(
                height: 45,
                width: 45,
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
                  height: 45,
                  width: 45,
                  ),
                ),
              errorWidget: (context, url, error) => Icon(Icons.account_circle, color: secondaryText,size:45),
            ) : Icon(Icons.account_circle, color: secondaryText,size:45)
          ),
        ),
        Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            splashColor: splashColor,
            child: SizedBox(height: 45,width:45),
            onTap: (){
              _scaffoldKey.currentState.openDrawer();
            },
          ),
        ),
      ],
    );
  }

  _headerSliverBuilderContent(List<CategoryData> categories){
    return <Widget>[
      SliverList(
        delegate: SliverChildListDelegate(
          [
            _buildAppBarHome(),
          ]
        ),
      ),
      SliverPersistentHeader(
        delegate: _SliverAppBarDelegate(
          PreferredSize(
            preferredSize: Size(MediaQuery.of(context).size.width, 55),
            child: _buildCategories(categories),
          )
        ),
        pinned: true,
      ),
    ];
  }

  Widget _buildDrawer(){
    return Container(
      width: MediaQuery.of(context).size.width * .75,
      child: Drawer(
        child: Container(
          color: secondaryBackgroundColor,
          child: Column(
            // Important: Remove any padding from the ListView.
            children: <Widget>[
              _buildDrawerHeader(),
              _buildListTileDrawer(text:S.of(context).saved_news,icon: Icons.bookmark,function: (){
                _userBloc.user == null ? showDialogNeedLogin(context)
                  : Navigator.pushNamed(context, "/savedNewsScreen");
              }),
              _buildListTileDrawer(text:S.of(context).my_account,icon: UpNewsIcons.ic_account, function: (){
                Navigator.pushNamed(context, _userBloc.user == null ? "/loginScreen" : "/myAccount");
              }),
              _buildListTileDrawer(text:S.of(context).rate_app,icon: Icons.star_border, function: (){
                LaunchReview.launch(androidAppId: "com.app.upnews");
              }),
              _buildListTileDrawer(text:S.of(context).send_feedback,icon: Icons.send, function: (){
                Navigator.pushNamed(context,"/sendFeedback");
              }),
              _buildListTileDrawer(text:S.of(context).settings,icon: Icons.settings, function: (){
                Navigator.pushNamed(context,"/settingsScreen");
              }),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(12),
                  alignment: Alignment.bottomLeft,
                  child: Text("${S.of(context).version} 0.1.0",
                    style: TextStyle(
                      color: primaryText,
                      fontSize: 12
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildDrawerHeader(){
    return Container(
      height: 130,
      margin: EdgeInsets.symmetric(horizontal: 12),
      padding: EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1, color: dividerColorSecondary)
        )
      ),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: _userBloc.getUrlPictureFromSharedPreferences() != null ? CachedNetworkImage(
              imageUrl: _userBloc.getUrlPictureFromSharedPreferences(),
              imageBuilder: (context, imageProvider) => Container(
                height: 60,
                width: 60,
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
                  height: 45,
                  width: 45,
                  ),
                ),
              errorWidget: (context, url, error) => Icon(Icons.account_circle, color: secondaryText,size:45),
            ) : Icon(Icons.account_circle, color: secondaryText,size:45)
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text("${_userBloc.userName?? S.of(context).hello_there}",
              style: TextStyle(
                color: primaryText,
                fontSize: 21,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTileDrawer({@required String text, @required IconData icon, @required Function function}){
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: (){
          Navigator.pop(context);
          function();
        },
        splashColor: splashColor,
        child: ListTile(
          leading: Icon(icon,color: primaryText),
          title: Text(text,
            style: TextStyle(
              color: primaryText,
              fontWeight: FontWeight.w500,
              fontSize: 18
            ),
          ),
          
        
        ),
      ),
    );
  }
  
  Widget _buildSearchContainer(){
    return Hero(
      tag: "_searchContainer",
      child: Container(
        height: 45,
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: secondaryBackgroundColor,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: (){
              final newsPage =  SearchNewsScreen(_homeBloc.categorieList); 
              Navigator.push(context,MaterialPageRoute(builder: (context) => newsPage));
            },
            borderRadius: BorderRadius.circular(5),
            child: Container(
              height: 45,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Color(0xff343651),width: 2)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Text(S.of(context).search_news,
                        style: TextStyle(
                        color: primaryText,
                        fontWeight: FontWeight.w500,
                        fontSize: 16
                      ),
                      textAlign: TextAlign.center
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 12),
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.search,color:primaryText),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
    
  }

  
  void showDialogNeedLogin(BuildContext context) async{

     return showDialog<void>(
        context: context,
        barrierDismissible: true, // user must tap button!
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(S.of(context).login,
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(S.of(context).you_need_log_in_to_see_your_saved_news,
                    style: TextStyle(
                      color: primaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.w500
                    ),
                    textAlign: TextAlign.left,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      FlatButton(
                        child: Text(S.of(context).cancel,
                          style: TextStyle(
                            color: primaryText,
                            fontSize: 18
                          ),
                        ),
                        onPressed: (){
                          Navigator.pop(context);
                        },
                      ),
                      FlatButton(
                        child: Text(S.of(context).login,
                          style: TextStyle(
                            color: secondaryAccent,
                            fontSize: 18
                          ),
                        ),
                        onPressed: (){
                          Navigator.pop(context);
                          Navigator.pushNamed(context, "/loginScreen");
                          
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),

          );
        },
      );

  } 

}



class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final PreferredSize _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                backgroundColor,
                backgroundColor.withOpacity(.90)
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter
            )
          ),
          child: _tabBar,
        );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}