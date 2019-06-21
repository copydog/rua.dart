abstract class BeanFactory {
  /// Does this bean factory contain a bean definition or externally
  /// registered singleton instance with the given name?
  bool containsBean(String name);
}
