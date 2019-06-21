/**
 * Interface to be implemented by bean metadata elements
 * that carry a configuration source object.
 */
abstract class BeanMetadataElement {
  /**
   * Return the configuration source {@code Object} for this metadata element
   * (may be {@code null}).
   */
  Object getSource();
}
