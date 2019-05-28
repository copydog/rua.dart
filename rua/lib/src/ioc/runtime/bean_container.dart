import 'package:get_it/get_it.dart';

typedef FactoryFunc<T> = T Function();

/// Dependency injection container
///
/// All the injection will be register in the container
class BeanContainer {
  /// using GetIt as di
  GetIt _getIt = GetIt()..allowReassignment = true;

  void registerFactory<T>(FactoryFunc<T> func) {
    _getIt.registerFactory<T>(func);
  }

  void registerSingleton<T>(T instance) {
    _getIt.registerSingleton<T>(instance);
  }

  void registerLazySingleton<T>(FactoryFunc<T> func) {
    _getIt.registerLazySingleton<T>(func);
  }

  T get<T>() {
    return _getIt.get<T>();
  }

  void reset() {
    _getIt.reset();
  }
}

BeanContainer container = new BeanContainer();
