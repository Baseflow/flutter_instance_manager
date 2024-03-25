#import "FlutterInstanceManagerPlugin.h"

// Plugin class that exists because the Flutter tool expects such a class to exist for every iOS
// plugin.
//
// <p><strong>DO NOT USE THIS CLASS.</strong>
@implementation FlutterInstanceManagerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  // no-op
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  // no-op
}

@end
