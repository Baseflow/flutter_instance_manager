import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_instance_manager/flutter_instance_manager.dart';
import 'package:flutter_instance_manager/flutter_instance_manager_platform_interface.dart';
import 'package:flutter_instance_manager/flutter_instance_manager_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterInstanceManagerPlatform
    with MockPlatformInterfaceMixin
    implements FlutterInstanceManagerPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterInstanceManagerPlatform initialPlatform = FlutterInstanceManagerPlatform.instance;

  test('$MethodChannelFlutterInstanceManager is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterInstanceManager>());
  });

  test('getPlatformVersion', () async {
    FlutterInstanceManager flutterInstanceManagerPlugin = FlutterInstanceManager();
    MockFlutterInstanceManagerPlatform fakePlatform = MockFlutterInstanceManagerPlatform();
    FlutterInstanceManagerPlatform.instance = fakePlatform;

    expect(await flutterInstanceManagerPlugin.getPlatformVersion(), '42');
  });
}
