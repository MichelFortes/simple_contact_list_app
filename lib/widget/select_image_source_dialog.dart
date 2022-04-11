import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class SelectImageSourceDialog extends StatelessWidget {
  const SelectImageSourceDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: const EdgeInsets.all(16),
      children: [
        TextButton(
          onPressed:() => Navigator.pop(context, ImageSource.gallery),
          child: Row(
            children: [
              const Icon(Icons.image),
              const SizedBox(width: 16),
              Expanded(child: Text("select_image_gallery".tr, maxLines: 1)),
            ],
          ),
        ),
        TextButton(
          onPressed:() => Navigator.pop(context, ImageSource.camera),
          child: Row(
            children: [
              const Icon(Icons.camera),
              const SizedBox(width: 16),
              Expanded(child: Text("take_picture".tr, maxLines: 1)),
            ],
          ),
        ),
      ],
    );
  }
}
