abstract class ApplicationContext {
  int getStartupDate();
  String getApplicationName();
  String getDisplayName();

  /// Return the unique id of this application context.
  /// @return the unique id of the context, or {@code null} if none
  String getId();
  ApplicationContext getParent();
}
