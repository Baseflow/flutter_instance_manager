// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.baseflow.instancemanager;

import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import java.lang.ref.ReferenceQueue;
import java.lang.ref.WeakReference;
import java.util.HashMap;
import java.util.UUID;
import java.util.WeakHashMap;

import io.flutter.plugin.common.BinaryMessenger;

/**
 * Maintains instances used to communicate with the corresponding objects in
 * Dart.
 *
 * <p>
 * Objects stored in this container are represented by an object in Dart that is
 * also stored in
 * an InstanceManager with the same identifier.
 *
 * <p>
 * When an instance is added with an identifier, either can be used to retrieve
 * the other.
 *
 * <p>
 * Added instances are added as a weak reference and a strong reference. When
 * the strong
 * reference is removed with `{@link #remove(UUID)}` and the weak reference is
 * deallocated, the
 * `finalizationListener` is made with the instance's identifier. However, if
 * the strong reference
 * is removed and then the identifier is retrieved with the intention to pass
 * the identifier to Dart
 * (e.g. calling {@link #getIdentifierForStrongReference(Object)}), the strong
 * reference to the
 * instance is recreated. The strong reference will then need to be removed
 * manually again.
 */
@SuppressWarnings("unchecked")
public class InstanceManager {
    private static final long CLEAR_FINALIZED_WEAK_REFERENCES_INTERVAL = 3000;
    private static final String TAG = "InstanceManager";

    /**
     * Interface for listening when a weak reference of an instance is removed from
     * the manager.
     */
    public interface FinalizationListener {
        void onFinalize(UUID identifier);
    }

    private final WeakHashMap<Object, UUID> identifiers = new WeakHashMap<>();
    private final HashMap<UUID, WeakReference<Object>> weakInstances = new HashMap<>();
    private final HashMap<UUID, Object> strongInstances = new HashMap<>();

    private final ReferenceQueue<Object> referenceQueue = new ReferenceQueue<>();
    private final HashMap<WeakReference<Object>, UUID> weakReferencesToIdentifiers = new HashMap<>();

    private final Handler handler = new Handler(Looper.getMainLooper());

    private final FinalizationListener finalizationListener;

    private boolean hasFinalizationListenerStopped = false;

    /**
     * Instantiate a new manager.
     *
     * <p>
     * When the manager is no longer needed, {@link #stopFinalizationListener()}
     * must be called.
     * This method will inform Dart about the finalization through the
     * {@link com.baseflow.instancemanager.AndroidInstanceManagerPigeon.JavaObjectFlutterApi}. If
     * you prefer to provide a custom finalizer please use the {@link #create(FinalizationListener)}
     * instead.
     * </p>
     *
     * @param binaryMessenger the binaryMessenger used to communicate with Dart.
     * @return a new `InstanceManager`.
     */
    public static InstanceManager create(@NonNull BinaryMessenger binaryMessenger) {
        return new InstanceManager(identifier ->
            new AndroidInstanceManagerPigeon.JavaObjectFlutterApi(binaryMessenger)
                .dispose(identifier.toString(), reply -> {}));
      }

    /**
     * Instantiate a new manager.
     *
     * <p>
     * When the manager is no longer needed, {@link #stopFinalizationListener()}
     * must be called.
     *
     * @param finalizationListener the listener for garbage collected weak
     *                             references.
     * @return a new `InstanceManager`.
     */
    @NonNull
    public static InstanceManager create(@NonNull FinalizationListener finalizationListener) {
        return new InstanceManager(finalizationListener);
    }

    private InstanceManager(FinalizationListener finalizationListener) {
        this.finalizationListener = finalizationListener;
        handler.postDelayed(
            this::releaseAllFinalizedInstances, CLEAR_FINALIZED_WEAK_REFERENCES_INTERVAL);
    }

    /**
     * Removes `identifier` and its associated strongly referenced instance, if
     * present, from the
     * manager.
     *
     * @param identifier the identifier paired to an instance.
     * @param <T>        the expected return type.
     * @return the removed instance if the manager contains the given identifier,
     *         otherwise `null` if
     *         the manager doesn't contain the value.
     */
    @Nullable
    public <T> T remove(UUID identifier) {
        logWarningIfFinalizationListenerHasStopped();
        return (T) strongInstances.remove(identifier);
    }

    /**
     * Retrieves the identifier paired with an instance.
     *
     * <p>
     * If the manager contains a strong reference to `instance`, it will return the
     * identifier
     * associated with `instance`. If the manager contains only a weak reference to
     * `instance`, a new
     * strong reference to `instance` will be added and will need to be removed
     * again with {@link
     * #remove(UUID)}.
     *
     * <p>
     * If this method returns a nonnull identifier, this method also expects the
     * Dart
     * `InstanceManager` to have, or recreate, a weak reference to the Dart instance
     * the identifier is
     * associated with.
     *
     * @param instance an instance that may be stored in the manager.
     * @return the identifier associated with `instance` if the manager contains the
     *         value, otherwise
     *         `null` if the manager doesn't contain the value.
     */
    @Nullable
    public UUID getIdentifierForStrongReference(@Nullable Object instance) {
        logWarningIfFinalizationListenerHasStopped();

        final UUID identifier = identifiers.get(instance);
        if (identifier != null) {
            strongInstances.put(identifier, instance);
        }
        return identifier;
    }

