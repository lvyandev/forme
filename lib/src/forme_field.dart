import 'package:flutter/widgets.dart';

import '../forme.dart';
import 'forme_field_scope.dart';

typedef FormeFieldStatusChanged<T> = void Function(
    FormeFieldState<T>, FormeFieldChangedStatus<T> status);
typedef FormeAsyncValidator<T> = Future<String?> Function(
  FormeFieldState<T> field,
  T value,
  bool Function() isValid,
);
typedef FormeValidator<T> = String? Function(FormeFieldState<T> field, T value);
typedef FormeFieldSetter<T> = void Function(FormeFieldState<T> field, T value);
typedef FormeFieldInitialized<T> = void Function(FormeFieldState<T> field);
typedef FormeFieldBuilder<T> = Widget Function(FormeFieldState<T> state);
typedef FormeFieldValidationFilter<T> = bool Function(
    FormeFieldValidationContext<T> context);

@immutable
class FormeFieldType extends Type {
  final Type fieldType;
  final String name;

  FormeFieldType._(this.fieldType, this.name);

  @override
  int get hashCode => Object.hash(fieldType, name);

  @override
  bool operator ==(Object other) {
    return other is FormeFieldType &&
        other.fieldType == fieldType &&
        other.name == name;
  }

  @override
  String toString() {
    return '$fieldType[$name]';
  }
}

class FormeField<T> extends StatefulWidget {
  /// field name
  ///
  /// **MUST BE UNIQUE IN A FORM**
  ///
  /// null name means:
  /// 1. value will be ignored when get form data
  /// 2. validation will be ignored when perform  a form validation ,but field won't
  /// 3. when get validation from `FormeState` , this field will be ignored
  /// 4. [Forme] will not hold this field state , visitors on [Forme] will not be triggered
  ///
  ///
  ///
  /// **if [name] changed , field will be disposed and rebuild**
  final String? name;

  final bool readOnly;
  final FormeFieldBuilder<T> builder;

  /// whether field is enabled,
  ///
  /// if field is disabled:
  ///
  /// 1. field will lose focus and can not be focused , but you still can get focusNode from `FormeFieldState` and set `canRequestFocus` to true and require focus
  /// 2. field's validators are ignored (manually validation will  be also ignored)
  /// 3. field is readOnly
  /// 4. value will be ignored when get form data
  /// 5. value can still be changed via `FormeFieldState`
  /// 6. validation state will always be `FormeValidationState.unnecessary`
  /// 7. when get validation from `FormeState` , this field will be ignored
  final bool enabled;

  /// initial value
  ///
  /// **[Forme.initialValue] has higher priority than field's initialValue**
  final T initialValue;

  /// used to support [Forme.autovalidateByOrder]
  ///
  /// **if not specified  , will use the order registered to [Forme]**
  final int? order;

  /// whether request focus when field value changed
  final bool requestFocusOnUserInteraction;

  /// listen field status change
  final FormeFieldStatusChanged<T>? onStatusChanged;

  /// called immediately after [FormeFieldState.initStatus]
  ///
  /// typically used to add visitors
  ///
  /// **DO NOT** request a new frame here
  final FormeFieldInitialized<T>? onInitialized;

  final FormeFieldSetter<T>? onSaved;

  /// quietlyValidate
  ///
  /// final value is [Forme.quietlyValidate] || [FormeField.quietlyValidate]
  ///
  /// false means default error text will not be displayed when validation not passed
  final bool quietlyValidate;

  /// not worked when validate manually
  final Duration? asyncValidatorDebounce;

  /// sync validator
  final FormeValidator<T>? validator;

  /// used to perform an async validation
  ///
  /// if you specify both asyncValidator and validator , asyncValidator will only worked after validator passed
  ///
  /// `isValid` is used to check whether this validation is valid or not
  /// if you want to update ui before you return validation result , you should call `isValid()` first
  ///
  /// eg:
  ///
  /// ```
  /// asyncValidator:(controller,value,isValid) {
  ///   return Future.delayed(const Duration(millseconds:500),(){
  ///     if(isValid()) {
  ///       updateUI();
  ///     }
  ///     return validationResult;
  ///   });
  /// }
  /// ```
  ///
  /// if `isValid()` is false, it means widget is unmounted or another async validation is performed
  /// or reset is called
  final FormeAsyncValidator<T>? asyncValidator;

