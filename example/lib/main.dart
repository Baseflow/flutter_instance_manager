import 'package:flutter_instance_manager/flutter_instance_manager.dart';

void main() {
  final InstanceManager instanceManager =
      InstanceManager(onWeakReferenceRemoved: (_) {});

  const String hostId = 'hostId';
  final ExampleObject hostInstance = ExampleObject();
  instanceManager.addHostCreatedInstance(hostInstance, hostId);

  final String dartId = instanceManager.addDartCreatedInstance(ExampleObject());
  // ignore: unused_local_variable
  final ExampleObject? dartInstance =
      instanceManager.getInstanceWithWeakReference(dartId);
}

class ExampleObject implements Copyable {
  @override
  Copyable copy() {
    return ExampleObject();
  }
}
