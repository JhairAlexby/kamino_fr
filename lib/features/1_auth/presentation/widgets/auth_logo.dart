import 'package:flutter/material.dart';

class AuthLogo extends StatelessWidget {
  final double size;

  const AuthLogo({Key? key, this.size = 48}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final maxAllowed = h < 700 ? 48.0 : 72.0;
    final s = size.clamp(32.0, maxAllowed).toDouble();
    return Image.asset(
      'assets/images/kaminoLogo.png',
      height: s,
    );
  }
}
