import 'package:flutter/cupertino.dart';
import 'package:forme/forme.dart';

class FormeCupertinoFormRowDecorator<T> implements FormeFieldDecorator<T> {
  FormeCupertinoFormRowDecorator({
    this.helper,
    this.padding,
    this.prefix,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context, Widget child, FormeFieldState<T> field) {
    String? errorText = field.errorText;
    return CupertinoFormRow(
      prefix: prefix,
      padding: padding,
      helper: helper,
      error: errorText == null
          ? null
          : errorBuilder?.call(errorText) ?? Text(errorText),
      child: child,
    );
  }

  final Widget? helper;
  final EdgeInsetsGeometry? padding;
  final Widget? prefix;
  final Widget Function(String erroText)? errorBuilder;
}
