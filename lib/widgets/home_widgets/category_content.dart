import 'package:flutter/material.dart';
import 'package:upnews/blocs/home_bloc.dart';
import 'package:upnews/models/categories.dart';

import 'news_list.dart';

class CategoryContent extends StatefulWidget {
  final CategoryData category;
  final List<CategoryData> categoriesList;
  CategoryContent({@required this.category, @required this.categoriesList});  

  @override
  _CategoryContentState createState() => _CategoryContentState();
}

class _CategoryContentState extends State<CategoryContent> with TickerProviderStateMixin {
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

    return NewsList(
       outCourseListRefresh:_homeBloc.outCourseListRefresh,
       retryLoad: _homeBloc.retryLoad,
       outCourses:_homeBloc.outCourses,
       nextPage:_homeBloc.nextPage,
       tryAgainNextPage:_homeBloc.tryAgainNextPage,
       singleKey:widget.category.categoryId.toString(),
    );
  }
}
