import 'package:rua/src/beans/factory/bean_creation_exception.dart';

/**
 * Exception thrown in case of a bean being requested despite
 * bean creation currently not being allowed (for example, during
 * the shutdown phase of a bean factory).
 *
 * @author Juergen Hoeller
 * @since 2.0
 */
class BeanCreationNotAllowedException extends BeanCreationException {
  /**
   * Create a new BeanCreationNotAllowedException.
   * @param beanName the name of the bean requested
   * @param msg the detail message
   */
  BeanCreationNotAllowedException.withBeanNameAndMessage(String beanName, String message)
      : super.withBeanNameAndMessage(beanName, message);
}
