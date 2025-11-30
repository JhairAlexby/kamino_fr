import 'package:flutter/material.dart';

class AppTheme {
  
  // --- TU NUEVA PALETA ---
  static const Color primaryMint = Color(0xFF85E6C0);
  static const Color primaryMintDark = Color(0xFF6BB39B);
  static const Color background = Color(0xFFF7F4E8); 
  static const Color textBlack = Color(0xFF181A20);
  static const Color lightMintBackground = Color(0xFFDAF3EA);

  static ThemeData getTheme() {
    return ThemeData(
      // 1. Fuente
      fontFamily: 'Inter',
      
      // 2. Esquema de colores principal (Corregido)
      primaryColor: primaryMint,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryMint,
        primary: primaryMint,
        surface: background, 
        onSurface: textBlack, // Color de texto sobre el fondo
      ),
      
      scaffoldBackgroundColor: background, // Fondo de todas las pantallas

      // 3. Tema de botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryMint,
          foregroundColor: textBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // 4. Tema de campos de texto (Inputs)
      inputDecorationTheme: InputDecorationTheme(
         border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey.shade400),
         ),
         enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey.shade400),
         ),
         focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: primaryMintDark, width: 2.0), 
         ),
      ),

      // 5. Tema de texto principal
      textTheme: const TextTheme(
        // Body text (Texto normal - ahora en negrita w600)
        bodyLarge: TextStyle(color: textBlack, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(color: textBlack, fontWeight: FontWeight.w600),
        bodySmall: TextStyle(color: textBlack, fontWeight: FontWeight.w600),
        
        // Titles & Headlines (Títulos - más negrita que el texto normal w800)
        titleLarge: TextStyle(color: textBlack, fontWeight: FontWeight.w800),
        titleMedium: TextStyle(color: textBlack, fontWeight: FontWeight.w800),
        titleSmall: TextStyle(color: textBlack, fontWeight: FontWeight.w800),
        
        headlineLarge: TextStyle(color: textBlack, fontWeight: FontWeight.w800),
        headlineMedium: TextStyle(color: textBlack, fontWeight: FontWeight.w800),
        headlineSmall: TextStyle(color: textBlack, fontWeight: FontWeight.w800),
        
        displayLarge: TextStyle(color: textBlack, fontWeight: FontWeight.w800),
        displayMedium: TextStyle(color: textBlack, fontWeight: FontWeight.w800),
        displaySmall: TextStyle(color: textBlack, fontWeight: FontWeight.w800),
        
        labelLarge: TextStyle(color: textBlack, fontWeight: FontWeight.w700),
        labelMedium: TextStyle(color: textBlack, fontWeight: FontWeight.w700),
        labelSmall: TextStyle(color: textBlack, fontWeight: FontWeight.w700),
      ),
      
      // 6. Tema de AppBar (Corregido)
      appBarTheme: const AppBarTheme(
        backgroundColor: background, 
        foregroundColor: textBlack, 
        elevation: 0,
        scrolledUnderElevation: 0,
      )
    );
  }
}