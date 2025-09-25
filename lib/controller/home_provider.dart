import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class HomeProvider extends ChangeNotifier {
  String? imagePath;
  XFile? imageFile;

  void _setImages(XFile? value) {
    imageFile = value;
    imagePath = value?.path;
    notifyListeners();
  }

  void openCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      _setImages(pickedFile);
    }
  }

  void openGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _setImages(pickedFile);
    }
  }

  void cropImage(BuildContext context) async {
    if (imagePath != null) {
      final CroppedFile? cropped = await ImageCropper().cropImage(
        sourcePath: imagePath!,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
            ],
          ),
          IOSUiSettings(
            title: 'Cropper',
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
            ],
          ),
          WebUiSettings(context: context),
        ],
      );

      if (cropped != null) {
        _setImages(XFile(cropped.path));
      }
    }
  }
}
