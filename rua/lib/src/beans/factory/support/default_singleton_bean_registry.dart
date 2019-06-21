import 'package:rua/src/beans/factory/bean_creation_exception.dart';
import 'package:rua/src/beans/factory/bean_currently_in_creation_exception.dart';
import 'package:rua/src/beans/factory/config/singleton_bean_registry.dart';
import 'package:rua/src/beans/factory/disposable_bean.dart';
import 'package:rua/src/beans/factory/object_factory.dart';
import 'package:rua/src/core/nullable.dart';
import 'package:rua/src/core/simple_alias_registry.dart';
import 'package:rua/src/lang/illegal_state_exception.dart';

/**
 * Generic registry for shared bean instances, implementing the
 * {@link org.springframework.beans.factory.config.SingletonBeanRegistry}.
 * Allows for registering singleton instances that should be shared
 * for all callers of the registry, to be obtained via bean name.
 *
 * <p>Also supports registration of
 * {@link org.springframework.beans.factory.DisposableBean} instances,
 * (which might or might not correspond to registered singletons),
 * to be destroyed on shutdown of the registry. Dependencies between
 * beans can be registered to enforce an appropriate shutdown order.
 *
 * <p>This class mainly serves as base class for
 * {@link org.springframework.beans.factory.BeanFactory} implementations,
 * factoring out the common management of singleton bean instances. Note that
 * the {@link org.springframework.beans.factory.config.ConfigurableBeanFactory}
 * interface extends the {@link SingletonBeanRegistry} interface.
 *
 * <p>Note that this class assumes neither a bean definition concept
 * nor a specific creation process for bean instances, in contrast to
 * {@link AbstractBeanFactory} and {@link DefaultListableBeanFactory}
 * (which inherit from it). Can alternatively also be used as a nested
 * helper to delegate to.
 *
 * @author Juergen Hoeller
 * @since 2.0
 * @see #registerSingleton
 * @see #registerDisposableBean
 * @see org.springframework.beans.factory.DisposableBean
 * @see org.springframework.beans.factory.config.ConfigurableBeanFactory
 */
class DefaultSingletonBeanRegistry extends SimpleAliasRegistry implements SingletonBeanRegistry {
  /** Cache of singleton objects: bean name to bean instance. */
  final Map<String, Object> _singletonObjects = Map();

  /** Cache of singleton factories: bean name to ObjectFactory. */
  final Map<String, ObjectFactory> _singletonFactories = Map();

  /** Cache of early singleton objects: bean name to bean instance. */
  final Map<String, Object> _earlySingletonObjects = Map();

  /** Set of registered singletons, containing the bean names in registration order. */
  final Set<String> _registeredSingletons = Set();

  /** Names of beans that are currently in creation. */
  final Set<String> _singletonsCurrentlyInCreation = Set();

  /** Names of beans currently excluded from in creation checks. */
  final Set<String> _inCreationCheckExclusions = Set();

  Set<Exception> _suppressedExceptions;

  /** Flag that indicates whether we're currently within destroySingletons. */
  bool _singletonsCurrentlyInDestruction = false;

  /** Disposable bean instances: bean name to disposable instance. */
  Map<String, Object> _disposableBeans = Map();

  /** Map between containing bean names: bean name to Set of bean names that the bean contains. */
  Map<String, Set<String>> _containedBeanMap = Map();

  /** Map between dependent bean names: bean name to Set of dependent bean names. */
  Map<String, Set<String>> _dependentBeanMap = Map();

  /** Map between depending bean names: bean name to Set of bean names for the bean's dependencies. */
  Map<String, Set<String>> _dependenciesForBeanMap = Map();

  /**
   * Add the given singleton object to the singleton cache of this factory.
   * <p>To be called for eager registration of singletons.
   * @param beanName the name of the bean
   * @param singletonObject the singleton object
   */
  void addSingleton(String beanName, Object singletonObject) {
    _singletonObjects[beanName] = singletonObject;
    _singletonFactories.remove(beanName);
    _earlySingletonObjects.remove(beanName);
    _registeredSingletons.add(beanName);
  }

  /**
   * Add the given singleton factory for building the specified singleton
   * if necessary.
   * <p>To be called for eager registration of singletons, e.g. to be able to
   * resolve circular references.
   * @param beanName the name of the bean
   * @param singletonFactory the factory for the singleton object
   */
  void addSingletonFactory(String beanName, ObjectFactory singletonFactory) {
    assert(singletonFactory != null, "Singleton factory must not be null");
    if (!_singletonObjects.containsKey(beanName)) {
      _singletonFactories[beanName] = singletonFactory;
      _earlySingletonObjects.remove(beanName);
      _registeredSingletons.add(beanName);
    }
  }

