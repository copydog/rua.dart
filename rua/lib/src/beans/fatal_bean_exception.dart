import 'package:rua/src/beans/beans_exception.dart';

/**
 * Thrown on an unrecoverable problem encountered in the
 * beans packages or sub-packages, e.g. bad class or field.
 *
 * @author Rod Johnson
 */
class FatalBeanException extends BeansException {
  /**
   * Construct a {@code FatalBeanException} with the specified detail message.
   * @param msg the detail message
   */
  FatalBeanException.withMessage(String message) : super.withMessage(message);
  /**
   * Construct a {@code FatalBeanException} with the specified detail message
   * and nested exception.
   * @param msg the detail message
   * @param cause the nested exception
   */
  FatalBeanException.withMessageAndCause(String cause, Object message)
      : super.withMessageAndCause(cause, message);
}
