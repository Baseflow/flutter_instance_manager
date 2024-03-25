// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTInstanceManager.h"
#import "FLTInstanceManager_Test.h"

#import <objc/runtime.h>

// Attaches to an object to receive a callback when the object is deallocated.
@interface Finalizer : NSObject
@end

// Attaches to an object to receive a callback when the object is deallocated.
@implementation Finalizer {
  NSUUID * _identifier;
  // Callbacks are no longer made once InstanceManager is inaccessible.
  OnDeallocCallback __weak _callback;
}

- (instancetype)initWithIdentifier:(NSUUID *)identifier callback:(OnDeallocCallback)callback {
  self = [self init];
  if (self) {
    _identifier = identifier;
    _callback = callback;
  }
  return self;
}

+ (void)attachToInstance:(NSObject *)instance
          withIdentifier:(NSUUID *)identifier
                callback:(OnDeallocCallback)callback {
  Finalizer *finalizer = [[Finalizer alloc] initWithIdentifier:identifier callback:callback];
  objc_setAssociatedObject(instance, _cmd, finalizer, OBJC_ASSOCIATION_RETAIN);
}

+ (void)detachFromInstance:(NSObject *)instance {
  objc_setAssociatedObject(instance, @selector(attachToInstance:withIdentifier:callback:), nil,
                           OBJC_ASSOCIATION_ASSIGN);
}

- (void)dealloc {
  if (_callback) {
    _callback(_identifier);
  }
}
@end

@interface FLTInstanceManager ()
@property dispatch_queue_t lockQueue;
@property NSMapTable<NSObject *, NSUUID *> *identifiers;
@property NSMapTable<NSUUID *, NSObject *> *weakInstances;
@property NSMapTable<NSUUID *, NSObject *> *strongInstances;
@end

@implementation FLTInstanceManager

- (instancetype)init {
  self = [super init];
  if (self) {
    _deallocCallback = _deallocCallback ? _deallocCallback : ^(NSUUID * identifier) {
    };
    _lockQueue = dispatch_queue_create("InstanceManager", DISPATCH_QUEUE_SERIAL);
    // Pointer equality is used to prevent collisions of objects that override the `isEqualTo:`
    // method.
    _identifiers =
        [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory | NSMapTableObjectPointerPersonality
                              valueOptions:NSMapTableStrongMemory];
    _weakInstances = [NSMapTable
        mapTableWithKeyOptions:NSMapTableStrongMemory
                  valueOptions:NSMapTableWeakMemory | NSMapTableObjectPointerPersonality];
    _strongInstances = [NSMapTable
        mapTableWithKeyOptions:NSMapTableStrongMemory
                  valueOptions:NSMapTableStrongMemory | NSMapTableObjectPointerPersonality];
  }
  return self;
}

- (instancetype)initWithDeallocCallback:(OnDeallocCallback)callback {
  self = [self init];
  if (self) {
    _deallocCallback = callback;
  }
  return self;
}

- (void)addDartCreatedInstance:(NSObject *)instance withIdentifier:(NSUUID *)instanceIdentifier {
  NSParameterAssert(instance);
  NSParameterAssert(instanceIdentifier >= 0);
  dispatch_async(_lockQueue, ^{
    [self addInstance:instance withIdentifier:instanceIdentifier];
  });
}

- (NSUUID *)addHostCreatedInstance:(nonnull NSObject *)instance {
  NSParameterAssert(instance);
  NSUUID * __block identifier = [NSUUID new];
  dispatch_sync(_lockQueue, ^{
    identifier = [NSUUID new];
    [self addInstance:instance withIdentifier:identifier];
  });
  return identifier;
}

- (nullable NSObject *)removeInstanceWithIdentifier:(NSUUID *)instanceIdentifier {
  NSObject *__block instance = nil;
  dispatch_sync(_lockQueue, ^{
    instance = [self.strongInstances objectForKey:instanceIdentifier];
    if (instance) {
        [self.strongInstances removeObjectForKey:instanceIdentifier];
    }
  });
  return instance;
}

- (nullable NSObject *)instanceForIdentifier:(NSUUID *)instanceIdentifier {
  NSObject *__block instance = nil;
  dispatch_sync(_lockQueue, ^{
    instance = [self.weakInstances objectForKey:instanceIdentifier];
  });
  return instance;
}

- (void)addInstance:(nonnull NSObject *)instance withIdentifier:(NSUUID *)instanceIdentifier {
  [self.identifiers setObject:instanceIdentifier forKey:instance];
  [self.weakInstances setObject:instance forKey:instanceIdentifier];
  [self.strongInstances setObject:instance forKey:instanceIdentifier];
  [Finalizer attachToInstance:instance
                  withIdentifier:instanceIdentifier
                        callback:self.deallocCallback];
}

- (NSUUID *)identifierWithStrongReferenceForInstance:(nonnull NSObject *)instance {
  NSUUID *__block identifierNumber = nil;
  dispatch_sync(_lockQueue, ^{
    identifierNumber = [self.identifiers objectForKey:instance];
    if (identifierNumber) {
      [self.strongInstances setObject:instance forKey:identifierNumber];
    }
  });
    return identifierNumber ? identifierNumber : [[NSUUID UUID] initWithUUIDString:@"XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXXX"];;
}

- (BOOL)containsInstance:(nonnull NSObject *)instance {
  BOOL __block containsInstance;
  dispatch_sync(_lockQueue, ^{
    containsInstance = [self.identifiers objectForKey:instance];
  });
  return containsInstance;
}

- (NSUInteger)strongInstanceCount {
  NSUInteger __block count = -1;
  dispatch_sync(_lockQueue, ^{
    count = self.strongInstances.count;
  });
  return count;
}

- (NSUInteger)weakInstanceCount {
  NSUInteger __block count = -1;
  dispatch_sync(_lockQueue, ^{
    count = self.weakInstances.count;
  });
  return count;
}
@end
