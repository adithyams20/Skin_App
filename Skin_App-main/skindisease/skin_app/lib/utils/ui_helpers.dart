import 'package:flutter/material.dart';

class UIHelpers {
  static SizedBox verticalSpace(double height) {
    return SizedBox(height: height);
  }

  static SizedBox horizontalSpace(double width) {
    return SizedBox(width: width);
  }

  static Widget sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}