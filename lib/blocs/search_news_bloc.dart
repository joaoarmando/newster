import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:diacritic/diacritic.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upnews/models/categories.dart';
import 'package:upnews/models/news.dart';
import 'package:upnews/utils.dart';

import '../shared_data.dart';

class SearchNewsBloc extends BlocBase {
  Timer _timer;
  final _savedCoursesController = BehaviorSubject<int>.seeded(0);
  final _refreshCourseListController = BehaviorSubject<LoadingCoursesState>.seeded(LoadingCoursesState.EMPTY_SEARCH);
  final _coursesController = BehaviorSubject<Map<String,dynamic>>();

  Stream<Map<String,dynamic>> get outCourses => _coursesController.stream;
  Stream<LoadingCoursesState> get outCourseListRefresh => _refreshCourseListController.stream;
  List<CategoryData> categorieList = [];
  String searchText = "";
  SharedPreferences prefs;
  List<String> savedCourses = [];
  double positionList; 
  String country;

  void setCategoriesList(List<CategoryData> _categorieList){
    categorieList = _categorieList;
  }



  void nextPage(){
    getNews(searchText,true);
  }

  void searchNews(String _search){
    if (_timer != null) _timer.cancel();
  _timer = new Timer(Duration(milliseconds: 1000), () {
     

      
      if (_search != searchText && _search.trim().length > 0)  {
        getNews(_search.trim(),false);
        
      }else {
        _refreshCourseListController.sink.add(LoadingCoursesState.EMPTY_SEARCH);
        _coursesController.sink.add(null);
      }
      searchText = _search.trim();
     

  });
}


  void tryAgainNextPage(){
    _coursesController.sink.add(getNewsCache());
  }

  Map<String,dynamic> getNewsCache(){
    Map<String,dynamic> cached;
    var cachedIndex = getIndex(searchText);
    if (cachedIndex != -1){
      cached = cachedNews[cachedIndex];
      return cached;
    }
    return null;
  }

  void getNews(String _searchText, bool nextPage) async{
    country = await getCountry();
    searchText = _searchText;
    Map<String,dynamic> cached = getNewsCache();

    if (cached != null){
      if (!nextPage) {
        cached["canAnimate"] = false;
        _coursesController.sink.add(cached);
        return null;
      } 
    }

    var cachedIndex = getIndex(searchText);
    if (!nextPage) {
        _refreshCourseListController.sink.add(LoadingCoursesState.LOADING);
        bool isConnected = await hasInternetConnection(true); // <= ISSO NÃO FUNCIONA NO FLUTTER WEB
        if (!isConnected){
          _refreshCourseListController.sink.add(LoadingCoursesState.NO_INTERNET_CONNECTION);
          return null;
        }
    }
 
    final ParseCloudFunction function = ParseCloudFunction('searchNews');
    final Map<String, String> params = <String, String>{
      'search': removeDiacritics(searchText),
      "skipCount": nextPage ? cached["news"].length.toString() : "0",
      "country":country
    };
      
    final apiResponse = await function.execute(parameters: params);
    
    
    List<NewsData> newsList = [];
    

    if (apiResponse.success){
      if (apiResponse.result != null){
        //Há cursos
        for (var course in apiResponse.result){

          int index = -1;
          if (cached != null) index =  getNewsIndex(course["objectId"],cached["news"]);
          if (index == -1) {
            String categoryName = getCategoryName(course["categories"][0]);
            newsList.add(NewsData.fromJSON(course,categoryName));
          }
        }
      }
      
      bool hasMoreNews = newsList.length > 9;

      if (cached == null){
        cached = {
          "searchText": removeDiacritics(searchText),
          "news":newsList,
          "hasMore":hasMoreNews,
          "canAnimate":true,
          "country":country
        };
        cachedNews.add(cached);
      }else {
        cached["news"].addAll(newsList);
        cached["hasMore"] = hasMoreNews;
        cached["canAnimate"] = false;
        cached["country"] = country;
        cachedNews[cachedIndex] = cached;
      }

      if(!nextPage) _refreshCourseListController.sink.add(LoadingCoursesState.IDLE);
      _coursesController.sink.add(cached);

    }
    return null;    
  }

  int getNewsIndex(String objectId,List<NewsData> newsList){
    for (var i = 0; i < newsList.length; i++){
      if (newsList[i].objectId == objectId){
          return i;
      }
    }
    return -1;
  }
  
  void retryLoad(){
    getNews(searchText, false);
  }


  int getIndex(String searchText){
    for (var i = 0; i < cachedNews.length; i++){
      if (cachedNews[i]["searchText"] == removeDiacritics(searchText) && cachedNews[i]["country"] == country)
        return i;
    }
    return -1;
  }
  
  String getCategoryName(int categoryId){
    for (CategoryData category in categorieList){
      if (category.categoryId == categoryId) return category.categoryName;
    }
    return "";
  }


  void dispose(){
    _savedCoursesController.close();
    _refreshCourseListController.close();
    _coursesController.close();
    super.dispose();
  }
}