import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:kamino_fr/core/app_theme.dart'; 

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _headerSlideController;
  late Animation<Offset> _headerSlideAnimation;
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _controller.forward();

    _headerSlideController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerSlideController,
      curve: Curves.easeOutExpo,
    ));
    _headerSlideController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _headerSlideController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
    // Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    
    // 1. Establecemos el estilo de la barra de estado ANTES de construir el Scaffold.
    // Esto asegura que la barra (fuera del SafeArea) sea negra y los iconos blancos.
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: AppTheme.textBlack, // Fondo negro
      statusBarIconBrightness: Brightness.light, // Iconos blancos
      statusBarBrightness: Brightness.dark, // Para iOS
    ));

    // 2. Usamos SafeArea para que el Scaffold comience DEBAJO de la barra de estado.
    return SafeArea(
      child: Scaffold(
        // 3. El fondo del Scaffold ahora está DENTRO del área segura.
        backgroundColor: AppTheme.textBlack,
        
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // 4. El "Header" de bienvenida (Tarjeta Menta)
              Container(
                width: double.infinity,
                // Ajustamos el padding superior, ya no necesitamos 80px
                // porque el SafeArea ya nos dio espacio.
                padding: const EdgeInsets.fromLTRB(30.0, 50.0, 30.0, 60.0), 
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryMint,
                      AppTheme.primaryMint.withOpacity(0.8),
                      AppTheme.primaryMint.withOpacity(0.9),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryMint.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: AnimatedBuilder(
                  animation: _headerSlideController,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _headerSlideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'H',
                                  style: TextStyle(
                                    fontSize: 50,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.textBlack,
                                  ),
                                ),
                                TextSpan(
                                  text: 'ola!',
                                  style: TextStyle(
                                    fontSize: 50,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8), 
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Bienvenido a ',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Kamino',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // 5. El resto del contenido
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50.0),

                    const Text(
                      'Iniciar Sesion',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 20.0),

                    Form(
                      key: _formKey,
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _fadeAnimation.value,
                            child: Transform.translate(
                              offset: _slideAnimation.value,
                              child: child,
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                hintText: 'Tu@correo.com',
                                filled: true,
                                fillColor: AppTheme.background.withOpacity(0.9),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(color: AppTheme.primaryMint, width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(fontSize: 16),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'El correo es obligatorio';
                                }
                                if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}").hasMatch(value.trim())) {
                                  return 'Ingresa un correo válido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20.0),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                hintText: 'Contraseña',
                                filled: true,
                                fillColor: AppTheme.background.withOpacity(0.9),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(color: AppTheme.primaryMint, width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                              ),
                              obscureText: _obscurePassword,
                              style: const TextStyle(fontSize: 16),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'La contraseña es obligatoria';
                                }
                                if (value.length < 6) {
                                  return 'La contraseña debe tener al menos 6 caracteres';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10.0),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  '¿Olvidaste tu contraseña?',
                                  style: TextStyle(
                                    color: AppTheme.primaryMint,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 25.0),
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryMint,
                                  foregroundColor: AppTheme.textBlack,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 5,
                                  shadowColor: AppTheme.primaryMint.withOpacity(0.3),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: AppTheme.textBlack,
                                          strokeWidth: 3,
                                        ),
                                      )
                                    : const Text(
                                        'Iniciar Sesión',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30.0),

                    Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'No tienes cuenta? ',
                            style: TextStyle(color: Colors.white),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Registrate',
                              style: TextStyle(
                                color: AppTheme.primaryMint, 
                                fontWeight: FontWeight.w700
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20.0),

                    Align(
                alignment: Alignment.center,
                child: Image.asset(
                  // CAMBIA ESTO por el nombre exacto de tu archivo de logo
                  'assets/images/logo.png', 
                  
                  // Juega con esta altura para ajustar el tamaño
                  height: 100, 
                ),
              ),
                    
                    const SizedBox(height: 50.0),
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