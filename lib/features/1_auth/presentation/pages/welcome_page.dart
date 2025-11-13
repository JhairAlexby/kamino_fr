import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../widgets/auth_logo.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_bottom_prompt.dart';
import 'package:kamino_fr/core/app_theme.dart';
import '../provider/welcome_provider.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: AppTheme.textBlack,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    return ChangeNotifierProvider(
      create: (_) => WelcomeProvider(),
      child: Scaffold(
        backgroundColor: AppTheme.textBlack,
        body: SafeArea(
          child: Consumer<WelcomeProvider>(
            builder: (context, provider, child) {
              final size = MediaQuery.of(context).size;
              final insets = MediaQuery.of(context).padding;
              final viewportHeight = size.height - insets.top - insets.bottom;
              final gapTop = (viewportHeight * 0.1).clamp(48.0, 100.0) as double;
              final gapL = (viewportHeight * 0.05).clamp(24.0, 60.0) as double;
              return SingleChildScrollView(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: SizedBox(
                        height: viewportHeight,
                        child: Column(
                          children: [
                            SizedBox(height: gapTop),
                            const AuthLogo(size: 150),
                            SizedBox(height: gapL),
                            RichText(
                              textAlign: TextAlign.center,
                              text: const TextSpan(
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                                children: [
                                  TextSpan(text: 'Conecta. '),
                                  TextSpan(
                                    text: 'Descubre.',
                                    style: TextStyle(color: AppTheme.primaryMint),
                                  ),
                                  TextSpan(text: ' Avanza.'),
                                ],
                              ),
                            ),
                            const Spacer(),
                            AuthPrimaryButton(
                              text: 'Registrate',
                              isLoading: false,
                              onPressed: () => provider.navigateToRegister(context),
                            ),
                            const SizedBox(height: 20),
                            AuthBottomPrompt(
                              text: 'Ya tienes cuenta? ',
                              actionText: 'Inicia Sesion',
                              onTap: () => provider.navigateToLogin(context),
                            ),
                            SizedBox(height: gapL),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

