//*************   © Copyrighted by OkiTel. An Exclusive item of Kostricani. *********************

import 'dart:core';
import 'dart:math';
import 'package:flutter/animation.dart';

class ShakeCurve extends Curve {
  @override
  double transform(double t) {
    //t from 0.0 to 1.0
    return sin(t * 3 * pi).abs();
  }
}
