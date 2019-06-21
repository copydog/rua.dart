import 'package:rua/src/beans/factory/bean_creation_exception.dart';

/**
 * Exception thrown in case of a reference to a bean that's currently in creation.
 * Typically happens when constructor autowiring matches the currently constructed bean.
 *
 * @author Juergen Hoeller
 * @since 1.1
 */
class BeanCurrentlyInCreationException extends BeanCreationException {
  /**
   * Create a new BeanCurrentlyInCreationException,
   * with a default error message that indicates a circular reference.
   * @param beanName the name of the bean requested
   */
  BeanCurrentlyInCreationException.withBeanName(String beanName)
      : super.withBeanNameAndMessage(beanName,
            "Requested bean is currently in creation: Is there an unresolvable circular reference?");

  /**
   * Create a new BeanCurrentlyInCreationException.
   * @param beanName the name of the bean requested
   * @param msg the detail message
   */
  BeanCurrentlyInCreationException.withBeanNameAndMessage(String beanName, String msg)
      : super.withBeanNameAndMessage(beanName, msg);
}
