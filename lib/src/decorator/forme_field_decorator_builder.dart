import 'package:flutter/material.dart';
import 'package:forme/forme.dart';

class FormeFieldDecoratorBuilder<T> extends FormeFieldDecorator<T> {
  final Widget Function(
      BuildContext context, Widget child, FormeFieldState<T> field) buider;

  const FormeFieldDecoratorBuilder({
    required this.buider,
  });

  @override
  Widget build(BuildContext context, Widget child, FormeFieldState<T> field) {
    return this.buider.call(context, child, field);
  }
}
