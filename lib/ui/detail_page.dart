import 'dart:io';

import 'package:flutter/material.dart';
import 'package:food_recognizer_app/data/model/food.dart';

class DetailPage extends StatelessWidget {
  final Food food;
  const DetailPage({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(food.name)),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.file(
              File(food.imagePath),
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
                      food.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text("Presentase: ${(food.score * 100).toStringAsFixed(2)}%"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
