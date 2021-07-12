import 'package:formz/formz.dart';

enum TextValidationError { invalid }

class Text extends FormzInput<String, TextValidationError> {
  const Text.pure() : super.pure('');
  const Text.dirty([String value = '']) : super.dirty(value);

  @override
  TextValidationError? validator(String? value) {
    return value != '' ? null : TextValidationError.invalid;
  }
}