    /**
     * Adds a new instance that was instantiated from Dart.
     *
     * <p>
     * The same instance can be added multiple times, but each identifier must be
     * unique. This
     * allows two objects that are equivalent (e.g. the `equals` method returns true
     * and their
     * hashcodes are equal) to both be added.
     *
     * @param instance   the instance to be stored.
     * @param identifier the identifier to be paired with instance. This value must
     *                   be >= 0 and
     *                   unique.
     */
    public void addDartCreatedInstance(@NonNull Object instance, UUID identifier) {
        logWarningIfFinalizationListenerHasStopped();
        addInstance(instance, identifier);
    }

    /**
     * Adds a new instance that was instantiated from the host platform.
     *
     * @param instance the instance to be stored. This must be unique to all other
     *                 added instances.
     * @return the unique identifier (>= 0) stored with instance.
     */
    public UUID addHostCreatedInstance(@NonNull Object instance) {
        logWarningIfFinalizationListenerHasStopped();

        if (containsInstance(instance)) {
            throw new IllegalArgumentException(
                "Instance of " + instance.getClass() + " has already been added.");
        }
        final UUID identifier = UUID.randomUUID();
        addInstance(instance, identifier);
        return identifier;
    }

    /**
     * Retrieves the instance associated with identifier.
     *
     * @param identifier the identifier associated with an instance.
     * @param <T>        the expected return type.
     * @return the instance associated with `identifier` if the manager contains the
     *         value, otherwise
     *         `null` if the manager doesn't contain the value.
     */
    @Nullable
    public <T> T getInstance(UUID identifier) {
        logWarningIfFinalizationListenerHasStopped();

        final WeakReference<T> instance = (WeakReference<T>) weakInstances.get(identifier);
        if (instance != null) {
            return instance.get();
        }
        return null;
    }

    /**
     * Returns whether this manager contains the given `instance`.
     *
     * @param instance the instance whose presence in this manager is to be tested.
     * @return whether this manager contains the given `instance`.
     */
    public boolean containsInstance(@Nullable Object instance) {
        logWarningIfFinalizationListenerHasStopped();
        return identifiers.containsKey(instance);
    }

    /**
     * Stop the periodic run of the {@link FinalizationListener} for instances that
     * have been garbage
     * collected.
     *
     * <p>
     * The InstanceManager can continue to be used, but the
     * {@link FinalizationListener} will no
     * longer be called and methods will log a warning.
     */
    public void stopFinalizationListener() {
        handler.removeCallbacks(this::releaseAllFinalizedInstances);
        hasFinalizationListenerStopped = true;
    }

    /**
     * Removes all of the instances from this manager.
     *
     * <p>
     * The manager will be empty after this call returns.
     */
    public void clear() {
        identifiers.clear();
        weakInstances.clear();
        strongInstances.clear();
        weakReferencesToIdentifiers.clear();
    }

    /**
     * Whether the {@link FinalizationListener} is still being called for instances
     * that are garbage
     * collected.
     *
     * <p>
     * See {@link #stopFinalizationListener()}.
     */
    public boolean hasFinalizationListenerStopped() {
        return hasFinalizationListenerStopped;
    }

    private void releaseAllFinalizedInstances() {
        if (hasFinalizationListenerStopped()) {
            return;
        }

        WeakReference<Object> reference;
        while ((reference = (WeakReference<Object>) referenceQueue.poll()) != null) {
            final UUID identifier = weakReferencesToIdentifiers.remove(reference);
            if (identifier != null) {
                weakInstances.remove(identifier);
                strongInstances.remove(identifier);
                finalizationListener.onFinalize(identifier);
            }
        }
        handler.postDelayed(
            this::releaseAllFinalizedInstances, CLEAR_FINALIZED_WEAK_REFERENCES_INTERVAL);
    }

    private void addInstance(Object instance, UUID identifier) {
        if (weakInstances.containsKey(identifier)) {
            throw new IllegalArgumentException(
                String.format("Identifier has already been added: %s", identifier));
        }
        final WeakReference<Object> weakReference = new WeakReference<>(instance, referenceQueue);
        identifiers.put(instance, identifier);
        weakInstances.put(identifier, weakReference);
        weakReferencesToIdentifiers.put(weakReference, identifier);
        strongInstances.put(identifier, instance);
    }

    private void logWarningIfFinalizationListenerHasStopped() {
        if (hasFinalizationListenerStopped()) {
            Log.w(TAG, "The manager was used after calls to the FinalizationListener have been stopped.");
        }
    }
}