  Object getSingleton_(String beanName, bool allowEarlyReference) {
    Object singletonObject = _singletonObjects[beanName];

    if (singletonObject == null && isSingletonCurrentlyInCreation(beanName)) {
      synchronized(_singletonObjects) {
        singletonObject = _earlySingletonObjects[beanName];
        if (singletonObject == null && allowEarlyReference) {
          ObjectFactory singletonFactory = _singletonFactories[beanName];
          if (singletonFactory != null) {
            singletonObject = singletonFactory.getObject();
            _earlySingletonObjects[beanName] = singletonObject;
            _singletonFactories.remove(beanName);
          }
        }
      }
    }
    return singletonObject;
  }

  /**
   * Return the (raw) singleton object registered under the given name,
   * creating and registering a new one if none registered yet.
   * @param beanName the name of the bean
   * @param singletonFactory the ObjectFactory to lazily create the singleton
   * with, if necessary
   * @return the registered singleton object
   */
  Object getSingleton__(String beanName, ObjectFactory singletonFactory) {
    assert(beanName != null, "Bean name must not be null");

    Object singletonObject = _singletonObjects[beanName];

    if (singletonObject == null) {
      if (_singletonsCurrentlyInDestruction) {
//        throw new BeanCreationNotAllowedException(beanName,
//            "Singleton bean creation not allowed while singletons of this factory are in destruction " +
//                "(Do not request a bean from a BeanFactory in a destroy method implementation!)");
      }
//      if (logger.isDebugEnabled()) {
//        logger.debug("Creating shared instance of singleton bean '" + beanName + "'");
//      }
      beforeSingletonCreation(beanName);
      bool newSingleton = false;
      bool recordSuppressedExceptions = (_suppressedExceptions == null);
      if (recordSuppressedExceptions) {
        _suppressedExceptions = new Set();
      }
      try {
        singletonObject = singletonFactory.getObject();
        newSingleton = true;
      } on IllegalStateException catch (ex) {
        // Has the singleton object implicitly appeared in the meantime ->
        // if yes, proceed with it since the exception indicates that state.
        singletonObject = _singletonObjects[beanName];
        if (singletonObject == null) {
          throw ex;
        }
      } on BeanCreationException catch (ex) {
        if (recordSuppressedExceptions) {
          for (Exception suppressedException in _suppressedExceptions) {
            ex.addRelatedCause(suppressedException);
          }
        }
        throw ex;
      } finally {
        if (recordSuppressedExceptions) {
          _suppressedExceptions = null;
        }
        afterSingletonCreation(beanName);
      }
      if (newSingleton) {
        addSingleton(beanName, singletonObject);
      }
    }
  }

  /**
   * Register an Exception that happened to get suppressed during the creation of a
   * singleton bean instance, e.g. a temporary circular reference resolution problem.
   * @param ex the Exception to register
   */
  void onSuppressedException(Exception ex) {
    if (_suppressedExceptions != null) {
      _suppressedExceptions.add(ex);
    }
  }

  /**
   * Remove the bean with the given name from the singleton cache of this factory,
   * to be able to clean up eager registration of a singleton if creation failed.
   * @param beanName the name of the bean
   * @see #getSingletonMutex()
   */
  void removeSingleton(String beanName) {
    _singletonObjects.remove(beanName);
    _singletonFactories.remove(beanName);
    _earlySingletonObjects.remove(beanName);
    _registeredSingletons.remove(beanName);
  }

  //---------------------------------------------------------------------
  // Implementation of SingletonBeanRegistry
  //---------------------------------------------------------------------

  @override
  bool containsSingleton(String beanName) {
    return _singletonObjects.containsKey(beanName);
  }

  @override
  Object getSingleton(String beanName) {
    return _singletonObjects[beanName];
    // todo: simplified
  }

  @override
  int getSingletonCount() {
    return _singletonObjects.length;
  }

  @override
  Object getSingletonMutex() {
    return _singletonObjects;
  }

  @override
  List<String> getSingletonNames() {
    return _registeredSingletons.toList();
  }

  @override
  void registerSingleton(String beanName, Object singletonObject) {
    assert(beanName != null, "Bean name must not be null");
    assert(singletonObject != null, "Singleton object must not be null");
    Object oldObject = _singletonObjects[beanName];
    if (oldObject != null) {
      throw new IllegalStateException("Could not register object [" +
          singletonObject +
          "] under bean name '" +
          beanName +
          "': there is already object [" +
          oldObject +
          "] bound");
    }
    addSingleton(beanName, singletonObject);
  }

