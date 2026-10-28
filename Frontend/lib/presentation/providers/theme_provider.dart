import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/secure_storage_service.dart';
import 'app_providers.dart';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SecureStorageService _storage;

  ThemeModeNotifier(this._storage) : super(ThemeMode.light) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final saved = await _storage.getThemeMode();
    if (saved == 'dark') {
      state = ThemeMode.dark;
    } else if (saved == 'light') {
      state = ThemeMode.light;
    }
  }

  Future<void> toggleTheme() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = next;
    await _storage.saveThemeMode(next == ThemeMode.dark ? 'dark' : 'light');
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _storage.saveThemeMode(mode == ThemeMode.dark ? 'dark' : 'light');
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref.watch(storageServiceProvider));
});

/// Controls whether monetary balances are masked (`••••••`) via the Privacy Eye toggle.
final balancePrivacyProvider = StateProvider<bool>((ref) => false);

/// Controls the active bottom navigation tab index in `MainShellScreen`.
final selectedNavTabProvider = StateProvider<int>((ref) => 0);

/// Optional search query shared with the Ledger / Transactions screen.
final transactionSearchQueryProvider = StateProvider<String>((ref) => '');
