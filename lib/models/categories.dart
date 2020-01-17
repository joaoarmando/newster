class CategoryData {
  String categoryName;
  int categoryId;

  CategoryData.fromJSON(Map<String,dynamic> _category){
    categoryName = _category["categoryName"];
    categoryId = _category["categoryId"];
  }
}