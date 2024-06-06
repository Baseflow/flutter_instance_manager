// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter_instance_manager/src/instance_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

/// To regenerate using `build_runner`, run
/// `dart run build_runner build`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('InstanceManager', () {
    test('addHostCreatedInstance', () {
      final CopyableObject object = CopyableObject();

      final InstanceManager instanceManager =
          InstanceManager(onWeakReferenceRemoved: (_) {});
      const Uuid uuid = Uuid();
      final String identifier = uuid.v4();

      instanceManager.addHostCreatedInstance(object, identifier);

      expect(instanceManager.getIdentifier(object), identifier);
      expect(
        instanceManager.getInstanceWithWeakReference(identifier),
        object,
      );
    });

    test(
        'addHostCreatedInstance prevents empty string to be used as identifier',
        () {
      final CopyableObject object = CopyableObject();

      final InstanceManager instanceManager =
          InstanceManager(onWeakReferenceRemoved: (_) {});

      expect(
        () => instanceManager.addHostCreatedInstance(object, ''),
        throwsAssertionError,
      );
    });

    test('addHostCreatedInstance prevents already used objects and ids', () {
      final CopyableObject object = CopyableObject();

      final InstanceManager instanceManager =
          InstanceManager(onWeakReferenceRemoved: (_) {});
      const Uuid uuid = Uuid();
      final String identifier = uuid.v4();

      instanceManager.addHostCreatedInstance(object, identifier);

      expect(
        () => instanceManager.addHostCreatedInstance(object, identifier),
        throwsAssertionError,
      );

      expect(
        () => instanceManager.addHostCreatedInstance(
            CopyableObject(), identifier),
        throwsAssertionError,
      );
    });

    test('addFlutterCreatedInstance', () {
      final CopyableObject object = CopyableObject();

      final InstanceManager instanceManager =
          InstanceManager(onWeakReferenceRemoved: (_) {});

      instanceManager.addDartCreatedInstance(object);

      final String? instanceId = instanceManager.getIdentifier(object);
      expect(instanceId, isNotNull);
      expect(
        instanceManager.getInstanceWithWeakReference(instanceId!),
        object,
      );
    });

    test('removeWeakReference', () {
      final CopyableObject object = CopyableObject();

      const Uuid uuid = Uuid();
      final String identifier = uuid.v4();

      String? weakInstanceId;
      final InstanceManager instanceManager =
          InstanceManager(onWeakReferenceRemoved: (String instanceId) {
        weakInstanceId = instanceId;
      });

      instanceManager.addHostCreatedInstance(object, identifier);

      expect(instanceManager.removeWeakReference(object), identifier);
      expect(
        instanceManager.getInstanceWithWeakReference(identifier),
        isA<CopyableObject>(),
      );
      expect(weakInstanceId, identifier);
    });

    test('removeWeakReference removes only weak reference', () {
      final CopyableObject object = CopyableObject();

      const Uuid uuid = Uuid();
      final String identifier = uuid.v4();
      final InstanceManager instanceManager =
          InstanceManager(onWeakReferenceRemoved: (_) {});

      instanceManager.addHostCreatedInstance(object, identifier);

      expect(instanceManager.removeWeakReference(object), identifier);
      final CopyableObject copy = instanceManager.getInstanceWithWeakReference(
        identifier,
      )!;
      expect(identical(object, copy), isFalse);
    });

    test('removeStrongReference', () {
      final CopyableObject object = CopyableObject();

      const Uuid uuid = Uuid();
      final String identifier = uuid.v4();
      final InstanceManager instanceManager =
          InstanceManager(onWeakReferenceRemoved: (_) {});

      instanceManager.addHostCreatedInstance(object, identifier);
      instanceManager.removeWeakReference(object);
      expect(instanceManager.remove(identifier), isA<CopyableObject>());
      expect(instanceManager.containsIdentifier(identifier), isFalse);
    });

    test('removeStrongReference removes only strong reference', () {
      final CopyableObject object = CopyableObject();

      const Uuid uuid = Uuid();
      final String identifier = uuid.v4();
      final InstanceManager instanceManager =
          InstanceManager(onWeakReferenceRemoved: (_) {});

      instanceManager.addHostCreatedInstance(object, identifier);
      expect(instanceManager.remove(identifier), isA<CopyableObject>());
      expect(
        instanceManager.getInstanceWithWeakReference(identifier),
        object,
      );
    });

    test('getInstance can add a new weak reference', () {
      final CopyableObject object = CopyableObject();

      const Uuid uuid = Uuid();
      final String identifier = uuid.v4();
      final InstanceManager instanceManager =
          InstanceManager(onWeakReferenceRemoved: (_) {});

      instanceManager.addHostCreatedInstance(object, identifier);
      instanceManager.removeWeakReference(object);

      final CopyableObject newWeakCopy =
          instanceManager.getInstanceWithWeakReference(
        identifier,
      )!;
      expect(identical(object, newWeakCopy), isFalse);
    });
  });
}

class CopyableObject with Copyable {
  @override
  Copyable copy() {
    return CopyableObject();
  }
}
