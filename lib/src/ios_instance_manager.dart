import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'android_instance_manager_api_impls.dart';
import 'instance_manager.dart';
import 'android_instance_manager.pigeon.dart';

/// Root of the Java class hierarchy.
///
/// See https://docs.oracle.com/javase/8/docs/api/java/lang/Object.html.
class JavaObject with Copyable {
  /// Constructs a [JavaObject] without creating the associated Java object.
  ///
  /// This should only be used by subclasses created by this library or to
  /// create copies.
  @protected
  JavaObject.detached({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  }) : _api = JavaObjectHostApiImpl(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        );

  /// Global instance of [InstanceManager].
  static final InstanceManager globalInstanceManager = _initInstanceManager();

  static InstanceManager _initInstanceManager() {
    WidgetsFlutterBinding.ensureInitialized();
    // Clears the native `InstanceManager` on initial use of the Dart one.
    InstanceManagerHostApi().clear();
    return InstanceManager(
      onWeakReferenceRemoved: (String identifier) {
        JavaObjectHostApiImpl().dispose(identifier);
      },
    );
  }

  /// Pigeon Host Api implementation for [JavaObject].
  final JavaObjectHostApiImpl _api;

  /// Release the reference to a native Java instance.
  static void dispose(JavaObject instance) {
    instance._api.instanceManager.removeWeakReference(instance);
  }

  @override
  JavaObject copy() {
    return JavaObject.detached();
  }
}
