import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'auth/login_screen.dart';
import 'budgets/budgets_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'profile/profile_screen.dart';
import 'savings/savings_goals_screen.dart';
import 'transactions/add_edit_transaction_sheet.dart';
import 'transactions/transactions_screen.dart';

class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key});

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  void _openAddTransactionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddEditTransactionSheet(),
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

  String _getInitials(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return 'PL';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final user = ref.watch(authProvider).user;
    final rawIndex = ref.watch(selectedNavTabProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    const tabs = <Widget>[
      DashboardScreen(),
      TransactionsScreen(),
      BudgetsScreen(),
      SavingsGoalsScreen(),
      ProfileScreen(),
    ];
    final currentIndex = rawIndex.clamp(0, tabs.length - 1);

    return Scaffold(
      backgroundColor: p.scaffoldBg,
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(66),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left User Avatar Pill (tapping opens Profile Screen)
                GestureDetector(
                  onTap: () => ref.read(selectedNavTabProvider.notifier).state = 4,
                  child: Tooltip(
                    message: 'View & Edit Profile',
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [p.primaryBrand, p.secondaryTeal],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: currentIndex == 4 ? p.primaryBrand : p.cardSurface,
                          width: 2.2,
                        ),
                        boxShadow: p.cardShadow,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _getInitials(user?.fullName),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),

                // Centered Brand Title ("Novbank" -> "PocketLedger")
                Text(
                  'PocketLedger',
                  style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),

                // Right Circular Pill Buttons (Theme Switcher + Sign Out)
                Row(
                  children: [
                    _TopCircleIconButton(
                      icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_outlined,
                      tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                      onTap: () => ref.read(themeModeProvider.notifier).toggleTheme(),
                    ),
                    const SizedBox(width: 8),
                    _TopCircleIconButton(
                      icon: Icons.logout_rounded,
                      tooltip: 'Sign Out',
                      onTap: _confirmLogout,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Subtle ambient radial glow in Dark Mode (inspired by Pinterest Pin #2)
          if (p.isDark)
            Positioned(
              top: -80,
              left: 30,
              right: 30,
              child: IgnorePointer(
                child: Container(
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        p.primaryBrand.withOpacity(0.16),
                        p.secondaryTeal.withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

          IndexedStack(
            index: currentIndex,
            children: tabs,
          ),

          // Floating Glassmorphic Pill Bottom Dock (matching Novbank Center Screen & Pinterest Pin #2)
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16, left: 24, right: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Frosted capsule navigation pill
                    ClipRRect(
                      borderRadius: BorderRadius.circular(38),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: Container(
                          height: 64,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: p.dockBackground,
                            borderRadius: BorderRadius.circular(38),
                            border: Border.all(
                              color: Colors.white.withOpacity(p.isDark ? 0.10 : 0.22),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.22),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _DockNavItem(
                                icon: Icons.home_outlined,
                                activeIcon: Icons.home_rounded,
                                label: 'Home',
                                isSelected: currentIndex == 0,
                                onTap: () => ref.read(selectedNavTabProvider.notifier).state = 0,
                              ),
                              const SizedBox(width: 4),
                              _DockNavItem(
                                icon: Icons.swap_horiz_rounded,
                                activeIcon: Icons.swap_horiz_rounded,
                                label: 'Ledger',
                                isSelected: currentIndex == 1,
                                onTap: () => ref.read(selectedNavTabProvider.notifier).state = 1,
                              ),
                              const SizedBox(width: 4),
                              _DockNavItem(
                                icon: Icons.account_balance_wallet_outlined,
                                activeIcon: Icons.account_balance_wallet_rounded,
                                label: 'Budgets',
                                isSelected: currentIndex == 2,
                                onTap: () => ref.read(selectedNavTabProvider.notifier).state = 2,
                              ),
                              const SizedBox(width: 4),
                              _DockNavItem(
                                icon: Icons.bar_chart_rounded,
                                activeIcon: Icons.bar_chart_rounded,
                                label: 'Goals',
                                isSelected: currentIndex == 3,
                                onTap: () => ref.read(selectedNavTabProvider.notifier).state = 3,
                              ),
                              const SizedBox(width: 4),
                              _DockNavItem(
                                icon: Icons.person_outline_rounded,
                                activeIcon: Icons.person_rounded,
                                label: 'Profile',
                                isSelected: currentIndex == 4,
                                onTap: () => ref.read(selectedNavTabProvider.notifier).state = 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Circular Primary Quick-Add Button beside the floating dock (Pinterest Pin #2)
                    GestureDetector(
                      onTap: _openAddTransactionSheet,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [p.primaryBrand, p.secondaryTeal],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: p.primaryBrand.withOpacity(0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopCircleIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _TopCircleIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: p.cardSurface,
            shape: BoxShape.circle,
            border: Border.all(color: p.borderSubtle, width: 1),
            boxShadow: p.cardShadow,
          ),
          child: Icon(
            icon,
            color: p.textPrimary,
            size: 19,
          ),
        ),
      ),
    );
  }
}

class _DockNavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DockNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Tooltip(
      message: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: 46,
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? p.dockActivePill : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? p.dockActiveIcon : p.dockInactiveIcon,
            size: 22,
          ),
        ),
      ),
    );
  }
}
