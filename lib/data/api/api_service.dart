import 'dart:convert';

import 'package:food_recognizer_app/data/model/food_response.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _host = "www.themealdb.com";
  static const String _path = "/api/json/v1/1/search.php";

  Future<FoodResponse> getFoodDetail(String name) async {
    final uri = Uri.https(_host, _path, {"s": name.trim()});
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return FoodResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load food detail");
    }
  }
}
