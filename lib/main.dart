// import 'package:flutter/material.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         body: SafeArea(
//           child: WaterAnimation(),
//         ),
//       ),
//     );
//   }
// }

// class WaterAnimation extends StatefulWidget {
//   @override
//   _WaterAnimationState createState() => _WaterAnimationState();
// }

// class _WaterAnimationState extends State<WaterAnimation>
//     with TickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 3),
//     );
//     _animation = Tween<double>(
//       begin: 0,
//       end: 1,
//     ).animate(_controller)
//       ..addListener(() {
//         setState(() {});
//       });
//     _controller.repeat(reverse: true);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: CustomPaint(
//         size: Size(200, 200),
//         painter: WaterPainter(_animation.value),
//       ),
//     );
//   }
// }

// class WaterPainter extends CustomPainter {
//   final double animationValue;

//   WaterPainter(this.animationValue);

//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = Paint()
//       ..color = Colors.blue.withOpacity(0.5)
//       ..style = PaintingStyle.fill;

//     Path path = Path()
//       ..moveTo(0, size.height)
//       ..lineTo(size.width, size.height)
//       ..lineTo(size.width, size.height * (1 - animationValue))
//       ..quadraticBezierTo(
//           size.width / 2, size.height * (1 - 2 * animationValue), 0, size.height * (1 - animationValue))
//       ..close();

//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return true;
//   }
// }

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Water Progress Loading Animation'),
        ),
        body: Center(
          child: WaterWavesProgressAnimation(),
        ),
      ),
    );
  }
}

class WaterWavesProgressAnimation extends StatefulWidget {
  @override
  _WaterWavesProgressAnimationState createState() =>
      _WaterWavesProgressAnimationState();
}

class _WaterWavesProgressAnimationState
    extends State<WaterWavesProgressAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Timer _timer;
  int _animationDuration = 10; // Default animation duration in seconds

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _animationDuration),
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_controller);

    // Listen for animation status changes
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _timer.cancel(); // Stop the timer if animation completes
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel(); // Cancel timer to prevent memory leaks
    super.dispose();
  }

  // Start animation with the provided duration
  void startAnimation(int durationSeconds) {
    setState(() {
      _animationDuration = durationSeconds;
    });
    _controller.duration = Duration(seconds: durationSeconds);
    _controller.forward(from: 0);
  }

  // Stop animation
  void stopAnimation() {
    _controller.stop();
    _timer.cancel(); // Cancel timer if animation is stopped manually
  }

  // Handle input and update animation duration
  void handleInput(int inputSeconds) {
    if (_controller.isAnimating) {
      _controller.stop();
      _timer.cancel();
    }
    startAnimation(inputSeconds);
    _timer = Timer(Duration(seconds: inputSeconds), stopAnimation);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => handleInput(10), // Example: Start animation for 10 seconds
          child: Text('Start Animation (10 seconds)'),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: stopAnimation,
          child: Text('Stop Animation'),
        ),
        SizedBox(height: 20),
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(200, 200),
                  painter: WaterPainter(_animation.value),
                  child: SizedBox(
                    height: 200,
                    width: 200,
                  ),
                ),
                Text(
                  '${(_animation.value * 100).toInt()}%',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class WaterPainter extends CustomPainter {
  final double animationValue;

  WaterPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    double progress = size.height * animationValue;

    Path path = Path();
    path.moveTo(0, size.height);
    for (double i = 0; i < size.width; i++) {
      double y = sin((i / size.width * 4 * pi) + (animationValue * 2 * pi)) * 10;
      path.lineTo(i, size.height - progress - y);
    }
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

