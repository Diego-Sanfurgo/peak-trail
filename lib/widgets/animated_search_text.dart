import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class AnimatedSearchText extends StatefulWidget {
  const AnimatedSearchText({super.key});

  @override
  State<AnimatedSearchText> createState() => _AnimatedSearchTextState();
}

class _AnimatedSearchTextState extends State<AnimatedSearchText>
    with SingleTickerProviderStateMixin {
  static const List<String> searchTerms = [
    'montañas',
    'lagos',
    'portezuelos',
    'cascadas',
    'experiencias',
    'lagunas',
    'volcanes',
  ];
  final textStyle = TextStyle(color: Colors.grey[600], fontSize: 16);

  late AnimationController controller;
  late Animation<Offset> slideOutAnimation;
  late Animation<Offset> slideInAnimation;
  late Animation<double> fadeOutAnimation;
  late Animation<double> fadeInAnimation;

  Timer? _timer;
  int currentIndex = Random().nextInt(searchTerms.length);
  int nextIndex = Random().nextInt(searchTerms.length);
  bool isAnimating = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Animación de salida: de centro hacia arriba
    slideOutAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1),
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    // Animación de entrada: de abajo hacia centro
    slideInAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    // Fade animations
    fadeOutAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeIn));
    fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          currentIndex = nextIndex;
          isAnimating = false;
        });
        controller.reset();
      }
    });

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _animateToNext();
    });
  }

  void _animateToNext() {
    if (isAnimating) return;
    setState(() {
      isAnimating = true;
      nextIndex = (currentIndex + 1) % searchTerms.length;
    });
    controller.forward();
  }

  @override
  void dispose() {
    _timer?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Buscar ', style: textStyle),
        ClipRect(
          child: SizedBox(
            width: 100,
            height: 20,
            child: Stack(
              children: [
                // Texto actual (sale hacia arriba)
                SlideTransition(
                  position: isAnimating
                      ? slideOutAnimation
                      : const AlwaysStoppedAnimation(Offset.zero),
                  child: FadeTransition(
                    opacity: isAnimating
                        ? fadeOutAnimation
                        : const AlwaysStoppedAnimation(1.0),
                    child: Text(searchTerms[currentIndex], style: textStyle),
                  ),
                ),
                // Texto nuevo (entra desde abajo)
                if (isAnimating)
                  SlideTransition(
                    position: slideInAnimation,
                    child: FadeTransition(
                      opacity: fadeInAnimation,
                      child: Text(searchTerms[nextIndex], style: textStyle),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
