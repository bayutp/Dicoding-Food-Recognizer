import 'dart:isolate';
import 'dart:typed_data';

import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as image_lib;

class IsolateInference {
  static const String _debugName = "TFLITE_INFERENCE";
  final ReceivePort _receivePort = ReceivePort();
  late Isolate _isolate;
  late SendPort _sendPort;
  SendPort get sendPort => _sendPort;

  Future<void> start() async {
    _isolate = await Isolate.spawn<SendPort>(
      entryPoint,
      _receivePort.sendPort,
      debugName: _debugName,
    );
    _sendPort = await _receivePort.first;
  }

  static void entryPoint(SendPort sendPort) async {
    final port = ReceivePort();
    sendPort.send(port.sendPort);

    await for (final InferenceModel isolateModel in port) {
      final bytes = isolateModel.bytes!;
      final inputShape = isolateModel.inputShape;

      final img = image_lib.decodeImage(bytes);
      final resized = image_lib.copyResize(
        img!,
        width: inputShape[1],
        height: inputShape[2],
      );

      final imageMatrix = List.generate(
        resized.height,
        (y) => List.generate(resized.width, (x) {
          final pixel = resized.getPixel(x, y);
          return [pixel.r, pixel.g, pixel.b];
        }),
      );

      final input = [imageMatrix];
      final output = [List.filled(isolateModel.outputShape[1], 0)];
      final address = isolateModel.interpreterAddress;

      final result = List<int>.from(_runInference(input, output, address));
      int maxScore = result.reduce((a, b) => a + b);
      final keys = isolateModel.labels;
      final values = result
          .map((e) => e.toDouble() / maxScore.toDouble())
          .toList();

      var classification = Map.fromIterables(keys, values);
      classification.removeWhere((key, value) => value == 0);

      isolateModel.responsePort.send(classification);
    }
  }

  Future<void> close() async {
    _isolate.kill();
    _receivePort.close();
  }

  static _runInference(
    List<List<List<List<num>>>> input,
    List<List<int>> output,
    int address,
  ) {
    Interpreter interpreter = Interpreter.fromAddress(address);
    interpreter.run(input, output);

    final result = output.first;
    return result;
  }
}

class InferenceModel {
  Uint8List? bytes;
  int interpreterAddress;
  List<String> labels;
  List<int> inputShape;
  List<int> outputShape;
  late SendPort responsePort;

  InferenceModel(
    this.bytes,
    this.interpreterAddress,
    this.labels,
    this.inputShape,
    this.outputShape,
  );
}
