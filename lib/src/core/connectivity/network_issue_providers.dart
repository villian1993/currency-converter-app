import 'package:currency_converter_app/src/core/connectivity/connectivity_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Set to true when a network call fails in a way that looks like "no internet",
/// even if the device reports some connectivity (e.g. captive portal).
final dioNoInternetFlagProvider = StateProvider<bool>((ref) => false);

/// "Online" derived from both device connectivity and recent Dio failures.
final effectiveIsOnlineProvider = Provider<bool>((ref) {
  final isOnline = ref.watch(isOnlineProvider);
  final dioFlag = ref.watch(dioNoInternetFlagProvider);
  return isOnline && dioFlag == false;
});

