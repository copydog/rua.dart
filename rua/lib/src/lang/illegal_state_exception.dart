import 'package:rua/src/lang/runtime_exception.dart';

class IllegalStateException extends RuntimeException {
  IllegalStateException(String message) : super.withMessage(message);
}
