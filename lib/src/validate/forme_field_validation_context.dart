import 'package:junny_forme/forme.dart';

class FormeFieldValidationContext<T> {
  /// current validate field
  final FormeFieldState<T> field;

  /// current form
  final FormeState? form;

  /// latest successful validation value
  final FormeOptional<T>? latestSuccessfulValidationValue;
  final T currentValidateValue;
  final FormeOptional<T>? validatingValue;

  FormeFieldValidation get validation => field.validation;

  const FormeFieldValidationContext(
      this.field,
      this.form,
      this.latestSuccessfulValidationValue,
      this.currentValidateValue,
      this.validatingValue);
}
