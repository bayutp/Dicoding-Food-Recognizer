import 'dart:io';

import 'package:flutter/material.dart';
import 'package:food_recognizer_app/controller/home_provider.dart';
import 'package:food_recognizer_app/controller/image_classification_provider.dart';
import 'package:food_recognizer_app/service/image_classification_service.dart';
import 'package:food_recognizer_app/static/classifications_state.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (context) => ImageClassificationService()),
        ChangeNotifierProvider(
          create: (context) => ImageClassificationProvider(
            context.read<ImageClassificationService>(),
          ),
        ),
        ChangeNotifierProvider(create: (context) => HomeProvider()),
      ],
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

class _HomeBody extends StatefulWidget {
  const _HomeBody();

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  late ImageClassificationProvider provider;
  String? imagePath;

  @override
  void dispose() {
    provider.close();
    super.dispose();
  }

  @override
  void initState() {
    provider = context.read<ImageClassificationProvider>();
    super.initState();
  }

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
                    imagePath = value.imagePath;
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
              Consumer<ImageClassificationProvider>(
                builder: (context, value, child) {
                  if (value.classification.isEmpty) {
                    return SizedBox.shrink();
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          value.classification.entries.first.key,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        child: Row(
                          mainAxisSize:
                              MainAxisSize.min, // biar ukuran pas isi konten
                          children: const [
                            Text('Food detail'),
                            SizedBox(width: 8), // jarak antara teks dan icon
                            Icon(Icons.arrow_forward), // icon di sebelah kanan
                          ],
                        ),
                      ),
                    ],
                  );
                },
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
                          onPressed: () => {
                            context.read<HomeProvider>().openGallery(),
                            provider.reset(),
                          },
                          child: const Text("Gallery"),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => {
                            context.read<HomeProvider>().openCamera(),
                            provider.reset(),
                          },
                          child: const Text("Camera"),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Consumer<ImageClassificationProvider>(
                    builder: (context, provider, _) {
                      return switch (provider.state) {
                        ClassificationsLoadingState() =>
                          const FilledButton.tonal(
                            onPressed: null,
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ClassificationsLoadedState() => FilledButton.tonal(
                          onPressed: () async {
                            if (imagePath != null && imagePath!.isNotEmpty) {
                              final bytes = await File(
                                imagePath!,
                              ).readAsBytes();
                              await provider.runClassifications(bytes);
                            }
                          },
                          child: const Text("Analyze"),
                        ),
                        ClassificationsErrorState(:final error) => Column(
                          children: [
                            Text(
                              'Error: $error',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            FilledButton.tonal(
                              onPressed: () async {
                                if (imagePath != null &&
                                    imagePath!.isNotEmpty) {
                                  final bytes = await File(
                                    imagePath!,
                                  ).readAsBytes();
                                  await provider.runClassifications(bytes);
                                }
                              },
                              child: const Text("Retry"),
                            ),
                          ],
                        ),
                        _ => FilledButton.tonal(
                          onPressed: () async {
                            if (imagePath != null && imagePath!.isNotEmpty) {
                              final bytes = await File(
                                imagePath!,
                              ).readAsBytes();
                              await provider.runClassifications(bytes);
                            }
                          },
                          child: const Text("Analyze"),
                        ),
                      };
                    },
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
