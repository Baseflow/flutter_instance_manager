// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_instance_manager/flutter_instance_manager.dart';

import 'foundation_instance_manager_implementation.dart';

/// Keys that may exist in the user info map of `NSError`.
class NSErrorUserInfoKey {
  NSErrorUserInfoKey._();

  /// The corresponding value is a localized string representation of the error
  /// that, if present, will be returned by [NSError.localizedDescription].
  ///
  /// See https://developer.apple.com/documentation/foundation/nslocalizeddescriptionkey.
  // ignore: constant_identifier_names
  static const String NSLocalizedDescription = 'NSLocalizedDescription';

  /// The URL which caused a load to fail.
  ///
  /// See https://developer.apple.com/documentation/foundation/nsurlerrorfailingurlstringerrorkey?language=objc.
  // ignore: constant_identifier_names
  static const String NSURLErrorFailingURLStringError =
      'NSErrorFailingURLStringKey';
}

/// Information about an error condition.
///
/// Wraps [NSError](https://developer.apple.com/documentation/foundation/nserror?language=objc).
@immutable
class NSError {
  /// Constructs an [NSError].
  const NSError({
    required this.code,
    required this.domain,
    this.userInfo = const <String, Object?>{},
  });

  /// The error code.
  ///
  /// Error codes are [domain]-specific.
  final int code;

  /// A string containing the error domain.
  final String domain;

  /// Map of arbitrary data.
  ///
  /// See [NSErrorUserInfoKey] for possible keys (non-exhaustive).
  ///
  /// This currently only supports values that are a String.
  final Map<String, Object?> userInfo;

  /// A string containing the localized description of the error.
  String? get localizedDescription =>
      userInfo[NSErrorUserInfoKey.NSLocalizedDescription] as String?;

  @override
  String toString() {
    if (localizedDescription?.isEmpty ?? true) {
      return 'Error $domain:$code:$userInfo';
    }
    return '$localizedDescription ($domain:$code:$userInfo)';
  }
}

/// The root class of most Objective-C class hierarchies.
@immutable
class NSObject with Copyable {
  /// Constructs a [NSObject] without creating the associated
  /// Objective-C object.
  ///
  /// This should only be used by subclasses created by this library or to
  /// create copies.
  NSObject.detached({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  }) : _api = NSObjectHostApiImpl(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ) {
    // Ensures FlutterApis for the Foundation library are set up.
    FoundationFlutterApis.instance.ensureSetUp();
  }

  /// Release the reference to the Swift object.
  static void dispose(NSObject instance) {
    instance._api.instanceManager.removeWeakReference(instance);
  }

  /// Global instance of [InstanceManager].
  static final InstanceManager globalInstanceManager =
      InstanceManager(onWeakReferenceRemoved: (String instanceId) {
    debugPrint('Removing instance: $instanceId');
    NSObjectHostApiImpl().dispose(instanceId);
  });

  final NSObjectHostApiImpl _api;

  @override
  NSObject copy() {
    return NSObject.detached(
      binaryMessenger: _api.binaryMessenger,
      instanceManager: _api.instanceManager,
    );
  }
}
