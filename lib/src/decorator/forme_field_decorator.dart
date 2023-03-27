import 'package:flutter/widgets.dart';
import 'package:forme/forme.dart';

/// **Widget returned by this decorator is a part of `FormeField`**
///
/// **DO NOT return another [FormeField]**
abstract class FormeFieldDecorator<T> {
  const FormeFieldDecorator();
  Widget build(BuildContext context, Widget child, FormeFieldState<T> field);
}
