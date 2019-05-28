import "package:rua/rua.dart";

@component
class A {}

@service
class B {}

@factory
class C {}

@component
class Ioc {
  @autowired
  A a;

  @autowired
  B b;

  @autowired
  C c;
}
