import 'dart:math';
import 'package:flutter/material.dart';
import 'package:love_app/src/pages/loggin_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<FloatingHeart> _hearts = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(_generateHearts)
     ..forward();

    // Navegar después de 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  void _generateHearts() {
    if (_random.nextDouble() > 0.7) { // Frecuencia de generación
      setState(() {
        _hearts.add(FloatingHeart(
          size: 10 + _random.nextDouble() * 20,
          x: _random.nextDouble(),
          speed: 0.5 + _random.nextDouble(),
          color: Colors.pink[200]!.withOpacity(0.7),
        ));
      });
    }

    // Mover corazones existentes
    setState(() {
      for (var heart in _hearts) {
        heart.y -= 0.01 * heart.speed;
      }
      _hearts.removeWhere((heart) => heart.y < -0.2);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F5),
      body: Stack(
        children: [
          // Fondo con gradiente
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0xFFFFF0F0), Color(0xFFFFD6E0)],
                center: Alignment.topCenter,
                radius: 1.5,
              ),
            ),
          ),

          // Corazones flotantes
          ..._hearts.map((heart) => Positioned(
            left: heart.x * MediaQuery.of(context).size.width,
            top: heart.y * MediaQuery.of(context).size.height,
            child: Opacity(
              opacity: heart.opacity,
              child: Icon(
                Icons.favorite,
                color: heart.color,
                size: heart.size,
              ),
            ),
          )),

          // Contenido principal
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite,
                  color: Colors.pinkAccent,
                  size: 100,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Feliz cumpleaños',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.pinkAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FloatingHeart {
  double x;
  double y;
  double size;
  double speed;
  Color color;
  double opacity;

  FloatingHeart({
    required this.size,
    required this.x,
    required this.speed,
    required this.color,
    this.y = 1.2,
    this.opacity = 1.0,
  });
}