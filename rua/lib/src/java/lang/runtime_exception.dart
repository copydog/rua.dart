import 'package:rua/src/java/lang/enhanced_exception.dart';

class RuntimeException extends EnhancedException {
  String message;

  RuntimeException() : super();

  RuntimeException.withCause(Object cause) : super.withCause(cause);

  RuntimeException.withMessage(String message) : super.withMessage(message);

  RuntimeException.withMessageAndCause(String cause, Object message)
      : super.withMessageAndCause(cause, message);
}
