import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketledger/core/constants/app_colors.dart';
import 'package:pocketledger/presentation/providers/auth_provider.dart';
import 'package:pocketledger/presentation/screens/auth/login_screen.dart';
import 'package:pocketledger/presentation/screens/main_shell_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  void _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final authState = ref.read(authProvider);
    if (authState.status == AuthStatus.authenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShellScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainShellScreen()),
        );
      } else if (next.status == AuthStatus.unauthenticated) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });

    return Scaffold(
      backgroundColor: p.scaffoldBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: p.badgeBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: p.primaryBrand.withOpacity(0.25),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                size: 56,
                color: p.primaryBrand,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'PocketLedger',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: p.textPrimary,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Smart Personal Finance & Budgeting',
              style: TextStyle(
                fontSize: 14,
                color: p.textSecondary,
              ),
            ),
            const SizedBox(height: 44),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(p.primaryBrand),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
