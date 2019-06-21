import 'package:rua/src/core/auto_closable.dart';

/// A Closeable is a source or destination of data that can be closed. The close method is invoked
/// to release resources that the object is holding (such as open files).
abstract class Closable implements AutoClosable {
  /// Closes this stream and releases any system resources associated with it.
}
