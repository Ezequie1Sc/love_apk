import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

import 'package:love_app/src/pages/minigame_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> 
    with SingleTickerProviderStateMixin {
  final TextEditingController _codeController = TextEditingController();
  final ConfettiController _confettiController = ConfettiController(
    duration: const Duration(seconds: 5),
  );
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  String? _errorMessage;
  bool _isValidating = false;
  int _attempts = 0;

  final List<String> _hints = [
    "Es el día más especial del año",
    "Formato Día/Mes (DD/MM)",
    "Nació una persona increíble",
    "Ese día tu mundo cambió para siempre",
    "Recuerda cuándo empezó tu historia",
    "¿Qué día celebramos tu vida?",
    "Ese día que esperas con ilusión",
    "Una fecha que siempre recordamos",
    "Tu día favorito en el calendario",
    "Ese día que hace sonreír a todos",
    "Piensa en velitas, pastel y deseos",
    "La razón de tantas sonrisas",
    "El día que todo valió la pena"
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  void _checkCode() async {
    if (_isValidating) return;

    setState(() {
      _isValidating = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    if (_codeController.text.trim() == "2507") {
      _confettiController.play();
      _controller.forward(from: 0);
      _showSuccessDialog();
    } else {
      setState(() {
        _attempts++;
        _errorMessage = _hints[_attempts > _hints.length ? _hints.length - 1 : _attempts - 1];
        _controller.forward(from: 0);
      });
    }

    setState(() {
      _isValidating = false;
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: Container(
                  padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.06),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.pink.shade50, Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Icon(
                          Icons.favorite,
                          color: Colors.pink.shade400,
                          size: MediaQuery.of(context).size.width * 0.2,
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                      Text(
                        '¡Acceso Concedido!',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.06,
                          fontWeight: FontWeight.w700,
                          color: Colors.pink.shade600,
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                      Text(
                        'Feliz cumpleaños mi amor ❤️🎂',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink.shade400,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width * 0.08,
                            vertical: MediaQuery.of(context).size.height * 0.02,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CakeCatcherGame(),
                            ),
                          );
                        },
                        child: Text(
                          'Continuar',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _controller.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;
    final isPortrait = screenSize.height > screenSize.width;

    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
          _buildAnimatedBackground(),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: [Colors.pink, Colors.red, Colors.purple, Colors.white],
              emissionFrequency: 0.03,
              numberOfParticles: 40,
              gravity: 0.05,
              maxBlastForce: 20,
            ),
          ),

          // Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16 : 24,
                  vertical: isSmallScreen ? 8 : 16,
                ),
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildAccessCard(),
                  ),
                ),
              ),
            ),
          ),

          // Error Message
          if (_errorMessage != null)
            Positioned(
              top: isSmallScreen ? 60 : 80,
              left: isSmallScreen ? 16 : 24,
              right: isSmallScreen ? 16 : 24,
              child: _buildErrorCard(),
            ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedContainer(
      duration: const Duration(seconds: 10),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.5,
          colors: [
            Colors.pink.shade50,
            Colors.purple.shade50,
            Colors.white,
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -0.5),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutBack,
        ),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.shade200, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red.shade400,
                size: MediaQuery.of(context).size.width * 0.06,
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.03),
              Expanded(
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: MediaQuery.of(context).size.width * 0.035,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: Colors.red.shade400,
                  size: MediaQuery.of(context).size.width * 0.05,
                ),
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccessCard() {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: isSmallScreen ? screenSize.width * 0.9 : 400),
      padding: EdgeInsets.all(isSmallScreen ? 20 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated Heart Icon
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              Icons.favorite_border,
              size: isSmallScreen ? screenSize.width * 0.2 : 64,
              color: Colors.pink.shade400,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 24),

          // Title
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [Colors.pink.shade400, Colors.purple.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              'Acceso Especial',
              style: TextStyle(
                fontSize: isSmallScreen ? screenSize.width * 0.07 : 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: isSmallScreen ? 4 : 8),

          // Subtitle
          Text(
            'Ingresa la fecha especial',
            style: TextStyle(
              fontSize: isSmallScreen ? screenSize.width * 0.04 : 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 24),

          // Date Input Field
          _buildDateInputField(),
          SizedBox(height: isSmallScreen ? 16 : 24),

          // Access Button
          _buildAccessButton(),
          SizedBox(height: isSmallScreen ? 12 : 16),

          // Help Button
          TextButton.icon(
            onPressed: _showHintDialog,
            icon: Icon(
              Icons.help_outline,
              size: isSmallScreen ? screenSize.width * 0.05 : 20,
              color: Colors.pink.shade400,
            ),
            label: Text(
              'Necesito una pista',
              style: TextStyle(
                color: Colors.pink.shade400,
                fontSize: isSmallScreen ? screenSize.width * 0.035 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: isSmallScreen ? 6 : 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateInputField() {
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: TextField(
        controller: _codeController,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: isSmallScreen ? 16 : 18,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade800,
        ),
        decoration: InputDecoration(
          hintText: "DD/MM",
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w500,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 16,
            vertical: isSmallScreen ? 12 : 16,
          ),
          suffixIcon: Icon(
            Icons.calendar_today_rounded,
            color: Colors.pink.shade300,
            size: isSmallScreen ? 18 : 20,
          ),
        ),
        onChanged: (value) {
          if (_errorMessage != null) {
            setState(() {
              _errorMessage = null;
            });
          }
        },
      ),
    );
  }

  Widget _buildAccessButton() {
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: ElevatedButton(
        onPressed: _isValidating ? null : _checkCode,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pink.shade400,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 36 : 48,
            vertical: isSmallScreen ? 12 : 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          shadowColor: Colors.pink.withOpacity(0.4),
        ),
        child: _isValidating
            ? SizedBox(
                width: isSmallScreen ? 20 : 24,
                height: isSmallScreen ? 20 : 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'VERIFICAR',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  void _showHintDialog() {
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  size: isSmallScreen ? 36 : 48,
                  color: Colors.pink.shade400,
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                Text(
                  'Pista Especial',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.pink.shade600,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 8 : 12),
                Text(
                  _hints[_attempts > _hints.length ? _hints.length - 1 : _attempts],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 16 : 24),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'ENTENDIDO',
                    style: TextStyle(
                      color: Colors.pink.shade400,
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}