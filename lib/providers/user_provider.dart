import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _usernameKey = 'username';

class UsernameNotifier extends Notifier<String> {
  @override
  String build() {
    _loadUsername();
    return 'Explorer'; // Default fallback value
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString(_usernameKey);
    if (savedName != null && savedName.isNotEmpty) {
      state = savedName;
    }
  }

  Future<void> updateUsername(String newName) async {
    final cleaned = newName.trim();
    state = cleaned.isEmpty ? 'Explorer' : cleaned;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, state);
  }
}

final usernameProvider = NotifierProvider<UsernameNotifier, String>(UsernameNotifier.new);
