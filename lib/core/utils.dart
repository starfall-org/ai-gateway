import 'package:flutter/material.dart';

Widget buildBrandLogo(String name, String? fileName) {
  return Image.asset(
    'assets/brand_logos/$fileName.png',
    height: 24,
    width: 24,
  );
}
