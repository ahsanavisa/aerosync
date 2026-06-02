import 'package:flutter_riverpod/flutter_riverpod.dart';

/// StateProvider to manage the active bottom navigation tab index of HomeScreen.
final tabIndexProvider = StateProvider<int>((ref) => 0);
