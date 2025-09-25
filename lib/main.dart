import 'package:flutter/material.dart';
import 'package:food_recognizer_app/data/model/food.dart';
import 'package:food_recognizer_app/static/navigation_route.dart';
import 'package:food_recognizer_app/ui/detail_page.dart';
import 'package:food_recognizer_app/ui/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: NavigationRoute.mainRoute.name,
      routes: {
        NavigationRoute.mainRoute.name: (context) => const HomePage(),
        NavigationRoute.detailRoute.name: (context) => DetailPage(
          food: ModalRoute.of(context)?.settings.arguments as Food,
        ),
      },
    );
  }
}
