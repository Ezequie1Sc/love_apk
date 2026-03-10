import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:url_launcher/url_launcher.dart';

class CakeCatcherGame extends StatefulWidget {
  const CakeCatcherGame({super.key});

  @override
  State<CakeCatcherGame> createState() => _CakeCatcherGameState();
}

class _CakeCatcherGameState extends State<CakeCatcherGame> {
  // Variables del jugador
  double playerX = 0.5;
  double playerY = 0.85;
  double playerWidth = 0.25;
  double playerHeight = 0.12;
  String playerImage = 'assets/pi.png';

  // Estado del juego
  int lives = 3;
  bool gameOver = false;
  bool gameWon = false;
  bool gameStarted = false;
  int score = 0;
  final int cakesToWin = 10;
  int currentNotification = 0;

  // Objetos que caen
  List<FallingItem> items = [];
  Random random = Random();

  // Controladores
  late Timer gameTimer;
  late Timer itemTimer;
  AudioPlayer audioPlayer = AudioPlayer();
  late ConfettiController _confettiController;
  late ConfettiController _waterfallConfettiController;

  // Efectos visuales
  bool showHeartEffect = false;
  double heartEffectX = 0.5;
  double heartEffectSize = 0.0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 10));
    _waterfallConfettiController = ConfettiController(duration: const Duration(seconds: 5));
    _playBackgroundMusic();
  }

  void _playBackgroundMusic() async {
    await audioPlayer.setSource(AssetSource('assets/katawaredoki.mp3'));
    await audioPlayer.setVolume(0.3);
    await audioPlayer.resume();
  }

  void _startGameplay() {
    setState(() {
      gameOver = false;
      gameWon = false;
      gameStarted = true;
      currentNotification = 2;
      lives = 3;
      score = 0;
      items.clear();
      showHeartEffect = false;
    });

    itemTimer = Timer.periodic(900.ms, (timer) {
      if (!gameOver && !gameWon && gameStarted) {
        _addFallingItem();
      }
    });

    gameTimer = Timer.periodic(16.ms, (timer) {
      if (!gameOver && !gameWon && gameStarted) {
        _updateGame();
      }
    });
  }

  void _addFallingItem() {
    setState(() {
      bool isGood = random.nextDouble() > 0.3;
      items.add(FallingItem(
        x: random.nextDouble() * 0.8 + 0.1,
        size: random.nextDouble() * 0.15 + 0.08,
        speed: random.nextDouble() * 0.005 + 0.003,
        isGood: isGood,
        type: isGood ? _getRandomGoodType() : _getRandomBadType(),
        rotation: random.nextDouble() * 0.2 - 0.1,
      ));
    });
  }

  String _getRandomGoodType() => ['🎂', '🍰', '🎁', '🎈', '🌸', '💝', '✨'][random.nextInt(7)];
  String _getRandomBadType() => ['💣', '☠️', '👎', '💔'][random.nextInt(4)];

  void _updateGame() {
    setState(() {
      // Actualizar posición de los objetos
      for (var item in items) {
        item.y += item.speed;
        item.rotation += 0.01;
      }

      // Eliminar objetos que salieron de la pantalla
      items.removeWhere((item) => item.y > 1.2);

      // Detección de colisiones
      for (var item in List.from(items)) {
        if (item.y > playerY - playerHeight/2 && item.y < playerY + playerHeight/2 && 
            item.x > playerX - playerWidth/2 && item.x < playerX + playerWidth/2) {
          
          if (item.isGood) {
            score++;
            _showHeartEffect(item.x);
            if (score >= cakesToWin) {
              gameWon = true;
              itemTimer.cancel();
              _confettiController.play();
              _waterfallConfettiController.play();
              Future.delayed(1.seconds, () {
                setState(() => currentNotification = 3);
              });
            }
          } else {
            lives--;
            if (lives <= 0) {
              gameOver = true;
              itemTimer.cancel();
              Future.delayed(500.ms, () {
                setState(() => currentNotification = 4);
              });
            }
          }
          items.remove(item);
        }
      }
    });
  }

  void _showHeartEffect(double x) {
    setState(() {
      showHeartEffect = true;
      heartEffectX = x;
      heartEffectSize = 0.0;
    });

    Timer.periodic(16.ms, (timer) {
      if (heartEffectSize < 0.3) {
        setState(() => heartEffectSize += 0.01);
      } else {
        timer.cancel();
        Future.delayed(300.ms, () {
          setState(() => showHeartEffect = false);
        });
      }
    });
  }

  void _movePlayer(double dx) {
    setState(() {
      playerX = (playerX + dx / MediaQuery.of(context).size.width * 2)
          .clamp(playerWidth/2, 1.0 - playerWidth/2);
    });
  }

  void _nextNotification() {
    setState(() {
      if (currentNotification < 3) {
        currentNotification++;
        if (currentNotification == 2) _startGameplay();
      }
    });
  }

  Future<void> _launchURL() async {
    final Uri url = Uri.parse('/');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  void dispose() {
    gameTimer.cancel();
    itemTimer.cancel();
    audioPlayer.dispose();
    _confettiController.dispose();
    _waterfallConfettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Fondo animado con gradiente
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFFFFCDD2).withOpacity(0.8),
                      const Color(0xFFF8BBD0).withOpacity(0.8),
                      const Color(0xFFE1BEE7).withOpacity(0.8),
                    ],
                  ),
                ),
              ),
              
              // Patrón de corazones de fondo
              Positioned.fill(
                child: Opacity(
                  opacity: 0.1,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isSmallScreen ? 6 : 8,
                    ),
                    itemCount: isSmallScreen ? 36 : 64,
                    itemBuilder: (context, index) {
                      return const Center(
                        child: Text('❤️', style: TextStyle(fontSize: 24)),
                      );
                    },
                  ),
                ),
              ),
              
              // Confeti
              _buildConfetti(),
              
              // Contenido principal
              SafeArea(
                child: GestureDetector(
                  onPanUpdate: (details) => _movePlayer(details.delta.dx),
                  child: Stack(
                    children: [
                      // Notificación de bienvenida
                      if (currentNotification == 0) 
                        _buildWelcomeNotification(isSmallScreen),
                      
                      // Notificación de instrucciones
                      if (currentNotification == 1) 
                        _buildInstructionsNotification(isSmallScreen),
                      
                      // Juego activo
                      if (currentNotification == 2) ...[
                        // Objetos que caen
                        for (var item in items)
                          Positioned(
                            left: screenSize.width * item.x,
                            top: screenSize.height * item.y,
                            child: Transform.rotate(
                              angle: item.rotation,
                              child: Text(
                                item.type,
                                style: TextStyle(
                                  fontSize: screenSize.width * item.size,
                                  color: item.isGood ? _getColorForItem(item.type) : Colors.black,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 5,
                                      color: Colors.black.withOpacity(0.5),
                                      offset: const Offset(1, 1),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        
                        // Efecto de corazón
                        if (showHeartEffect)
                          Positioned(
                            left: screenSize.width * (heartEffectX - heartEffectSize/2),
                            top: screenSize.height * (playerY - 0.2),
                            child: Text(
                              '💖',
                              style: TextStyle(
                                fontSize: screenSize.width * heartEffectSize,
                                color: Colors.pink,
                              ),
                            ),
                          ),
                        
                        // Jugador
                        Positioned(
                          left: screenSize.width * (playerX - playerWidth/2),
                          top: screenSize.height * (playerY - playerHeight/2),
                          child: SizedBox(
                            width: screenSize.width * playerWidth,
                            height: screenSize.height * playerHeight,
                            child: Image.asset(
                              playerImage,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        
                        // Contadores de juego
                        _buildGameCounters(isSmallScreen),
                      ],
                      
                      // Notificación final (ganaste)
                      if (currentNotification == 3) 
                        _buildFinalNotification(isSmallScreen),
                      
                      // Notificación de derrota
                      if (currentNotification == 4) 
                        _buildGameOverNotification(isSmallScreen),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildConfetti() {
    return Stack(
      children: [
        // Confeti de explosión
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: -1.0,
            maxBlastForce: 20,
            minBlastForce: 10,
            emissionFrequency: 0.05,
            numberOfParticles: 25,
            gravity: 0.1,
            colors: const [
              Colors.pink, Colors.purple, Colors.red, 
              Colors.orange, Colors.yellow
            ],
          ),
        ),
        
        // Confeti en cascada
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _waterfallConfettiController,
            blastDirection: pi / 2,
            emissionFrequency: 0.03,
            minimumSize: const Size(10, 10),
            maximumSize: const Size(20, 20),
            numberOfParticles: 30,
            gravity: 0.3,
            colors: const [
              Colors.pinkAccent, Colors.purpleAccent, Colors.redAccent,
              Colors.orangeAccent, Colors.yellowAccent
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGameCounters(bool isSmallScreen) {
    return Stack(
      children: [
        // Contador de vidas
        Positioned(
          top: 20,
          left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.favorite, color: Colors.red, size: 20),
                const SizedBox(width: 4),
                Text(
                  'x$lives',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Puntuación
        Positioned(
          top: 20,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '⭐ $score/$cakesToWin',
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeNotification(bool isSmallScreen) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          width: isSmallScreen ? MediaQuery.of(context).size.width * 0.9 : MediaQuery.of(context).size.width * 0.85,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFff758c), Color(0xFFff7eb3)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '❤️ Bienvenida Especial ❤️',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isSmallScreen ? 24 : 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'DancingScript',
                  shadows: const [
                    Shadow(
                      blurRadius: 5,
                      color: Colors.pink,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'Hola mi pequeña Ivettecita,\n\n'
                'Este pequeño juego fue creado con todo mi cariño para ti.\n\n'
                'Eres mi mundo, mi razón de ser, y quiero que este día sea tan especial como tú lo eres para mí.\n\n'
                'Espero que disfrutes este pequeño detalle hecho con amor.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  color: Colors.white,
                  height: 1.5,
                  fontFamily: 'Pacifico',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _nextNotification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.pink,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 30 : 40,
                    vertical: isSmallScreen ? 12 : 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                  shadowColor: Colors.pink,
                ),
                child: Text(
                  'CONTINUAR',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ).animate().scale().fadeIn(),
      ),
    );
  }

  Widget _buildInstructionsNotification(bool isSmallScreen) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          width: isSmallScreen ? MediaQuery.of(context).size.width * 0.9 : MediaQuery.of(context).size.width * 0.85,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFa18cd1), Color(0xFFfbc2eb)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🎂 Cómo Jugar 🎁',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isSmallScreen ? 24 : 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'DancingScript',
                  shadows: const [
                    Shadow(
                      blurRadius: 5,
                      color: Colors.purple,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Text(
                '¡Atrapa los regalos para descubrir una sorpresa especial!\n\n'
                '1. Presiona al piplu y desliza tu dedo por la pantalla para moverlo\n'
                '2. Atrapa los regalos buenos (🎂🍰🎁)\n'
                '3. EVITA los objetos malos (💣☠️)\n'
                '4. Consigue ${cakesToWin} puntos para ganar\n\n'
                'Tienes 3 vidas. ¡Buena suerte mi amor!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  color: Colors.white,
                  height: 1.5,
                  fontFamily: 'Pacifico',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _nextNotification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.purple,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 30 : 40,
                    vertical: isSmallScreen ? 12 : 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                  shadowColor: Colors.purple,
                ),
                child: Text(
                  'COMENZAR JUEGO',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ).animate().scale().fadeIn(),
      ),
    );
  }

  Widget _buildFinalNotification(bool isSmallScreen) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          width: isSmallScreen ? MediaQuery.of(context).size.width * 0.9 : MediaQuery.of(context).size.width * 0.85,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFf6d365),
                Color(0xFFfda085),
                Color(0xFFff758c),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.deepOrange.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¡LO LOGRASTE! 🎉',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isSmallScreen ? 28 : 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'DancingScript',
                  shadows: const [
                    Shadow(
                      blurRadius: 5,
                      color: Colors.deepOrange,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'Feliz cumpleaños mi amor 😊\n\n'
                'Sabía que podrías hacerlo, eres increíblemente talentosa y especial.\n\n'
                'Este pequeño juego no es nada comparado con todo lo que significas para mí.\n\n'
                'Aquí tienes un regalo especial para ti:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  color: Colors.white,
                  height: 1.5,
                  fontFamily: 'Pacifico',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _launchURL,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFf6d365),
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 30 : 40,
                    vertical: isSmallScreen ? 12 : 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                  shadowColor: Colors.deepOrange,
                ),
                child: Text(
                  'VER REGALO ESPECIAL ❤️',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: _startGameplay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 30 : 40,
                    vertical: isSmallScreen ? 12 : 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: Colors.white, width: 2),
                  ),
                ),
                child: Text(
                  'JUGAR DE NUEVO',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ).animate().scale().fadeIn(),
      ),
    );
  }

  Widget _buildGameOverNotification(bool isSmallScreen) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          width: isSmallScreen ? MediaQuery.of(context).size.width * 0.9 : MediaQuery.of(context).size.width * 0.85,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¡Oh no! 💔',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isSmallScreen ? 28 : 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'DancingScript',
                  shadows: const [
                    Shadow(
                      blurRadius: 5,
                      color: Colors.red,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'No pasa nada mi amor, todos tenemos días así.\n\n'
                'Lo importante es que lo intentaste y te divertiste en el proceso.\n\n'
                'Recuerda que en la vida, como en este juego, siempre puedes volver a intentarlo.\n\n'
                '¿Quieres probar otra vez? ¡Esta vez seguro lo lograrás!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  color: Colors.white,
                  height: 1.5,
                  fontFamily: 'Pacifico',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => setState(() => currentNotification = 1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 30 : 40,
                    vertical: isSmallScreen ? 12 : 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                  shadowColor: Colors.red,
                ),
                child: Text(
                  'REINTENTAR',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () => setState(() => currentNotification = 0),
                child: Text(
                  'Volver al inicio',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: Colors.white,
                    fontFamily: 'Pacifico',
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ).animate().scale().fadeIn(),
      ),
    );
  }

  Color _getColorForItem(String type) {
    switch (type) {
      case '🎂': return Colors.pink;
      case '🍰': return Colors.orange;
      case '🎁': return Colors.red;
      case '🎈': return Colors.blue;
      case '🌸': return Colors.purple;
      case '💝': return Colors.red;
      case '✨': return Colors.yellow;
      default: return Colors.green;
    }
  }
}

class FallingItem {
  double x;
  double y = 0;
  double size;
  double speed;
  bool isGood;
  String type;
  double rotation;

  FallingItem({
    required this.x,
    required this.size,
    required this.speed,
    required this.isGood,
    required this.type,
    required this.rotation,
  });
}