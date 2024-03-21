import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_instance_manager_method_channel.dart';

abstract class FlutterInstanceManagerPlatform extends PlatformInterface {
  /// Constructs a FlutterInstanceManagerPlatform.
  FlutterInstanceManagerPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterInstanceManagerPlatform _instance = MethodChannelFlutterInstanceManager();

  /// The default instance of [FlutterInstanceManagerPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterInstanceManager].
  static FlutterInstanceManagerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterInstanceManagerPlatform] when
  /// they register themselves.
  static set instance(FlutterInstanceManagerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
