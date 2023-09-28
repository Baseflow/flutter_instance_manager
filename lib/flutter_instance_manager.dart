
import 'flutter_instance_manager_platform_interface.dart';

class FlutterInstanceManager {
  Future<String?> getPlatformVersion() {
    return FlutterInstanceManagerPlatform.instance.getPlatformVersion();
  }
}
