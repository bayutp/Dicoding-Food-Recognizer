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
                  Text(
                    "Presentase: ${(widget.food.score * 100).toStringAsFixed(2)}%",
                  ),
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
                    DetailLoadedResultState(result: var foodDetail) => Text(
                      foodDetail[0].strMeal,
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
