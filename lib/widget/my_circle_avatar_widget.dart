import 'dart:io';

import 'package:flutter/material.dart';

class MyCircleAvatarWidget extends StatelessWidget {
  final String imageUrl;
  final String placeholderAsset;
  final String? localStorageTempImagePath;

  const MyCircleAvatarWidget({Key? key, required this.imageUrl, required this.placeholderAsset, this.localStorageTempImagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.2), shape: BoxShape.circle, border: Border.all(color: Theme.of(context).primaryColor, width: 1)),
        child: ClipOval(
          child: localStorageTempImagePath != null
              ? Image.file(File(localStorageTempImagePath!), fit: BoxFit.cover)
              : FadeInImage.assetNetwork(
                  image: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: placeholderAsset,
                  imageErrorBuilder: (context, object, stack) => Image.asset(placeholderAsset),
                ),
        ),

        // Image.network(imageUrl,
        //   fit: BoxFit.cover,
        //   errorBuilder: (context, error, stackTrace) => Image.asset(placeholderAsset),
        //   loadingBuilder: (context, widget, event) => event?.cumulativeBytesLoaded == event?.expectedTotalBytes ? widget : Image.asset(placeholderAsset),
        // ),
      ),
    );
  }
}
