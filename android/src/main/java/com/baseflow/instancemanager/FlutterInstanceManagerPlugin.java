package com.baseflow.instancemanager;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;

/**
 * Plugin class that exists because the Flutter tool expects such a class to exist for every Android
 * plugin.
 *
 * <p><strong>DO NOT USE THIS CLASS.</strong>
 */
public class FlutterInstanceManagerPlugin implements FlutterPlugin {
  @SuppressWarnings("deprecation")
  public static void registerWith(
      @NonNull io.flutter.plugin.common.PluginRegistry.Registrar registrar) {
    // no-op
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    // no-op
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    // no-op
  }
}
