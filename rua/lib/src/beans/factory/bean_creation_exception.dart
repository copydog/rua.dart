import 'package:rua/src/beans/fatal_bean_exception.dart';
import 'package:rua/src/core/nullable.dart';

class BeanCreationException extends FatalBeanException {
  final String _beanName;

  final String _resourceDescription;

  List<Object> _relatedCauses;

  BeanCreationException.withMessage(
    String message, [
    this._beanName,
    this._resourceDescription,
  ]) : super.withMessage(message);

  BeanCreationException.withMessageAndCause(
    String message,
    Object cause, [
    this._beanName,
    this._resourceDescription,
  ]) : super.withMessageAndCause(message, cause);

  BeanCreationException.withBeanNameAndMessage(
    this._beanName,
    String message, [
    this._resourceDescription,
  ]) : super.withMessage(message);

  BeanCreationException.withBeanNameAndMessageAndCause(
    this._beanName,
    String message,
    Object cause, [
    this._resourceDescription,
  ]) : super.withMessageAndCause(message, cause);

  /**
   * Return the description of the resource that the bean
   * definition came from, if any.
   */
  @Nullable()
  String getResourceDescription() {
    return _resourceDescription;
  }

  /**
   * Return the name of the bean requested, if any.
   */
  @Nullable()
  String getBeanName() {
    return _beanName;
  }

  /**
   * Add a related cause to this bean creation exception,
   * not being a direct cause of the failure but having occurred
   * earlier in the creation of the same bean instance.
   * @param ex the related cause to add
   */
  void addRelatedCause(Object ex) {
    if (_relatedCauses == null) {
      _relatedCauses = List();
    }
    _relatedCauses.add(ex);
  }

  /**
   * Return the related causes, if any.
   * @return the array of related causes, or {@code null} if none
   */
  @Nullable()
  List<Object> getRelatedCauses() {
    return _relatedCauses;
  }
}