  void setCurrentlyInCreation(String beanName, bool inCreation) {
    assert(beanName != null, "Bean name must not be null");
    if (!inCreation) {
      _inCreationCheckExclusions.add(beanName);
    } else {
      _inCreationCheckExclusions.remove(beanName);
    }
  }

  bool isCurrentlyInCreation(String beanName) {
    assert(beanName != null, "Bean name must not be null");
    return (!_inCreationCheckExclusions.contains(beanName) && isActuallyInCreation(beanName));
  }

  bool isActuallyInCreation(String beanName) {
    return isSingletonCurrentlyInCreation(beanName);
  }

  /**
   * Return whether the specified singleton bean is currently in creation
   * (within the entire factory).
   * @param beanName the name of the bean
   */
  bool isSingletonCurrentlyInCreation(String beanName) {
    return _singletonsCurrentlyInCreation.contains(beanName);
  }

  /**
   * Callback before singleton creation.
   * <p>The default implementation register the singleton as currently in creation.
   * @param beanName the name of the singleton about to be created
   * @see #isSingletonCurrentlyInCreation
   */
  void beforeSingletonCreation(String beanName) {
    if (!_inCreationCheckExclusions.contains(beanName) &&
        !_singletonsCurrentlyInCreation.add(beanName)) {
      throw new BeanCurrentlyInCreationException.withBeanName(beanName);
    }
  }

  /**
   * Callback after singleton creation.
   * <p>The default implementation marks the singleton as not in creation anymore.
   * @param beanName the name of the singleton that has been created
   * @see #isSingletonCurrentlyInCreation
   */
  void afterSingletonCreation(String beanName) {
    if (!_inCreationCheckExclusions.contains(beanName) &&
        !_singletonsCurrentlyInCreation.remove(beanName)) {
      throw new IllegalStateException("Singleton '" + beanName + "' isn't currently in creation");
    }
  }

  /**
   * Add the given bean to the list of disposable beans in this registry.
   * <p>Disposable beans usually correspond to registered singletons,
   * matching the bean name but potentially being a different instance
   * (for example, a DisposableBean adapter for a singleton that does not
   * naturally implement Spring's DisposableBean interface).
   * @param beanName the name of the bean
   * @param bean the bean instance
   */
  void registerDisposableBean(String beanName, DisposableBean bean) {
    _disposableBeans[beanName] = bean;
  }

  /**
   * Register a containment relationship between two beans,
   * e.g. between an inner bean and its containing outer bean.
   * <p>Also registers the containing bean as dependent on the contained bean
   * in terms of destruction order.
   * @param containedBeanName the name of the contained (inner) bean
   * @param containingBeanName the name of the containing (outer) bean
   * @see #registerDependentBean
   */
  void registerContainedBean(String containedBeanName, String containingBeanName) {
    Set<String> containedBeans = _containedBeanMap[containingBeanName] ?? Set();
    if (!containedBeans.add(containedBeanName)) {
      return;
    }
    registerDependentBean(containedBeanName, containingBeanName);
  }

  /**
   * Register a dependent bean for the given bean,
   * to be destroyed before the given bean is destroyed.
   * @param beanName the name of the bean
   * @param dependentBeanName the name of the dependent bean
   */
  void registerDependentBean(String beanName, String dependentBeanName) {
    String canonicalName = this.canonicalName(beanName);

    Set<String> dependentBeans = _dependentBeanMap[canonicalName] ?? Set();
    if (!dependentBeans.add(dependentBeanName)) {
      return;
    }

    Set<String> dependenciesForBean = _dependenciesForBeanMap[dependentBeanName] ?? Set();
    dependenciesForBean.add(canonicalName);
  }

  /**
   * Determine whether the specified dependent bean has been registered as
   * dependent on the given bean or on any of its transitive dependencies.
   * @param beanName the name of the bean to check
   * @param dependentBeanName the name of the dependent bean
   * @since 4.0
   */
  bool isDependent(String beanName, String dependentBeanName) {
    return _isDependent_(beanName, dependentBeanName, null);
  }

  bool _isDependent_(
      String beanName, String dependentBeanName, @Nullable() Set<String> alreadySeen) {
    if (alreadySeen != null && alreadySeen.contains(beanName)) {
      return false;
    }
    String canonicalName = this.canonicalName(beanName);
    Set<String> dependentBeans = _dependentBeanMap[canonicalName];
    if (dependentBeans == null) {
      return false;
    }
    if (dependentBeans.contains(dependentBeanName)) {
      return true;
    }
    for (String transitiveDependency in dependentBeans) {
      if (alreadySeen == null) {
        alreadySeen = new Set();
      }
      alreadySeen.add(beanName);
      if (_isDependent_(transitiveDependency, dependentBeanName, alreadySeen)) {
        return true;
      }
    }
    return false;
  }

