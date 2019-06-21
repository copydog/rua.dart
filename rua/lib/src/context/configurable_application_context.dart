import 'package:rua/src/context/application_context.dart';
import 'package:rua/src/context/lifecycle.dart';
import 'package:rua/src/core/closable.dart';

abstract class ConfigurableApplicationContext implements ApplicationContext, Lifecycle, Closable {}
