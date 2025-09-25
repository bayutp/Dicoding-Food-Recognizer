import 'dart:io';

import 'package:flutter/material.dart';
import 'package:food_recognizer_app/data/api/api_service.dart';
import 'package:food_recognizer_app/static/detail_result_state.dart';
import 'package:food_recognizer_app/static/helper.dart';
import 'package:http/http.dart';

class DetailProvider extends ChangeNotifier {
  final ApiService _service;

  DetailProvider(this._service);

  DetailResultState _resultState = DetailNoneResultState();

  DetailResultState get resultState => _resultState;

  Future<void> fetchDetailFood(String name) async {
    try {
      _emit(DetailLoadingResultState());

      final result = await _service.getFoodDetail(name);
      if (result.meals.isEmpty) {
        _emit(DetailErrorResultState(Helper.errEmpty));
      } else {
        _emit(DetailLoadedResultState(result.meals));
      }
    } on ClientException catch (_) {
      _emit(DetailErrorResultState(Helper.errServer));
    } on SocketException catch (_) {
      _emit(DetailErrorResultState(Helper.errInet));
    } on FormatException catch (_) {
      _emit(DetailErrorResultState(Helper.errFmt));
    } catch (e) {
      _emit(DetailErrorResultState(Helper.errMsg));
    }
  }

  void _emit(DetailResultState state) {
    _resultState = state;
    notifyListeners();
  }
}