  /**
   * Determine whether a dependent bean has been registered for the given name.
   * @param beanName the name of the bean to check
   */
  bool hasDependentBean(String beanName) {
    return _dependentBeanMap.containsKey(beanName);
  }

  /**
   * Return the names of all beans which depend on the specified bean, if any.
   * @param beanName the name of the bean
   * @return the array of dependent bean names, or an empty array if none
   */
  List<String> getDependentBeans(String beanName) {
    Set<String> dependentBeans = _dependentBeanMap[beanName];
    if (dependentBeans == null) {
      return [];
    }
    return dependentBeans.toList();
  }

  /**
   * Return the names of all beans that the specified bean depends on, if any.
   * @param beanName the name of the bean
   * @return the array of names of beans which the bean depends on,
   * or an empty array if none
   */
  List<String> getDependenciesForBean(String beanName) {
    Set<String> dependenciesForBean = _dependenciesForBeanMap[beanName];
    if (dependenciesForBean == null) {
      return [];
    }
    return dependenciesForBean.toList();
  }

  void destroySingletons() {
//    if (logger.isTraceEnabled()) {
//      logger.trace("Destroying singletons in " + this);
//    }
    _singletonsCurrentlyInDestruction = true;

    List<String> disposableBeanNames;
    disposableBeanNames = _disposableBeans.keys.toList();
    for (int i = disposableBeanNames.length - 1; i >= 0; i--) {
      destroySingleton(disposableBeanNames[i]);
    }

    _containedBeanMap.clear();
    _dependentBeanMap.clear();
    _dependenciesForBeanMap.clear();

    clearSingletonCache();
  }

  /**
   * Clear all cached singleton instances in this registry.
   * @since 4.3.15
   */
  void clearSingletonCache() {
    _singletonObjects.clear();
    _singletonFactories.clear();
    _earlySingletonObjects.clear();
    _registeredSingletons.clear();
    _singletonsCurrentlyInDestruction = false;
  }

  /**
   * Destroy the given bean. Delegates to {@code destroyBean}
   * if a corresponding disposable bean instance is found.
   * @param beanName the name of the bean
   * @see #destroyBean
   */
  void destroySingleton(String beanName) {
    // Remove a registered singleton of the given name, if any.
    removeSingleton(beanName);

    // Destroy the corresponding DisposableBean instance.
    DisposableBean disposableBean;
    synchronized(_disposableBeans) {
      disposableBean = _disposableBeans.remove(beanName) as DisposableBean;
    }

    destroyBean(beanName, disposableBean);
  }

  /**
   * Destroy the given bean. Must destroy beans that depend on the given
   * bean before the bean itself. Should not throw any exceptions.
   * @param beanName the name of the bean
   * @param bean the bean instance to destroy
   */
  void destroyBean(String beanName, @Nullable() DisposableBean bean) {
    // Trigger destruction of dependent beans first...
    Set<String> dependencies;
    // Within full synchronization in order to guarantee a disconnected Set
    dependencies = _dependentBeanMap.remove(beanName);
    if (dependencies != null) {
//      if (logger.isTraceEnabled()) {
//        logger.trace("Retrieved dependent beans for bean '" + beanName + "': " + dependencies);
//      }
      for (String dependentBeanName in dependencies) {
        destroySingleton(dependentBeanName);
      }
    }

    // Actually destroy the bean now...
    if (bean != null) {
      try {
        bean.destroy();
      } on Object catch (ex) {
//        if (logger.isInfoEnabled()) {
//          logger.info("Destroy method on bean with name '" + beanName + "' threw an exception", ex);
//        }
      }
    }

    // Trigger destruction of contained beans...
    Set<String> containedBeans;
    // Within full synchronization in order to guarantee a disconnected Set
    containedBeans = _containedBeanMap.remove(beanName);
    if (containedBeans != null) {
      for (String containedBeanName in containedBeans) {
        destroySingleton(containedBeanName);
      }
    }

    for (MapEntry<String, Set<String>> entry in _dependentBeanMap.entries) {
      Set<String> dependenciesToClean = entry.value;
      dependenciesToClean.remove(beanName);
    }

    _dependenciesForBeanMap.remove(beanName);
  }
}
