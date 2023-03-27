import '../../forme.dart';

class FormeValidateSnapshot {
  final List<FormeFieldValidateSnapshot> _snapshots;

  FormeValidateSnapshot(this._snapshots);

  /// get first invalid field
  FormeFieldValidateSnapshot? get firstInvalidField {
    final Iterable<FormeFieldValidateSnapshot> iterable = invalidFields;
    if (iterable.isNotEmpty) {
      return iterable.first;
    }
    return null;
  }

  /// all field is valid
  bool get isValid => _snapshots.every((element) => element.isValid);

  /// get all invalid fields
  Iterable<FormeFieldValidateSnapshot> get invalidFields =>
      _snapshots.where((element) => element.isInvalid);

  /// get validated data
  ///
  /// **when you want to submit a form after all validation passed,
  /// you should use form data from this method rather than [FormeKey.data] due to
  /// form data may be changed during async validation**
  ///
  /// use [isValueChangedDuringValidation] to check whether form data changed during async validation
  Map<String, dynamic> get value => _snapshots
      .where((element) => element.name != null)
      .toList()
      .asMap()
      .map<String, dynamic>(
          (key, value) => MapEntry<String, dynamic>(value.name!, value.value));

  /// whether form' value changed after validation
  bool get isValueChangedAfterValidation =>
      _snapshots.any((element) => element.isValueChangedAfterValidation);

  /// whether value changed after initialized
  ///
  /// **unlike [FormeState.isValueChanged] , this method is compare snapshot value and initialValue**
  bool get isValueChanged =>
      _snapshots.any((element) => element.isValueChanged);

  FormeValidation get validation {
    return FormeValidation(_snapshots
        .where((element) => element.name != null)
        .toList()
        .asMap()
        .map((key, value) => MapEntry(value.name!, value.validation)));
  }
}

/// used to hold  validate result and validated value
///
/// since value may be changed during async validation
class FormeFieldValidateSnapshot<T> {
  /// validated value , may not equals the field's value
  final T value;

  /// validation , may not equals the field's current validation  if performed another validate during async validation
  final FormeFieldValidation validation;

  /// name of field
  final String? name;

  final FormeFieldState<T> field;

  FormeFieldValidateSnapshot(
    this.value,
    this.validation,
    this.name,
    this.field,
  );

  bool get isValueChangedAfterValidation =>
      !field.isValueEquals(value, field.value);

  /// whether value changed after initialized
  ///
  /// **unlike [FormeFieldState.isValueChanged] , this method is compare snapshot value and initialValue**
  bool get isValueChanged => !field.isValueEquals(field.initialValue, value);

  /// whether field is invalid
  bool get isInvalid => validation.isInvalid;
  bool get isValid => validation.isValid;
}
