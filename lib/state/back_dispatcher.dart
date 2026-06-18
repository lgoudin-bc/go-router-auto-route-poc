import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The app's root [BackButtonDispatcher]. We own it (rather than letting
/// MaterialApp.router create one internally) so the "Simulate Android system
/// back" button can invoke the exact same dispatcher the OS would — proving
/// risk 5's back-priority chain end to end.
final rootBackDispatcherProvider = Provider<RootBackButtonDispatcher>(
  (ref) => RootBackButtonDispatcher(),
);
