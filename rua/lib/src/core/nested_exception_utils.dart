import 'package:rua/src/core/nullable.dart';

/**
 * Helper class for implementing exception classes which are capable of
 * holding nested exceptions. Necessary because we can't share a base
 * class among different exception types.
 *
 * <p>Mainly for use within the framework.
 *
 * @author Juergen Hoeller
 * @since 2.0
 * @see NestedRuntimeException
 * @see NestedCheckedException
 * @see NestedIOException
 * @see org.springframework.web.util.NestedServletException
 */
abstract class NestedExceptionUtils {
  /**
   * Build a message for the given base message and root cause.
   * @param message the base message
   * @param cause the root cause
   * @return the full exception message
   */
  @Nullable()
  static String buildMessage(@Nullable() String message, @Nullable() Exception cause) {
    if (cause == null) {
      return message;
    }
    StringBuffer sb = new StringBuffer();
    if (message != null) {
      sb..write(message)..write("; ");
    }
    sb..write("nested exception is ")..write(cause);
    return sb.toString();
  }

  /**
   * Retrieve the innermost cause of the given exception, if any.
   * @param original the original exception to introspect
   * @return the innermost exception, or {@code null} if none
   * @since 4.3.9
   */
  @Nullable()
  static Exception getRootCause(@Nullable() Exception original) {
    return original;
  }

  /**
   * Retrieve the most specific cause of the given exception, that is,
   * either the innermost cause (root cause) or the exception itself.
   * <p>Differs from {@link #getRootCause} in that it falls back
   * to the original exception if there is no root cause.
   * @param original the original exception to introspect
   * @return the most specific cause (never {@code null})
   * @since 4.3.9
   */
  static Exception getMostSpecificCause(Exception original) {
    Exception rootCause = getRootCause(original);
    return (rootCause != null ? rootCause : original);
  }
}
