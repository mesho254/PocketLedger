import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/savings_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  String _selectedCurrency = 'USD';
  bool _isSaving = false;
  String? _lastSyncedUserId;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _selectedCurrency = CurrencyFormatter.optionFor(user?.currency).code;
    _lastSyncedUserId = user?.id;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String _getInitials(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return 'PL';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _isSaving = true);
    final success = await ref.read(authProvider.notifier).updateProfile(
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          currency: _selectedCurrency,
        );

    if (!mounted) return;
    setState(() => _isSaving = false);

    final p = context.palette;
    final opt = CurrencyFormatter.optionFor(_selectedCurrency);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: success ? p.primaryBrand : p.expenseRose,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(
          success
              ? 'Profile updated • Active currency: ${opt.shortLabel}'
              : (ref.read(authProvider).errorMessage ?? 'Could not update profile'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<void> _quickSelectCurrency(CurrencyOption option) async {
    setState(() => _selectedCurrency = option.code);
    await ref.read(authProvider.notifier).updateCurrency(option.code);
    if (!mounted) return;
    final p = context.palette;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.primaryBrand,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(
          'Currency switched to ${option.displayLabel} across all screens',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _openChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (_) => const _ChangePasswordDialog(),
    );
  }

  void _confirmLogout() {
    final p = context.palette;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Sign Out',
          style: TextStyle(color: p.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to log out of PocketLedger?',
          style: TextStyle(color: p.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: p.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: p.expenseRose),
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final currency = ref.watch(currencyFormatterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final isMasked = ref.watch(balancePrivacyProvider);

    final txCount = ref.watch(transactionProvider).transactions.length;
    final budgetCount = ref.watch(budgetProvider).budgets.length;
    final goalCount = ref.watch(savingsProvider).goals.length;

    // Sync controllers if user first loads from API
    if (user != null && user.id != _lastSyncedUserId) {
      _lastSyncedUserId = user.id;
      _fullNameController.text = user.fullName;
      _emailController.text = user.email;
      _selectedCurrency = CurrencyFormatter.optionFor(user.currency).code;
    } else if (user != null && _selectedCurrency != CurrencyFormatter.optionFor(user.currency).code) {
      _selectedCurrency = CurrencyFormatter.optionFor(user.currency).code;
    }

    final memberSince = user?.createdAt != null
        ? 'Member since ${DateFormat('MMM yyyy').format(user!.createdAt!)}'
        : 'Verified PocketLedger Member';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        color: p.primaryBrand,
        onRefresh: () => ref.read(authProvider.notifier).checkAuthStatus(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 115),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ===============================================================
              // 1. HERO USER IDENTITY BENTO CARD
              // ===============================================================
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: p.cardSurface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: p.borderSubtle, width: 1),
                  boxShadow: p.cardShadow,
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 82,
                          height: 82,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [p.primaryBrand, p.secondaryTeal],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: p.primaryBrand.withOpacity(0.28),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _getInitials(user?.fullName ?? _fullNameController.text),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: p.incomeGreen,
                            shape: BoxShape.circle,
                            border: Border.all(color: p.cardSurface, width: 2.5),
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      (user?.fullName.isNotEmpty == true)
                          ? user!.fullName
                          : 'PocketLedger User',
                      style: TextStyle(
                        color: p.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (user?.email.isNotEmpty == true)
                          ? user!.email
                          : 'user@pocketledger.app',
                      style: TextStyle(
                        color: p.textSecondary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: p.badgeBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Active Currency: ${currency.option.shortLabel}',
                            style: TextStyle(
                              color: p.badgeText,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: p.nestedSurface,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            memberSince,
                            style: TextStyle(
                              color: p.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Summary Pill Counters
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      decoration: BoxDecoration(
                        color: p.nestedSurface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: p.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _ProfileStatItem(
                              label: 'Transactions',
                              value: '$txCount',
                            ),
                          ),
                          Container(width: 1, height: 30, color: p.borderSubtle),
                          Expanded(
                            child: _ProfileStatItem(
                              label: 'Budgets',
                              value: '$budgetCount',
                            ),
                          ),
                          Container(width: 1, height: 30, color: p.borderSubtle),
                          Expanded(
                            child: _ProfileStatItem(
                              label: 'Goals',
                              value: '$goalCount',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ===============================================================
              // 2. INSTANT GLOBAL CURRENCY SWITCHER BENTO CARD
              // ===============================================================
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: p.cardSurface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: p.borderSubtle, width: 1),
                  boxShadow: p.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Global Currency',
                                style: TextStyle(
                                  color: p.textPrimary,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Tap any currency to update all screens immediately',
                                style: TextStyle(
                                  color: p.textSecondary,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: p.badgeBg,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            currency.symbol,
                            style: TextStyle(
                              color: p.badgeText,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: CurrencyFormatter.supportedCurrencies.map((opt) {
                        final isSelected = currency.code == opt.code;
                        return GestureDetector(
                          onTap: () => _quickSelectCurrency(opt),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                            decoration: BoxDecoration(
                              color: isSelected ? p.primaryBrand : p.nestedSurface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? p.primaryBrand : p.borderSubtle,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  opt.symbol,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : p.primaryBrand,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  opt.code,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : p.textPrimary,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ===============================================================
              // 3. PERSONAL INFORMATION EDIT FORM BENTO CARD
              // ===============================================================
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: p.cardSurface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: p.borderSubtle, width: 1),
                  boxShadow: p.cardShadow,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Personal Details',
                        style: TextStyle(
                          color: p.textPrimary,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Update your display name, email address, and default currency.',
                        style: TextStyle(
                          color: p.textSecondary,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 18),

                      CustomTextField(
                        controller: _fullNameController,
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        prefixIcon: Icons.person_outline_rounded,
                        validator: (val) {
                          if (val == null || val.trim().length < 2) {
                            return 'Full name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        hint: 'you@example.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Email address is required';
                          }
                          if (!val.contains('@') || !val.contains('.')) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Preferred Currency',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: p.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: CurrencyFormatter.supportedCurrencies
                                    .any((c) => c.code == _selectedCurrency)
                                ? _selectedCurrency
                                : 'USD',
                            isExpanded: true,
                            dropdownColor: p.cardSurface,
                            style: TextStyle(
                              color: p.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              fillColor: p.nestedSurface,
                              prefixIcon: Icon(
                                Icons.currency_exchange_rounded,
                                color: p.textSecondary,
                                size: 20,
                              ),
                            ),
                            items: CurrencyFormatter.supportedCurrencies.map((curr) {
                              return DropdownMenuItem(
                                value: curr.code,
                                child: Text(curr.displayLabel),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedCurrency = val);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      PrimaryButton(
                        text: 'Save Profile Changes',
                        icon: Icons.check_circle_outline_rounded,
                        isLoading: _isSaving,
                        onPressed: _saveProfile,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // ===============================================================
              // 4. PREFERENCES & SECURITY BENTO CARD
              // ===============================================================
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: p.cardSurface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: p.borderSubtle, width: 1),
                  boxShadow: p.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preferences & Security',
                      style: TextStyle(
                        color: p.textPrimary,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Dark Mode Toggle Row
                    _PreferenceRow(
                      icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      title: 'Dark Mode',
                      subtitle: isDark ? 'Obsidian & Luminous Teal active' : 'Novbank Alabaster Light active',
                      trailing: Switch.adaptive(
                        value: isDark,
                        activeColor: p.primaryBrand,
                        onChanged: (_) => ref.read(themeModeProvider.notifier).toggleTheme(),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Privacy Mode Toggle Row
                    _PreferenceRow(
                      icon: isMasked ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      title: 'Privacy Balance Mask',
                      subtitle: 'Hide monetary figures (${currency.masked('••••')})',
                      trailing: Switch.adaptive(
                        value: isMasked,
                        activeColor: p.primaryBrand,
                        onChanged: (val) => ref.read(balancePrivacyProvider.notifier).state = val,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Change Password Action Row
                    InkWell(
                      onTap: _openChangePasswordDialog,
                      borderRadius: BorderRadius.circular(18),
                      child: _PreferenceRow(
                        icon: Icons.lock_reset_rounded,
                        title: 'Change Password',
                        subtitle: 'Update your account security credentials',
                        trailing: Icon(Icons.chevron_right_rounded, color: p.textMuted),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Sign Out Action Row
                    InkWell(
                      onTap: _confirmLogout,
                      borderRadius: BorderRadius.circular(18),
                      child: _PreferenceRow(
                        icon: Icons.logout_rounded,
                        iconColor: p.expenseRose,
                        title: 'Sign Out',
                        titleColor: p.expenseRose,
                        subtitle: 'Log out of your PocketLedger session',
                        trailing: Icon(Icons.chevron_right_rounded, color: p.expenseRose),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileStatItem extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileStatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: p.textPrimary,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: p.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _PreferenceRow extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final Color? titleColor;
  final String subtitle;
  final Widget trailing;

  const _PreferenceRow({
    required this.icon,
    this.iconColor,
    required this.title,
    this.titleColor,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final effectiveIconColor = iconColor ?? p.primaryBrand;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: p.nestedSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: p.iconBoxSurface,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: effectiveIconColor, size: 20),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor ?? p.textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: p.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _ChangePasswordDialog extends ConsumerStatefulWidget {
  const _ChangePasswordDialog();

  @override
  ConsumerState<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final err = await ref.read(authProvider.notifier).changePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (err == null) {
      Navigator.pop(context);
      final p = context.palette;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: p.incomeGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: const Text(
            'Password changed successfully',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      );
    } else {
      setState(() => _error = err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Dialog(
      backgroundColor: p.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: p.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Change Password',
                  style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 16),
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: p.expenseRose.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _error!,
                      style: TextStyle(color: p.expenseRose, fontSize: 12.5),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                CustomTextField(
                  controller: _currentPasswordController,
                  label: 'Current Password',
                  hint: 'Enter current password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Enter your current password';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _newPasswordController,
                  label: 'New Password',
                  hint: 'At least 6 characters',
                  prefixIcon: Icons.vpn_key_outlined,
                  obscureText: true,
                  validator: (val) {
                    if (val == null || val.length < 6) {
                      return 'New password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm New Password',
                  hint: 'Re-enter new password',
                  prefixIcon: Icons.check_circle_outline,
                  obscureText: true,
                  validator: (val) {
                    if (val != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 22),
                PrimaryButton(
                  text: 'Update Password',
                  isLoading: _isSubmitting,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

