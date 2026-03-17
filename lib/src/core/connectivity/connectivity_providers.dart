import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

final connectivityStreamProvider =
    StreamProvider<List<ConnectivityResult>>((ref) {
  final connectivity = ref.watch(connectivityProvider);

  final controller = StreamController<List<ConnectivityResult>>();

  unawaited(() async {
    try {
      controller.add(await connectivity.checkConnectivity());
    } catch (_) {
      // Ignore: we'll still get updates from the stream.
    }
  }());

  final sub = connectivity.onConnectivityChanged.listen(controller.add);
  ref.onDispose(() {
    unawaited(sub.cancel());
    unawaited(controller.close());
  });

  return controller.stream.distinct(listEquals);
});

final isOnlineProvider = Provider<bool>((ref) {
  final results = ref.watch(connectivityStreamProvider).value;
  if (results == null) return true;
  if (results.isEmpty) return false;
  return results.contains(ConnectivityResult.none) == false;
});

class OnlineStatusController extends AutoDisposeNotifier<bool> {
  @override
  bool build() {
    final results = ref.watch(connectivityStreamProvider).value;
    if (results == null) return true;
    if (results.isEmpty) return false;
    return results.contains(ConnectivityResult.none) == false;
  }
}
