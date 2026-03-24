import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/async_value_widget.dart';
import '../application/auth_controller.dart';
import 'login_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return AsyncValueWidget(
      value: authState,
      loadingMessage: 'Restoring your AIRA session...',
      data: (user) {
        if (user == null) {
          return const LoginScreen();
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            context.go('/app');
          }
        });

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
