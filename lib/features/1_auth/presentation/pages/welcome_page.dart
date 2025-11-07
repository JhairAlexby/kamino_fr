import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Importa tus componentes
import '../widgets/auth_logo.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_bottom_prompt.dart';

// Importa tu tema y ViewModel
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
              
              // 1. AÑADIMOS EL SINGLECHILDSCROLLVIEW
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Container(
                    // Hacemos que el contenido ocupe al menos el alto de la pantalla
                    height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                    child: Column(
                      children: [
                        const SizedBox(height: 80),
                        const AuthLogo(size: 150),
                        const SizedBox(height: 50),

                        // Asegúrate de que esta imagen exista en 'assets/images/'
                        Image.asset(
                          '../assets/images/welcome_graphic.png', 
                          height: MediaQuery.of(context).size.height * 0.35, 
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 50),

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

                        // 3. QUITAMOS EL SPACER DE AQUÍ
                        // const Spacer(), 
                        
                        // 4. Y AÑADIMOS UN SPACER AQUÍ PARA EMPUJAR LOS BOTONES
                        //    hacia abajo, ahora que el Container tiene altura fija.
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
                        const SizedBox(height: 40), 
                      ],
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