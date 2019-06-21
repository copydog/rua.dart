import 'package:rua/src/core/nested_exception_utils.dart';
import 'package:rua/src/core/nullable.dart';
import 'package:rua/src/lang/enhanced_exception.dart';
import 'package:rua/src/lang/runtime_exception.dart';

/**
 * Handy class for wrapping runtime {@code Exceptions} with a root cause.
 *
 * <p>This class is {@code abstract} to force the programmer to extend
 * the class. {@code getMessage} will include nested exception
 * information; {@code printStackTrace} and other like methods will
 * delegate to the wrapped exception, if any.
 *
 * <p>The similarity between this class and the {@link NestedCheckedException}
 * class is unavoidable, as Java forces these two classes to have different
 * superclasses (ah, the inflexibility of concrete inheritance!).
 *
 * @author Rod Johnson
 * @author Juergen Hoeller
 * @see #getMessage
 * @see #printStackTrace
 * @see NestedCheckedException
 */
abstract class NestedRuntimeException extends RuntimeException {
  /**
   * Construct a {@code NestedRuntimeException} with the specified detail message.
   * @param msg the detail message
   */
  NestedRuntimeException.withMessage(String message) : super.withMessage(message);

  /**
   * Construct a {@code NestedRuntimeException} with the specified detail message
   * and nested exception.
   * @param msg the detail message
   * @param cause the nested exception
   */
  NestedRuntimeException.withMessageAndCause(String cause, Object message)
      : super.withMessageAndCause(cause, message);

  @override
  @Nullable()
  String getMessage() {
    return NestedExceptionUtils.buildMessage(super.getMessage(), getCause());
  }

  /**
   * Retrieve the innermost cause of this exception, if any.
   * @return the innermost exception, or {@code null} if none
   * @since 2.0
   */
  @Nullable()
  Object getRootCause() {
    return NestedExceptionUtils.getRootCause(this);
  }

  /**
   * Retrieve the most specific cause of this exception, that is,
   * either the innermost cause (root cause) or this exception itself.
   * <p>Differs from {@link #getRootCause()} in that it falls back
   * to the present exception if there is no root cause.
   * @return the most specific cause (never {@code null})
   * @since 2.0.3
   */
  Object getMostSpecificCause() {
    Object rootCause = getRootCause();
    return (rootCause != null ? rootCause : this);
  }

  /**
   * Check whether this exception contains an exception of the given type:
   * either it is of the given class itself or it contains a nested cause
   * of the given type.
   * @param exType the exception type to look for
   * @return whether there is a nested exception of the specified type
   */
  bool contains(@Nullable() Type exType) {
    if (exType == null) {
      return false;
    }
    if (exType == this.runtimeType) {
      return true;
    }

    Object cause = getCause();
    if (cause == this) {
      return false;
    }
    if (cause is NestedRuntimeException) {
      return cause.contains(exType);
    } else {
      while (cause != null) {
        if (exType == cause.runtimeType) {
          return true;
        }
        if (cause is! EnhancedException) {
          break;
        }

        if ((cause as EnhancedException).getCause() == cause) {
          break;
        }
        cause = (cause as EnhancedException).getCause();
      }
      return false;
    }
  }
}
