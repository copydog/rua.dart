import 'package:rua/src/java/lang/runtime_exception.dart';

class IllegalStateException extends RuntimeException {
  IllegalStateException(String message) : super.withMessage(message);
}
