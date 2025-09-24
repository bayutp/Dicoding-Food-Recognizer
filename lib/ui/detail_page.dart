import 'dart:io';

import 'package:flutter/material.dart';
import 'package:food_recognizer_app/controller/detail_provider.dart';
import 'package:food_recognizer_app/data/api/api_service.dart';
import 'package:food_recognizer_app/data/model/food.dart';
import 'package:food_recognizer_app/static/detail_result_state.dart';
import 'package:provider/provider.dart';

class DetailPage extends StatelessWidget {
  final Food food;
  const DetailPage({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (context) => ApiService()),
        ChangeNotifierProvider(
          create: (context) => DetailProvider(context.read<ApiService>()),
        ),
      ],
      child: DetailView(food: food),
    );
  }
}

class DetailView extends StatefulWidget {
  final Food food;
  const DetailView({super.key, required this.food});

  @override
  State<DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends State<DetailView> {
  @override
  void initState() {
    super.initState();
    final provider = context.read<DetailProvider>();
    Future.microtask(() => provider.fetchDetailFood(widget.food.name));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.food.name)),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.file(
              File(widget.food.imagePath),
              width: double.infinity,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Text(
                      widget.food.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text("${(widget.food.score * 100).toStringAsFixed(2)}%"),
                ],
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Consumer<DetailProvider>(
                builder: (context, value, child) {
                  return switch (value.resultState) {
                    DetailLoadingResultState() => Center(
                      child: CircularProgressIndicator(),
                    ),
                    DetailErrorResultState(errorMsg: var msg) => Center(
                      child: Text(msg),
                    ),
                    DetailLoadedResultState(result: var foodDetail) => Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadiusGeometry.circular(16),
                              child: Image.network(
                                foodDetail[0].strMealThumb,
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    foodDetail[0].strMeal,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    "${foodDetail[0].strCategory} - ${foodDetail[0].strArea}",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Ingredients",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: foodDetail[0].ingredients.length,
                            itemBuilder: (context, index) {
                              final ingredient =
                                  foodDetail[0].ingredients[index];
                              final measure = foodDetail[0].measures[index];
                              return ListTile(
                                title: Text(ingredient),
                                subtitle: Text(measure),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Instructions",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          foodDetail[0].strInstructions,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                    _ => SizedBox.shrink(),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
