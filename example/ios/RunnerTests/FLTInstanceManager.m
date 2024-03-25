// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <XCTest/XCTest.h>

@import flutter_instance_manager;
@import flutter_instance_manager.Test;

@interface FLTInstanceManagerTests : XCTestCase
@end

@implementation FLTInstanceManagerTests
- (void)testAddDartCreatedInstance {
  FLTInstanceManager *instanceManager = [[FLTInstanceManager alloc] init];
  NSObject *object = [[NSObject alloc] init];
  NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"0a7a587b-c86e-4c22-ae0a-179d6266e7f8"];

  [instanceManager addDartCreatedInstance:object withIdentifier:uuid];
  XCTAssertEqualObjects([instanceManager instanceForIdentifier:uuid], object);
  XCTAssertEqual([instanceManager identifierWithStrongReferenceForInstance:object], uuid);
}

- (void)testAddHostCreatedInstance {
  FLTInstanceManager *instanceManager = [[FLTInstanceManager alloc] init];
  NSObject *object = [[NSObject alloc] init];
  [instanceManager addHostCreatedInstance:object];

  NSUUID *identifier = [instanceManager identifierWithStrongReferenceForInstance:object];
  XCTAssertNotNil(identifier);
  XCTAssertEqualObjects([instanceManager instanceForIdentifier:identifier], object);
}

- (void)testRemoveInstanceWithIdentifier {
  FLTInstanceManager *instanceManager = [[FLTInstanceManager alloc] init];
  NSObject *object = [[NSObject alloc] init];
  NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"0a7a587b-c86e-4c22-ae0a-179d6266e7f8"];

  [instanceManager addDartCreatedInstance:object withIdentifier:uuid];

  XCTAssertEqualObjects([instanceManager removeInstanceWithIdentifier:uuid], object);
  XCTAssertEqual([instanceManager strongInstanceCount], 0);
}

- (void)testDeallocCallbackIsIgnoredIfNull {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
  // This sets deallocCallback to nil to test that uses are null checked.
  FLTInstanceManager *instanceManager = [[FLTInstanceManager alloc] initWithDeallocCallback:nil];
#pragma clang diagnostic pop
  NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"0a7a587b-c86e-4c22-ae0a-179d6266e7f8"];

  [instanceManager addDartCreatedInstance:[[NSObject alloc] init] withIdentifier:uuid];

  // Tests that this doesn't cause a EXC_BAD_ACCESS crash.
  [instanceManager removeInstanceWithIdentifier:uuid];
}

- (void)testObjectsAreStoredWithPointerHashcode {
  FLTInstanceManager *instanceManager = [[FLTInstanceManager alloc] init];

  NSURL *url1 = [NSURL URLWithString:@"https://www.flutter.dev"];
  NSURL *url2 = [NSURL URLWithString:@"https://www.flutter.dev"];

  // Ensure urls are considered equal.
  XCTAssertTrue([url1 isEqual:url2]);

  [instanceManager addHostCreatedInstance:url1];
  [instanceManager addHostCreatedInstance:url2];

  XCTAssertNotEqual([instanceManager identifierWithStrongReferenceForInstance:url1],
                    [instanceManager identifierWithStrongReferenceForInstance:url2]);
}
@end
