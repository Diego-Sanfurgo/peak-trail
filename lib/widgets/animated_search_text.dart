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
  static const List<String> _searchTerms = [
    'montañas',
    'lagos',
    'portezuelos',
    'cascadas',
    'experiencias',
    'lagunas',
    'volcanes',
  ];
  final textStyle = TextStyle(color: Colors.grey[600], fontSize: 16);

  late AnimationController _controller;
  late Animation<Offset> _slideOutAnimation;
  late Animation<Offset> _slideInAnimation;
  late Animation<double> _fadeOutAnimation;
  late Animation<double> _fadeInAnimation;

  Timer? _timer;
  int _currentIndex = Random().nextInt(_searchTerms.length);
  int _nextIndex = Random().nextInt(_searchTerms.length);
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Animación de salida: de centro hacia arriba
    _slideOutAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Animación de entrada: de abajo hacia centro
    _slideInAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Fade animations
    _fadeOutAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentIndex = _nextIndex;
          _isAnimating = false;
        });
        _controller.reset();
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
    if (_isAnimating) return;
    setState(() {
      _isAnimating = true;
      _nextIndex = (_currentIndex + 1) % _searchTerms.length;
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
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
                  position: _isAnimating
                      ? _slideOutAnimation
                      : const AlwaysStoppedAnimation(Offset.zero),
                  child: FadeTransition(
                    opacity: _isAnimating
                        ? _fadeOutAnimation
                        : const AlwaysStoppedAnimation(1.0),
                    child: Text(_searchTerms[_currentIndex], style: textStyle),
                  ),
                ),
                // Texto nuevo (entra desde abajo)
                if (_isAnimating)
                  SlideTransition(
                    position: _slideInAnimation,
                    child: FadeTransition(
                      opacity: _fadeInAnimation,
                      child: Text(_searchTerms[_nextIndex], style: textStyle),
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
