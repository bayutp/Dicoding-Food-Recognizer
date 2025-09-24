import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:food_recognizer_app/service/image_classification_service.dart';
import 'package:food_recognizer_app/static/classifications_state.dart';

class ImageClassificationProvider extends ChangeNotifier {
  final ImageClassificationService _service;

  ClassificationsState _state = ClassificationsNoneState();
  ClassificationsState get state => _state;

  ImageClassificationProvider(this._service) {
    _service.initHelper();
  }

  Map<String, num> _classifications = {};

  Map<String, num> get classification => Map.fromEntries(
    (_classifications.entries.toList()
          ..sort((a, b) => a.value.compareTo(b.value)))
        .reversed
        .take(1),
  );

  Future<void> runClassifications(Uint8List bytes) async {
    _state = ClassificationsLoadingState();
    notifyListeners();

    try {
      _classifications = await _service.inferenceImageFileIsolate(bytes);
      _state = ClassificationsLoadedState(_classifications);
    } catch (e) {
      _state = ClassificationsErrorState(e.toString());
    }

    notifyListeners();
  }

  Future<void> close() async {
    await _service.close();
  }

  void reset() {
    _classifications = {};
    _state = ClassificationsNoneState();
    notifyListeners();
  }
}
