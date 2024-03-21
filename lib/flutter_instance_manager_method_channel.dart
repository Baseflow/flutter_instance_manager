import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_instance_manager_platform_interface.dart';

/// An implementation of [FlutterInstanceManagerPlatform] that uses method channels.
class MethodChannelFlutterInstanceManager extends FlutterInstanceManagerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_instance_manager');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
