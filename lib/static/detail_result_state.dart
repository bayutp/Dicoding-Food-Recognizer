import 'package:food_recognizer_app/data/model/food_response.dart';

sealed class DetailResultState {}

class DetailNoneResultState extends DetailResultState {}

class DetailLoadingResultState extends DetailResultState {}

class DetailLoadedResultState extends DetailResultState {
  List<Meal> result;

  DetailLoadedResultState(this.result);
}

class DetailErrorResultState extends DetailResultState {
  String errorMsg;

  DetailErrorResultState(this.errorMsg);
}
