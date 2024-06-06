// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTFoundationImplementation.h"
#import <objc/runtime.h>

@interface FLTObjectFlutterApiImpl ()
// BinaryMessenger must be weak to prevent a circular reference with the host API it
// references.
@property(nonatomic, weak) id<FlutterBinaryMessenger> binaryMessenger;
// InstanceManager must be weak to prevent a circular reference with the object it stores.
@property(nonatomic, weak) FLTInstanceManager *instanceManager;
@end

@implementation FLTObjectFlutterApiImpl
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(FLTInstanceManager *)instanceManager {
  self = [self initWithBinaryMessenger:binaryMessenger];
  if (self) {
    _binaryMessenger = binaryMessenger;
    _instanceManager = instanceManager;
  }
  return self;
}
@end

@implementation FLTObject
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(FLTInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _objectApi = [[FLTObjectFlutterApiImpl alloc] initWithBinaryMessenger:binaryMessenger
                                                          instanceManager:instanceManager];
  }
  return self;
}
@end

@interface FLTObjectHostApiImpl ()
// InstanceManager must be weak to prevent a circular reference with the object it stores.
@property(nonatomic, weak) FLTInstanceManager *instanceManager;
@end

@implementation FLTObjectHostApiImpl
- (instancetype)initWithInstanceManager:(FLTInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _instanceManager = instanceManager;
  }
  return self;
}

- (void)disposeObjectWithIdentifier:(nonnull NSUUID *)identifier
                              error:(FlutterError *_Nullable *_Nonnull)error {
  [self.instanceManager removeInstanceWithIdentifier:identifier];
}
@end
