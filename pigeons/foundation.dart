import 'package:pigeon/pigeon.dart';

/// pigeon examples
/// https://github.com/flutter/packages/blob/a757073ac4eaf05b7516d3d0488e5c98b221043f/packages/pigeon/example/README.md?plain=1#L16

/// To regenerate using pigeon, run
/// `dart run pigeon --input pigeons/foundation.dart`.
///
@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/foundation/foundation_instance_manager.pigeon.dart',
  dartTestOut: 'lib/test/foundation/test_foundation_instance_manager.pigeon.dart',
  dartOptions: DartOptions(),
  swiftOut: 'ios/Classes/FoundationApi/foundation.pigeon.swift',
  swiftOptions: SwiftOptions(),
  objcOptions: ObjcOptions(prefix: 'FTL'),
  copyrightHeader: 'pigeons/copyright.txt',
))

/// Mirror of NSObject.
///
/// See https://developer.apple.com/documentation/objectivec/nsobject.
@HostApi(dartHostTestHandler: 'TestNSObjectHostApi')
abstract class NSObjectHostApi {
  @ObjCSelector('disposeObjectWithIdentifier:')
  void dispose(String identifier);
}

/// Handles callbacks from an NSObject instance.
///
/// See https://developer.apple.com/documentation/objectivec/nsobject.
@FlutterApi()
abstract class NSObjectFlutterApi {
  @ObjCSelector('disposeObjectWithIdentifier:')
  void dispose(String identifier);
}