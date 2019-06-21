import 'package:rua/src/core/nested_runtime_exception.dart';

class BeansException extends NestedRuntimeException {
  /**
   * Construct a {@code BeansException} with the specified detail message.
   * @param msg the detail message
   */
  BeansException.withMessage(String message) : super.withMessage(message);
  /**
   * Construct a {@code BeansException} with the specified detail message
   * and nested exception.
   * @param msg the detail message
   * @param cause the nested exception
   */
  BeansException.withMessageAndCause(String cause, Object message)
      : super.withMessageAndCause(cause, message);
}
