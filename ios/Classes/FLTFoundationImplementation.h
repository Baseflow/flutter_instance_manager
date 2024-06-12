// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>

#import "foundation.pigeon.h"
#import "FLTInstanceManager.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Flutter api implementation for NSObject.
 *
 * Handles making callbacks to Dart for an NSObject.
 */
@interface FLTObjectFlutterApiImpl : FLTNSObjectFlutterApi
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(FLTInstanceManager *)instanceManager;
@end

/**
 * Implementation of NSObject for FWFObjectHostApiImpl.
 */
@interface FLTObject : NSObject
@property(readonly, nonnull, nonatomic) FLTObjectFlutterApiImpl *objectApi;

- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(FLTInstanceManager *)instanceManager;
@end

/**
 * Host api implementation for NSObject.
 *
 * Handles creating NSObject that intercommunicate with a paired Dart object.
 */
@interface FLTObjectHostApiImpl : NSObject <FLTNSObjectHostApi>
- (instancetype)initWithInstanceManager:(FLTInstanceManager *)instanceManager;
@end

NS_ASSUME_NONNULL_END
