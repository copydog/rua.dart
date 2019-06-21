import 'package:rua/src/context/application_context.dart';
import 'package:rua/src/context/configurable_application_context.dart';
import 'package:rua/src/context/lifecycle_processor.dart';
import 'package:rua/src/lang/illegal_state_exception.dart';

class AbstractApplicationContext implements ConfigurableApplicationContext {
  String _id;

  String _displayName;

  String _applicationName;

  /// System time in milliseconds when this context started
  int _startupDate;

  ApplicationContext _parent;

  bool active;

  bool closed;

  LifecycleProcessor _lifecycleProcessor;

  @override
  void close() {
    _doClose();
    // todo: shutdown hook
  }

  void _doClose() {
    active = false;
  }

  @override
  String getApplicationName() => _applicationName;

  @override
  String getDisplayName() => _displayName;

  @override
  String getId() => _id;

  @override
  ApplicationContext getParent() => _parent;

  @override
  int getStartupDate() => _startupDate;

  @override
  bool isRunning() {
    return _lifecycleProcessor != null && _lifecycleProcessor.isRunning();
  }

  LifecycleProcessor getLifecycleProcessor() {
    if (_lifecycleProcessor == null) {
      throw new IllegalStateException("LifecycleProcessor not initialized - " +
          "call 'refresh' before invoking lifecycle methods via the context: " +
          toString());
    }

    return _lifecycleProcessor;
  }

  @override
  void start() {
    getLifecycleProcessor().start();
  }

  @override
  void stop() {
    getLifecycleProcessor().stop();
  }
}
