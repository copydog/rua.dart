import 'package:rua/src/beans/factory/config/configurable_bean_factory.dart';
import 'package:rua/src/core/attribute_accessor.dart';
import 'package:rua/src/core/bean_metadata_element.dart';

abstract class BeanDefinition implements AttributeAccessor, BeanMetadataElement {
  /**
   * Scope identifier for the standard singleton scope: "singleton".
   * <p>Note that extended bean factories might support further scopes.
   * @see #setScope
   */
  String SCOPE_SINGLETON = ConfigurableBeanFactory.SCOPE_SINGLETON;

  /**
   * Scope identifier for the standard prototype scope: "prototype".
   * <p>Note that extended bean factories might support further scopes.
   * @see #setScope
   */
  String SCOPE_PROTOTYPE = ConfigurableBeanFactory.SCOPE_PROTOTYPE;
}
