import 'package:action_slider/action_slider.dart';
import 'package:flutter/material.dart';

enum TrackingState { idle, active, paused }

class AnimatedActionBtn extends StatefulWidget {
  const AnimatedActionBtn({super.key});

  @override
  State<AnimatedActionBtn> createState() => _AnimatedActionBtnState();
}

class _AnimatedActionBtnState extends State<AnimatedActionBtn> {
  TrackingState _currentState = TrackingState.idle;

  void _onStartPressed() {
    setState(() {
      _currentState = TrackingState.active;
    });
  }

  void _onActiveButtonPressed() {
    setState(() {
      _currentState = TrackingState.paused;
    });
  }

  void _onResumePressed() {
    setState(() {
      _currentState = TrackingState.active;
    });
  }

  void _onFinishPressed() {
    setState(() {
      _currentState = TrackingState.idle;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget loadingIcon = CircularProgressIndicator(
      color: Colors.white,
      padding: EdgeInsets.all(8),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedSwitcher(
          duration: Duration(milliseconds: 200),
          child: _currentState == TrackingState.idle
              ? ActionSlider.standard(
                  key: ValueKey('standard'),
                  height: constraints.maxHeight,
                  sliderBehavior: SliderBehavior.stretch,
                  successIcon: Icon(Icons.flag_outlined, color: Colors.white),
                  loadingIcon: loadingIcon,
                  failureIcon: Icon(Icons.error, color: Colors.red),
                  icon: Icon(Icons.chevron_right_outlined, color: Colors.white),
                  customOuterBackgroundBuilder: (context, sliderState, child) {
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.green.withValues(alpha: 0.1),
                        border: Border.all(color: Colors.black),
                      ),
                    );
                  },
                  action: (controller) async {
                    controller.loading();
                    await Future.delayed(const Duration(seconds: 2));
                    controller.success();
                    await Future.delayed(const Duration(seconds: 2));

                    _onStartPressed();

                    controller.reset();
                  },
                  child: Text("Deliza para comenzar"),
                )
              : _currentState == TrackingState.active
              ? OutlinedButton.icon(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                      Colors.green.withValues(alpha: 0.1),
                    ),
                    foregroundColor: WidgetStatePropertyAll(Colors.black),
                    fixedSize: WidgetStatePropertyAll(
                      Size.fromHeight(constraints.maxHeight),
                    ),
                  ),
                  label: Text("Pausar"),
                  icon: Icon(Icons.pause),
                  onPressed: _onActiveButtonPressed,
                )
              : ActionSlider.dual(
                  key: ValueKey('dual'),
                  height: constraints.maxHeight,
                  loadingIcon: loadingIcon,
                  sliderBehavior: SliderBehavior.stretch,
                  icon: Icon(Icons.sync_alt_outlined, color: Colors.white),
                  customOuterBackgroundBuilder: (context, sliderState, child) {
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.green.withValues(alpha: 0.1),
                        border: Border.all(color: Colors.black),
                      ),
                    );
                  },
                  startChild: Text("Terminar"),
                  startAction: (controller) async {
                    controller.loading();
                    await Future.delayed(const Duration(seconds: 2));
                    controller.success();
                    _onFinishPressed();
                    controller.reset();
                  },
                  endChild: Text("Reanudar"),
                  endAction: (controller) async {
                    controller.loading();
                    await Future.delayed(const Duration(seconds: 2));
                    controller.success();
                    _onResumePressed();
                    controller.reset();
                  },
                ),
        );
      },
    );
  }
}
