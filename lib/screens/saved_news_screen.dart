import 'package:flutter/material.dart';
import 'package:upnews/app_theme.dart';
import 'package:upnews/blocs/saved_news_screen_bloc.dart';
import 'package:upnews/generated/i18n.dart';
import 'package:upnews/widgets/home_widgets/news_list.dart';

class SavedNewsScreen extends StatefulWidget {
  @override
  _SavedNewsScreenState createState() => _SavedNewsScreenState();
}

class _SavedNewsScreenState extends State<SavedNewsScreen> {
  
  SavedNewsBloc _savedNewsBloc = SavedNewsBloc();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String currentCountry;

  
    @override
  void initState() {
    _savedNewsBloc.getNews(false);

    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    
    return Scaffold(
      drawerEdgeDragWidth: 0,
      key: _scaffoldKey,
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _buildAppBar(),
            Expanded(
              child: _buildListNews()
            )
            
          ],
        ),
      ),
    );
  }



  Widget _buildListNews(){
       return NewsList(
        outCourseListRefresh:_savedNewsBloc.outCourseListRefresh,
        retryLoad: _savedNewsBloc.retryLoad,
        outCourses:_savedNewsBloc.outCourses,
        nextPage:_savedNewsBloc.nextPage,
        tryAgainNextPage:_savedNewsBloc.tryAgainNextPage,
        singleKey:"null",
      );
  } 

  Widget _buildAppBar(){
     return Container(
      padding: const EdgeInsets.all(12),
      height: 56,
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
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              child: Icon(Icons.close,color:primaryText,size: 35,),
              borderRadius: BorderRadius.circular(99),
              onTap: () async{
                  FocusScope.of(context).unfocus();
                  if (MediaQuery.of(context).viewInsets.bottom > 0)
                      await Future.delayed(Duration(milliseconds: 100));
                  
                  Navigator.pop(context);
              },
            ),
          ),
          SizedBox(width: 12),
          Text(S.of(context).saved_news,
              style: TextStyle(
                color: primaryText,
                fontWeight: FontWeight.w500,
                fontSize: 18
              ),
            ),
        ],
      ),
    );
  }




}

