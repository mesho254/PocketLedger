import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../presentation/providers/auth_provider.dart';

class CurrencyOption {
  final String code;
  final String symbol;
  final String name;
  final bool spaceAfterSymbol;

  const CurrencyOption({
    required this.code,
    required this.symbol,
    required this.name,
    this.spaceAfterSymbol = false,
  });

  String get displayLabel => '$code ($symbol) — $name';
  String get shortLabel => '$code ($symbol)';
}

class CurrencyFormatter {
  final CurrencyOption option;

  const CurrencyFormatter(this.option);

  static const List<CurrencyOption> supportedCurrencies = [
    CurrencyOption(code: 'USD', symbol: '\$', name: 'US Dollar'),
    CurrencyOption(code: 'EUR', symbol: '€', name: 'Euro'),
    CurrencyOption(code: 'GBP', symbol: '£', name: 'British Pound'),
    CurrencyOption(
        code: 'KES',
        symbol: 'KSh',
        name: 'Kenyan Shilling',
        spaceAfterSymbol: true),
    CurrencyOption(code: 'NGN', symbol: '₦', name: 'Nigerian Naira'),
    CurrencyOption(
        code: 'ZAR',
        symbol: 'R',
        name: 'South African Rand',
        spaceAfterSymbol: true),
    CurrencyOption(code: 'INR', symbol: '₹', name: 'Indian Rupee'),
    CurrencyOption(code: 'CAD', symbol: 'CA\$', name: 'Canadian Dollar'),
    CurrencyOption(code: 'AUD', symbol: 'A\$', name: 'Australian Dollar'),
    CurrencyOption(code: 'JPY', symbol: '¥', name: 'Japanese Yen'),
  ];

  static CurrencyOption optionFor(String? rawCode) {
    final code = (rawCode ?? 'USD').toUpperCase().trim();
    for (final item in supportedCurrencies) {
      if (item.code == code) return item;
    }
    if (code.isEmpty) return supportedCurrencies.first;
    return CurrencyOption(
      code: code,
      symbol: code,
      name: code,
      spaceAfterSymbol: true,
    );
  }

  factory CurrencyFormatter.fromCode(String? code) {
    return CurrencyFormatter(optionFor(code));
  }

  String get code => option.code;
  String get symbol => option.symbol;
  String get name => option.name;

  String get _prefix =>
      option.spaceAfterSymbol ? '${option.symbol} ' : option.symbol;

  /// Formats a currency amount with the active currency symbol (e.g. "$1,250.00" or "KSh 1,250.00")
  String format(double amount, {int decimalDigits = 2}) {
    final digits = option.code == 'JPY' ? 0 : decimalDigits;
    return NumberFormat.currency(
      symbol: _prefix,
      decimalDigits: digits,
    ).format(amount);
  }

  /// Formats only the numeric portion with grouping commas (e.g. "48,840.24")
  /// used next to the superscript symbol in the Hero Balance display.
  String formatNumberOnly(double amount, {int decimalDigits = 2}) {
    final digits = option.code == 'JPY' ? 0 : decimalDigits;
    return NumberFormat.currency(
      symbol: '',
      decimalDigits: digits,
    ).format(amount).trim();
  }

  /// Formats compact currency amounts (e.g. "$12.4K" or "KSh 12.4K")
  String formatCompact(double amount, {int decimalDigits = 1}) {
    return NumberFormat.compactCurrency(
      symbol: _prefix,
      decimalDigits: decimalDigits,
    ).format(amount);
  }

  /// Masked representation when privacy mode is enabled (e.g. "$••••••" or "KSh ••••••")
  String masked([String dots = '••••••']) => '$_prefix$dots';
}

/// Reactive provider that rebuilds all dependent screens/widgets whenever the user's currency changes.
final currencyFormatterProvider = Provider<CurrencyFormatter>((ref) {
  final currencyCode = ref.watch(
    authProvider.select((state) => state.user?.currency ?? 'USD'),
  );
  return CurrencyFormatter.fromCode(currencyCode);
});
