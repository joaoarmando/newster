import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upnews/models/categories.dart';
import 'package:upnews/models/news.dart';
import 'package:upnews/utils.dart';

import '../shared_data.dart';
enum LoadingState{LOADING,NO_INTERNET,HAS_INTERNET}

class HomeBloc extends BlocBase {
  final _selectController = BehaviorSubject<int>();
  final _savedCoursesController = BehaviorSubject<int>.seeded(0);
  final _refreshCourseListController = BehaviorSubject<LoadingCoursesState>();
  final _savedCourseStateController = BehaviorSubject<bool>();
  final _coursesController = BehaviorSubject<Map<String,dynamic>>();
  final _categoriesController = BehaviorSubject<List<CategoryData>>();
  final _tryAgainController = BehaviorSubject<LoadingState>();

  Stream<LoadingState> get outRebuild => _tryAgainController.stream;
  Stream<int> get outSelected => _selectController.stream;
  Stream<int> get outSavedCourses => _savedCoursesController.stream;
  Stream<bool> get outSavedCoursesState => _savedCourseStateController.stream;
  Stream<Map<String,dynamic>> get outCourses => _coursesController.stream;
  Stream<LoadingCoursesState> get outCourseListRefresh => _refreshCourseListController.stream;
  Stream<List<CategoryData>> get outCategories => _categoriesController.stream;
  List<CategoryData> categorieList = [];
  int categoryId = -1 ;
  SharedPreferences prefs;
  List<String> savedCourses = [];
  double positionList; 

  String country;

  void setCategoriesList(List<CategoryData> _categorieList){
    categorieList = _categorieList;
  }


  void selectCategory(int _categoryId){
    if (categoryId != null){
      categoryId = _categoryId;
      _selectController.sink.add(categoryId);
    }
    getNews(categoryId,false);

  }

  void checkInternet() async{
    _tryAgainController.sink.add(LoadingState.LOADING);
    var hasInternet = await hasInternetConnection(true);
    if (hasInternet){
      _tryAgainController.sink.add(LoadingState.HAS_INTERNET);
      getCategories();
    }
    else _tryAgainController.sink.add(LoadingState.NO_INTERNET);
    
  }

  void nextPage(){
    getNews(categoryId,true);
  }

  void getCategories() async {
    country = await getCountry();
    categorieList.clear();
    var queryBuilder = QueryBuilder(ParseObject('Categories'))
      ..whereEqualTo("country",country.toUpperCase());

    ParseResponse apiResponse = await queryBuilder.query();
    if (apiResponse.success){
      
      if (apiResponse.result != null)
        for (ParseObject categories in apiResponse.result){
            for (Map<String,dynamic> category in categories.get("categories")){
              categorieList.add(CategoryData.fromJSON(category));
            }
        }
        if (categorieList.length == 0){
          // PAÍS NÃO SUPORTADO
          saveCountry("US");
        }
        else _categoriesController.sink.add(categorieList);
    } 
  }

  void tryAgainNextPage(){
    _coursesController.sink.add(getNewsCache());
  }

  Map<String,dynamic> getNewsCache(){
    Map<String,dynamic> cached;
    var cachedIndex = getIndex(categoryId);
    if (cachedIndex != -1){
      cached = cachedNews[cachedIndex];
      return cached;
    }
    return null;
  }

  void getNews(int _categoryId, bool nextPage) async{
    country = await getCountry();
    categoryId = _categoryId;
    Map<String,dynamic> cached = getNewsCache();
    if (cached != null){
      if (!nextPage) {
        cached["canAnimate"] = false;
        _coursesController.sink.add(cached);
        return null;
      } 
    }

    var cachedIndex = getIndex(categoryId);
    if (!nextPage) {
        _refreshCourseListController.sink.add(LoadingCoursesState.LOADING);
        bool isConnected = await hasInternetConnection(true); // <= ISSO NÃO FUNCIONA NO FLUTTER WEB
        if (!isConnected){
          _refreshCourseListController.sink.add(LoadingCoursesState.NO_INTERNET_CONNECTION);
          return null;
        }
    }
 

   

    if (!nextPage) _refreshCourseListController.sink.add(LoadingCoursesState.SUCCESS);
    List<int> categoriesList = [categoryId];
    var queryBuilder = QueryBuilder(ParseObject('News'))..setLimit(10)..orderByDescending("createdAt");

    if (categoryId != -1) queryBuilder.whereContainedIn("categories", categoriesList);
    if (nextPage) queryBuilder.setAmountToSkip(cached["news"].length);

    queryBuilder.whereEqualTo("country",country);
    
    
    List<NewsData> newsList = [];
    

    var apiResponse = await queryBuilder.query();

    if (apiResponse.success){
      if (apiResponse.result != null){
        //Há cursos
        for (var news in apiResponse.result){

          int index = -1;
          if (cached != null) index =  getNewsIndex(news.objectId,cached["news"]);
          if (index == -1) {
            String categoryName = getCategoryName(categoryId);
            newsList.add(NewsData.fromParseObject(news:news,categoryName: categoryName));
          }
        }
      }
      
      bool hasMoreNews = newsList.length > 9;

      if (cached == null){
        cached = {
          "categoryId": categoryId, 
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
    getCategories();
    getNews(categoryId, false);
  }


  int getIndex(int categoryId){
    for (var i = 0; i < cachedNews.length; i++){
      if (cachedNews[i]["categoryId"] == categoryId && cachedNews[i]["country"] == country)
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
    _selectController.close();
    _savedCoursesController.close();
    _savedCourseStateController.close();
    _refreshCourseListController.close();
    _coursesController.close();
    _categoriesController.close();
    _tryAgainController.close();
    super.dispose();
  }
}