// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v19.0.2), do not edit directly.
// See also: https://pub.dev/packages/pigeon

#import <Foundation/Foundation.h>

@protocol FlutterBinaryMessenger;
@protocol FlutterMessageCodec;
@class FlutterError;
@class FlutterStandardTypedData;

NS_ASSUME_NONNULL_BEGIN


/// The codec used by FLTNSObjectHostApi.
NSObject<FlutterMessageCodec> *FLTNSObjectHostApiGetCodec(void);

/// Mirror of NSObject.
///
/// See https://developer.apple.com/documentation/objectivec/nsobject.
@protocol FLTNSObjectHostApi
- (void)disposeObjectWithIdentifier:(NSString *)identifier error:(FlutterError *_Nullable *_Nonnull)error;
@end

extern void SetUpFLTNSObjectHostApi(id<FlutterBinaryMessenger> binaryMessenger, NSObject<FLTNSObjectHostApi> *_Nullable api);

extern void SetUpFLTNSObjectHostApiWithSuffix(id<FlutterBinaryMessenger> binaryMessenger, NSObject<FLTNSObjectHostApi> *_Nullable api, NSString *messageChannelSuffix);

/// The codec used by FLTNSObjectFlutterApi.
NSObject<FlutterMessageCodec> *FLTNSObjectFlutterApiGetCodec(void);

/// Handles callbacks from an NSObject instance.
///
/// See https://developer.apple.com/documentation/objectivec/nsobject.
@interface FLTNSObjectFlutterApi : NSObject
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger;
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger messageChannelSuffix:(nullable NSString *)messageChannelSuffix;
- (void)disposeObjectWithIdentifier:(NSString *)identifier completion:(void (^)(FlutterError *_Nullable))completion;
@end

NS_ASSUME_NONNULL_END
