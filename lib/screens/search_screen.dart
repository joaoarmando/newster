import 'dart:async';

import 'package:flutter/material.dart';
import 'package:upnews/blocs/search_news_bloc.dart';
import 'package:upnews/generated/i18n.dart';
import 'package:upnews/widgets/home_widgets/news_list.dart';
import '../app_theme.dart';

class SearchNewsScreen extends StatefulWidget {

  final categories;
  SearchNewsScreen(this.categories);

  @override
  _SearchNewsScreenState createState() => _SearchNewsScreenState();
}

class _SearchNewsScreenState extends State<SearchNewsScreen> {

  var focusNode = new FocusNode();
  SearchNewsBloc _searchNewsBloc = SearchNewsBloc();

  @override
  void initState() {
    _searchNewsBloc.setCategoriesList(widget.categories);
    Future.delayed(Duration(milliseconds: 500)).then((a){
      FocusScope.of(context).requestFocus(focusNode);
    });
   
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: <Widget>[

            _buildSearchContainer(),
            Expanded(child: _buildListNews()),
          ],
        ),
      ),
      
    );
  }

  
  Widget _buildListNews(){
       return NewsList(
        outCourseListRefresh:_searchNewsBloc.outCourseListRefresh,
        retryLoad: _searchNewsBloc.retryLoad,
        outCourses:_searchNewsBloc.outCourses,
        nextPage:_searchNewsBloc.nextPage,
        tryAgainNextPage:_searchNewsBloc.tryAgainNextPage,
        singleKey:"null",
      );
  } 


  Widget _buildSearchContainer(){
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
                FocusScope.of(context).unfocus();
                if (MediaQuery.of(context).viewInsets.bottom > 0)
                    await Future.delayed(Duration(milliseconds: 100));
                
                Navigator.pop(context);
            },
          ),
          Hero(
            tag: "_searchContainer",
            child: Container(
              margin: EdgeInsets.symmetric(horizontal:12),
              width: MediaQuery.of(context).size.width * .8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5)
              ),

              child: Material(
                type: MaterialType.transparency,
                child: TextField(
                  focusNode: focusNode,
                  decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(top:2, bottom:2, left: 6),
                    suffixIcon: Icon(Icons.search,size: 30,color: primaryText),
                    border:  OutlineInputBorder( borderRadius: BorderRadius.circular(5)),
                    fillColor: secondaryBackgroundColor,
                    filled: true,
                    hintText: S.of(context).search_news,
                    hintStyle: TextStyle(color: secondaryText, fontSize: 16)
                  ),
                  onChanged: (s){
                     _searchNewsBloc.searchNews(s);
                  },
                  onSubmitted: (s){
                    _searchNewsBloc.getNews(s.trim(),false);
                  },
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(color:primaryText, fontSize: 16, fontWeight: FontWeight.w600),   
                ),
              ),
            ),
          )
          
        ],
      ),
    );
  }
}