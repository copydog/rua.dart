import 'package:rua/src/core/alias_registry.dart';
import 'package:rua/src/lang/illegal_state_exception.dart';

class SimpleAliasRegistry implements AliasRegistry {
  final Map<String, String> _aliasMap = new Map();

  /**
   * Determine whether the given name has the given alias registered.
   * @param name the name to check
   * @param alias the alias to look for
   * @since 4.2.1
   */
  bool hasAlias(String name, String alias) {
    for (MapEntry<String, String> entry in this._aliasMap.entries) {
      String registeredName = entry.value;
      if (registeredName == name) {
        String registeredAlias = entry.key;
        if (registeredAlias == alias || hasAlias(registeredAlias, alias)) {
          return true;
        }
      }
    }
    return false;
  }

  /**
   * Transitively retrieve all aliases for the given name.
   * @param name the target name to find aliases for
   * @param result the resulting aliases list
   */
  void _retrieveAliases(String name, List<String> result) {
    this._aliasMap.forEach((alias, registeredName) {
      if (registeredName == name) {
        result.add(alias);
        _retrieveAliases(alias, result);
      }
    });
  }

  /**
   * Check whether the given name points back to the given alias as an alias
   * in the other direction already, catching a circular reference upfront
   * and throwing a corresponding IllegalStateException.
   * @param name the candidate name
   * @param alias the candidate alias
   * @see #registerAlias
   * @see #hasAlias
   */
  void checkForAliasCircle(String name, String alias) {
    if (hasAlias(alias, name)) {
      throw new IllegalStateException("Cannot register alias '" +
          alias +
          "' for name '" +
          name +
          "': Circular reference - '" +
          name +
          "' is a direct or indirect alias for '" +
          alias +
          "' already");
    }
  }

  /**
   * Return whether alias overriding is allowed.
   * Default is {@code true}.
   */
  bool allowAliasOverriding() {
    return true;
  }

  @override
  List<String> getAliases(String name) {
    List<String> result = List<String>();
    _retrieveAliases(name, result);
    return result;
//    return StringUtils.toStringArray(result);
  }

  @override
  bool isAlias(String name) {
    return _aliasMap.containsKey(name);
  }

  @override
  void registerAlias(String name, String alias) {
    assert(name != null && name != "", "'name' must not be empty");
    assert(alias != null && alias != "", "'alias' must not be empty");

    if (name == alias) {
      _aliasMap.remove(alias);
//      if (logger.isDebugEnabled()) {
//        logger.debug("Alias definition '" + alias + "' ignored since it points to same name");
//      }
    } else {
      String registeredName = _aliasMap[alias];
      if (registeredName != null) {
        if (registeredName == name) {
          // An existing alias - no need to re-register
          return;
        }
        if (!allowAliasOverriding()) {
          throw new IllegalStateException("Cannot define alias '" +
              alias +
              "' for name '" +
              name +
              "': It is already registered for name '" +
              registeredName +
              "'.");
        }
//        if (logger.isDebugEnabled()) {
//          logger.debug("Overriding alias '" +
//              alias +
//              "' definition for registered name '" +
//              registeredName +
//              "' with new target name '" +
//              name +
//              "'");
//        }
      }
    }
  }

  @override
  void removeAlias(String alias) {
    String name = this._aliasMap.remove(alias);
    if (name == null) {
      throw new IllegalStateException("No alias '" + alias + "' registered");
    }
  }

  /**
   * Determine the raw name, resolving aliases to canonical names.
   * @param name the user-specified name
   * @return the transformed name
   */
  String canonicalName(String name) {
    String canonicalName = name;
    // Handle aliasing...
    String resolvedName;
    do {
      resolvedName = this._aliasMap[canonicalName];
      if (resolvedName != null) {
        canonicalName = resolvedName;
      }
    } while (resolvedName != null);
    return canonicalName;
  }
}
