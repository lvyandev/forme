import 'package:flutter/material.dart';
import 'package:forme/forme.dart';

typedef EmptyChecker<T> = bool Function(T value, FormeFieldState<T> field);
typedef InputDecorationBuilder = InputDecoration Function(BuildContext context);

class FormeInputDecorationDecorator<T> extends FormeFieldDecorator<T> {
  final int? hintMaxLines;
  final EmptyChecker<T>? emptyChecker;
  final InputCounterWidgetBuilder? buildCounter;
  final int Function(T value)? counter;
  final int? maxLength;
  final InputDecorationBuilder? decorationBuilder;
  final Widget Function(BuildContext context, Widget child)? childBuilder;

  FormeInputDecorationDecorator({
    this.hintMaxLines,
    this.emptyChecker,
    this.buildCounter,
    this.maxLength,
    this.counter,
    this.decorationBuilder,
    this.childBuilder,
  });

  @override
  Widget build(BuildContext context, Widget child, FormeFieldState<T> field) {
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final ThemeData themeData = Theme.of(context);
    bool isValidateQuietly = Forme.of(context)?.quietlyValidate ?? false;
    bool isFocused = field.hasFocusNode ? field.focusNode.hasFocus : false;
    InputDecoration? decoration = decorationBuilder?.call(context);
    InputDecoration effectiveDecoration =
        (decoration ?? const InputDecoration())
            .applyDefaults(themeData.inputDecorationTheme)
            .copyWith(
              enabled: field.enabled,
              hintMaxLines: decoration?.hintMaxLines ?? hintMaxLines,
              errorText: isValidateQuietly ? null : field.errorText,
            );
    Widget? counter;
    if (effectiveDecoration.counter == null &&
        effectiveDecoration.counterText == null &&
        buildCounter != null) {
      final Widget? builtCounter = buildCounter!(
        context,
        currentLength: this.counter!(field.value),
        maxLength: maxLength,
        isFocused: isFocused,
      );
      // If buildCounter returns null, don't add a counter widget to the field.
      if (builtCounter != null) {
        counter = Semantics(
          container: true,
          liveRegion: isFocused,
          child: builtCounter,
        );
      }
      effectiveDecoration = effectiveDecoration.copyWith(counter: counter);
    }

    if (maxLength != null) {
      int currentLength = (this.counter ?? _counter).call(field.value);
      String counterText = '$currentLength';
      String semanticCounterText = '';
      // Handle a real maxLength (positive number)
      if (maxLength! > 0) {
        // Show the maxLength in the counter
        counterText += '/$maxLength';
        final int remaining = (maxLength! - currentLength)
            .clamp(0, maxLength!); // ignore_clamp_double_lint
        semanticCounterText =
            localizations.remainingTextFieldCharacterCount(remaining);
      }
      bool hasIntrinsicError = maxLength! > 0 && currentLength > maxLength!;
      if (hasIntrinsicError) {
        effectiveDecoration = effectiveDecoration.copyWith(
          errorText: effectiveDecoration.errorText ?? '',
          counterStyle: effectiveDecoration.errorStyle ??
              (themeData.useMaterial3
                  ? _m3CounterErrorStyle(context)
                  : _m2CounterErrorStyle(context)),
          counterText: counterText,
          semanticCounterText: semanticCounterText,
        );
      } else {
        effectiveDecoration = effectiveDecoration.copyWith(
          counterText: counterText,
          semanticCounterText: semanticCounterText,
        );
      }
    }

    return InputDecorator(
      decoration: effectiveDecoration,
      isEmpty: emptyChecker?.call(field.value, field) ?? false,
      isFocused: isFocused,
      child: childBuilder?.call(context, child) ?? child,
    );
  }

  int _counter(T value) {
    if (value is String) {
      return value.length;
    }
    if (value is Map) {
      return value.length;
    }
    if (value is Iterable) {
      return value.length;
    }
    throw 'can not determine the length of value';
  }

  TextStyle _m2CounterErrorStyle(BuildContext context) => Theme.of(context)
      .textTheme
      .bodySmall!
      .copyWith(color: Theme.of(context).colorScheme.error);

  TextStyle _m3CounterErrorStyle(BuildContext context) => Theme.of(context)
      .textTheme
      .bodySmall!
      .copyWith(color: Theme.of(context).colorScheme.error);
}
