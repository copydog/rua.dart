/// An object that may hold resources (such as file or socket handles) until it is closed.
/// The close() method of an AutoCloseable object is called automatically when exiting a
/// try-with-resources block for which the object has been declared in the resource specification
/// header. This construction ensures prompt release, avoiding resource exhaustion exceptions and
/// errors that may otherwise occur.
abstract class AutoClosable {
  /// Closes this resource, relinquishing any underlying resources.
  void close();
}
