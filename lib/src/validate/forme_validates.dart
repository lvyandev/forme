import '../../forme.dart';

/// validators for [Forme]
class FormeValidates {
  FormeValidates._();

//https://stackoverflow.com/a/50663835/7514037
  static const String emailPattern =
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";

  /// when valid:
  ///
  /// 1. value is null
  /// 2. value == given value
  static FormeValidator<T> equals<T>(T value, {String errorText = ''}) {
    return (f, T v) => value == null || v == value ? null : errorText;
  }

  /// when valid
  ///
  /// 1. value is not null
  static FormeValidator<T> notNull<T>({String errorText = ''}) {
    return (f, T v) => v == null ? errorText : null;
  }

  /// when valid
  ///
  /// 1. value is null
  /// 2. min == null && max == null
  /// 3. value's length is > min and < max
  static FormeValidator<T> size<T>(
      {String errorText = '', int? min, int? max}) {
    return (f, T v) {
      if (v == null) {
        return null;
      }
      if (min == null && max == null) {
        return null;
      }

      return _validateSize(_getLength(v), min, max, errorText: errorText);
    };
  }

  /// when valid
  ///
  /// 1. value is null
  /// 2. value is >= min
  static FormeValidator<T> min<T>(double min, {String errorText = ''}) {
    return (f, T v) => (v != null && v as num < min) ? errorText : null;
  }

  /// when valid
  ///
  /// 1. value is null
  /// 2. value is <= max
  static FormeValidator<T> max<T>(double max, {String errorText = ''}) {
    return (f, dynamic v) => (v != null && v as num > max) ? errorText : null;
  }

  /// when valid:
  ///
  /// 1. value is null
  /// 2. value >= min && value <= max
  static FormeValidator<T> range<T>(double min, double max,
      {String errorText = ''}) {
    return (f, T v) =>
        (v == null || (v as num >= min && v <= max)) ? null : errorText;
  }

  /// when valid
  ///
  /// 1. value is null
  /// 2. value's length > 0
  static FormeValidator<T> notEmpty<T>({String errorText = ''}) {
    return (f, T v) {
      if (v == null) {
        return errorText;
      }
      if (_getLength(v) == 0) {
        return errorText;
      }
      return null;
    };
  }

  /// when valid
  ///
  /// 1. value is null
  /// 2. value's length(after trim) > 0
  static FormeValidator<T> notBlank<T>({String errorText = ''}) {
    return (f, T v) {
      if (v == null) {
        return null;
      }
      return (v as String).trim().isNotEmpty ? null : errorText;
    };
  }

  /// when valid
  ///
  /// 1. value is null
  /// 2. value > 0
  static FormeValidator<T> positive<T>({String errorText = ''}) {
    return (f, T v) {
      if (v == null) {
        return null;
      }
      return v as num > 0 ? null : errorText;
    };
  }

  /// when valid
  ///
  /// 1. value is null
  /// 2. value >= 0
  static FormeValidator<T> positiveOrZero<T>({String errorText = ''}) {
    return (f, T v) {
      if (v == null) {
        return null;
      }
      return v as num >= 0 ? null : errorText;
    };
  }

  /// when valid
  ///
  /// 1. value is null
  /// 2. value < 0
  static FormeValidator<T> negative<T>({String errorText = ''}) {
    return (f, T v) {
      if (v == null) {
        return null;
      }
      return v as num < 0 ? null : errorText;
    };
  }

  /// when valid
  ///
  /// 1. value is null
  /// 2. value <= 0
  static FormeValidator<T> negativeOrZero<T>({String errorText = ''}) {
    return (f, T v) {
      if (v == null) {
        return null;
      }
      return v as num <= 0 ? null : errorText;
    };
  }

  /// when valid
  ///
  /// 1. value is null
  /// 2. value match pattern
  static FormeValidator<T> pattern<T>(String pattern, {String errorText = ''}) {
    return (f, T v) {
      if (v == null) {
        return null;
      }
      final bool isValid = RegExp(pattern).hasMatch(v as String);
      if (!isValid) {
        return errorText;
      }
      return null;
    };
  }

  /// when valid
  ///
  /// 1. value is null
  /// 2. value is an email
  static FormeValidator<T> email<T>({String errorText = ''}) {
    return pattern(emailPattern, errorText: errorText);
  }

  /// when valid
  ///
  /// 1. value is null
  /// 2. value is an url
  static FormeValidator<T> url<T>({
    String errorText = '',
    String? schema,
    String? host,
    int? port,
  }) {
    return (f, T v) {
      if (v == null || (v as String).isEmpty) {
        return null;
      }

      final Uri? uri = Uri.tryParse(v);
      if (uri == null) {
        return errorText;
      }

      if (schema != null && schema.isNotEmpty && !uri.isScheme(schema)) {
        return errorText;
      }
      if (host != null && host.isNotEmpty && uri.host != host) {
        return errorText;
      }
      if (port != null && uri.port != port) {
        return errorText;
      }

      return null;
    };
  }

  /// when valid
  ///
  /// 1. any validator return null
  static FormeValidator<T> any<T>(List<FormeValidator<T>> validators,
      {String errorText = ''}) {
    return (f, T v) {
      for (final FormeValidator<T> validator in validators) {
        if (validator(f, v) == null) {
          return null;
        }
      }
      return errorText;
    };
  }

  /// when valid
  ///
  /// 1. every validator return null
  static FormeValidator<T> all<T>(List<FormeValidator<T>> validators,
      {String errorText = ''}) {
    return (f, T v) {
      for (final FormeValidator<T> validator in validators) {
        final String? resultText = validator(f, v);
        if (resultText != null) {
          return resultText == '' ? errorText : resultText;
        }
      }
      return null;
    };
  }

  static String? _validateSize(int length, int? min, int? max,
      {String errorText = ''}) {
    if (min != null && min > length) {
      return errorText;
    }
    if (max != null && max < length) {
      return errorText;
    }
    return null;
  }
}

int _getLength(dynamic v) {
  if (v is Iterable) {
    return v.length;
  }
  if (v is Map) {
    return v.length;
  }

  if (v is String) {
    return v.length;
  }

  throw Exception(
      'only support Iterator|Map|String , current type is ${v.runtimeType}');
}
