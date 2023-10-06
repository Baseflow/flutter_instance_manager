import 'package:pigeon/pigeon.dart';

/// To regenerate using pigeon, run
/// `dart run pigeon --input pigeons/android_instance_manager.dart`.
@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/instance_manager.pigeon.dart',
    dartTestOut: 'lib/test/test_instance_manager.pigeon.dart',
    javaOut:
        'android/src/main/java/com/baseflow/instancemanager/InstanceManagerPigeon.java',
    javaOptions: JavaOptions(
      package: 'com.baseflow.instancemanager',
      className: 'InstanceManagerPigeon',
    ),
  ),
)

/// Host API for managing the native `InstanceManager`.
@HostApi(dartHostTestHandler: 'TestInstanceManagerHostApi')
abstract class InstanceManagerHostApi {
  /// Clear the native `InstanceManager`.
  ///
  /// This is typically only used after a hot restart.
  void clear();
}

/// Handles methods calls to the native Java Object class.
///
/// Also handles calls to remove the reference to an instance with `dispose`.
///
/// See https://docs.oracle.com/javase/7/docs/api/java/lang/Object.html.
@HostApi(dartHostTestHandler: 'TestJavaObjectHostApi')
abstract class JavaObjectHostApi {
  void dispose(String identifier);
}

/// Handles callbacks methods for the native Java Object class.
///
/// See https://docs.oracle.com/javase/7/docs/api/java/lang/Object.html.
@FlutterApi()
abstract class JavaObjectFlutterApi {
  void dispose(String identifier);
}
