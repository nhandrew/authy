import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract class TextFieldStyles {
  static BoxDecoration get cupertinoDecoration {
    return BoxDecoration(
        border: Border.all(
          color: Colors.white,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(5.0));
  }

  static BoxDecoration get cupertinoErrorDecoration {
    return BoxDecoration(
        border: Border.all(
          color: Colors.deepPurple,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(5.0));
  }
}