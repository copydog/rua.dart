/**
 * Configuration interface to be implemented by most bean factories. Provides
 * facilities to configure a bean factory, in addition to the bean factory
 * client methods in the {@link org.springframework.beans.factory.BeanFactory}
 * interface.
 *
 * <p>This bean factory interface is not meant to be used in normal application
 * code: Stick to {@link org.springframework.beans.factory.BeanFactory} or
 * {@link org.springframework.beans.factory.ListableBeanFactory} for typical
 * needs. This extended interface is just meant to allow for framework-internal
 * plug'n'play and for special access to bean factory configuration methods.
 *
 * @author Juergen Hoeller
 * @since 03.11.2003
 * @see org.springframework.beans.factory.BeanFactory
 * @see org.springframework.beans.factory.ListableBeanFactory
 * @see ConfigurableListableBeanFactory
 */
abstract class ConfigurableBeanFactory {
  /**
   * Scope identifier for the standard singleton scope: "singleton".
   * Custom scopes can be added via {@code registerScope}.
   * @see #registerScope
   */
  static String SCOPE_SINGLETON = "singleton";

  /**
   * Scope identifier for the standard prototype scope: "prototype".
   * Custom scopes can be added via {@code registerScope}.
   * @see #registerScope
   */
  static String SCOPE_PROTOTYPE = "prototype";
}
