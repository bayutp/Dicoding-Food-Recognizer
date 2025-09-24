import 'dart:io';

import 'package:flutter/material.dart';
import 'package:food_recognizer_app/controller/home_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeProvider(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Food Recognizer"),
        actions: [
          IconButton(
            onPressed: () {
              final imagePath = context.read<HomeProvider>().imagePath;
              if (imagePath != null) {
                context.read<HomeProvider>().cropImage(context);
              }
            },
            icon: Icon(Icons.crop),
          ),
        ],
      ),
      body: _HomeBody(),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: Consumer<HomeProvider>(
                  builder: (context, value, child) {
                    final imagePath = value.imagePath;
                    return imagePath == null
                        ? Align(
                            alignment: Alignment.center,
                            child: Icon(Icons.image_rounded, size: 100),
                          )
                        : Image.file(
                            File(imagePath.toString()),
                            fit: BoxFit.contain,
                          );
                  },
                ),
              ),
              SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              context.read<HomeProvider>().openGallery(),
                          child: const Text("Gallery"),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              context.read<HomeProvider>().openCamera(),
                          child: const Text("Camera"),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: () {
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      scaffoldMessenger.showSnackBar(
                        SnackBar(content: Text("Feature under development 🙏")),
                      );
                    },
                    child: const Text("Analyze"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
