import 'package:flutter/material.dart';

extension Responsive on BuildContext {
  static const double _dw = 390.0;
  static const double _dh = 844.0;

  double get _sw => MediaQuery.sizeOf(this).width;
  double get _sh => MediaQuery.sizeOf(this).height;

  double w(double dp) => dp * _sw / _dw;

  double h(double dp) => dp * _sh / _dh;

  double sp(double dp) => dp * _sw / _dw;

  double r(double dp) => dp * _sw / _dw;
}