  final AutovalidateMode autovalidateMode;

  /// used to determine whether perform a validation
  ///
  /// will not work when validate manually
  ///
  ///
  /// default :
  ///
  /// ``` Dart
  /// bool _defaultValidationFilter(FormeFieldValidationContext<T> context) {
  ///   final FormeFieldValidation validation = context.validation;
  ///
  ///   if (validation.isWaiting || validation.isFail) {
  ///     return true;
  ///   }
  ///
  ///   if (context.validatingValue != null) {
  ///     return !context.comparator(
  ///         context.validatingValue!.value, context.currentValidateValue);
  ///   }
  ///
  ///   if (context.latestSuccessfulValidationValue == null) {
  ///     return true;
  ///  }
  ///
  ///   return !context.comparator(context.latestSuccessfulValidationValue!.value,
  ///       context.currentValidateValue);
  ///}
  /// ```
  final FormeFieldValidationFilter<T>? validationFilter;
  final FocusNode? focusNode;

  /// used to decorate field
  ///
  /// [FormeInputDecorationDecorator]
  final FormeFieldDecorator<T>? decorator;

  Type get fieldType => super.runtimeType;

  @override
  Type get runtimeType =>
      name == null ? super.runtimeType : FormeFieldType._(fieldType, name!);

  const FormeField.allFields({
    required Key? key,
    required String? name,
    required bool readOnly,
    required FormeFieldBuilder<T> builder,
    required bool enabled,
    required T initialValue,
    required int? order,
    required bool requestFocusOnUserInteraction,
    required FormeFieldStatusChanged<T>? onStatusChanged,
    required FormeFieldInitialized<T>? onInitialized,
    required FormeFieldSetter<T>? onSaved,
    required bool quietlyValidate,
    required Duration? asyncValidatorDebounce,
    required FormeValidator<T>? validator,
    required FormeAsyncValidator<T>? asyncValidator,
    required AutovalidateMode? autovalidateMode,
    required FormeFieldValidationFilter<T>? validationFilter,
    required FocusNode? focusNode,
    required FormeFieldDecorator<T>? decorator,
  }) : this(
          key: key,
          name: name,
          readOnly: readOnly,
          builder: builder,
          enabled: enabled,
          initialValue: initialValue,
          order: order,
          requestFocusOnUserInteraction: requestFocusOnUserInteraction,
          onStatusChanged: onStatusChanged,
          onInitialized: onInitialized,
          onSaved: onSaved,
          quietlyValidate: quietlyValidate,
          asyncValidatorDebounce: asyncValidatorDebounce,
          validator: validator,
          asyncValidator: asyncValidator,
          autovalidateMode: autovalidateMode,
          validationFilter: validationFilter,
          focusNode: focusNode,
          decorator: decorator,
        );

  const FormeField({
    Key? key,
    this.validator,
    this.name,
    this.readOnly = false,
    required this.builder,
    this.enabled = true,
    required this.initialValue,
    AutovalidateMode? autovalidateMode,
    this.order,
    this.requestFocusOnUserInteraction = true,
    this.onStatusChanged,
    this.onInitialized,
    this.onSaved,
    this.quietlyValidate = false,
    this.asyncValidatorDebounce,
    this.asyncValidator,
    this.validationFilter,
    this.focusNode,
    this.decorator,
  })  : autovalidateMode = autovalidateMode ?? AutovalidateMode.disabled,
        super(key: key);

  @override
  FormeFieldState<T> createState() => FormeFieldState();

  static FormeFieldState<T>? of<T>(BuildContext context) {
    final FormeFieldState? controller = FormeFieldScope.of(context);
    if (controller == null) {
      return null;
    }
    return controller as FormeFieldState<T>;
  }
}
