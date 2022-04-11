import 'package:flutter/material.dart';

var gradientBox = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Colors.white,
      Colors.brown.shade200,
    ],
  ),
);
