abstract class Lifecycle {
  /// Stop this component, typically in a synchronous fashion, such that the
  /// component is fully stopped upon return of this method.
  void start();

  /// Start this component.
  void stop();

  /// Check whether this component is currently running.
  bool isRunning();
}
