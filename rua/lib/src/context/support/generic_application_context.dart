import 'package:rua/src/beans/factory/config/bean_definition.dart';
import 'package:rua/src/beans/factory/support/bean_definition_registry.dart';
import 'package:rua/src/context/support/abstract_application_context.dart';

class GenericApplicationContext extends AbstractApplicationContext
    implements BeanDefinitionRegistry {
  //---------------------------------------------------------------------
  // Implementation of BeanDefinitionRegistry
  //---------------------------------------------------------------------

  @override
  bool containsBeanDefinition(String beanName) {
    // TODO: implement containsBeanDefinition
  }

  @override
  BeanDefinition getBeanDefinition(String beanName) {
    // TODO: implement getBeanDefinition
  }

  @override
  int getBeanDefinitionCount() {
    // TODO: implement getBeanDefinitionCount
  }

  @override
  List<String> getBeanDefinitionNames() {
    // TODO: implement getBeanDefinitionNames
  }

  @override
  bool isBeanNameInUse(String beanName) {
    // TODO: implement isBeanNameInUse
  }

  @override
  void registerBeanDefinition(String beanName, BeanDefinition beanDefinition) {
    // TODO: implement registerBeanDefinition
  }

  @override
  void removeBeanDefinition(String beanName) {
    // TODO: implement removeBeanDefinition
  }

  @override
  List<String> getAliases(String name) {
    // TODO: implement getAliases
  }

  @override
  bool isAlias(String name) {
    // TODO: implement isAlias
  }

  @override
  void registerAlias(String name, String alias) {
    // TODO: implement registerAlias
  }

  @override
  void removeAlias(String alias) {
    // TODO: implement removeAlias
  }
}
