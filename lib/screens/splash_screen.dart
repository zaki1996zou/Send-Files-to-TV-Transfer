import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/ads_actions.dart';
import '../util/global.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _startLaunchFlow();
  }

  Future<void> _startLaunchFlow() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    await AdsActions.showAppOpenOnLaunch(onFinished: _navigateToHome);
  }

  void _navigateToHome() {
    if (!mounted) return;
    pastSplash = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Image.asset(
        'assets/images/splash.png',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}

class SplashArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final arrowWidth = size.width * 0.35;
    final arrowHeight = size.height * 0.22;

    final topArrowPaint = Paint()..color = AppColors.splashNavy;
    final bottomArrowPaint = Paint()..color = AppColors.splashCyan;

    _drawArrow(
      canvas,
      Offset(size.width / 2, centerY - arrowHeight * 0.3),
      arrowWidth,
      arrowHeight,
      topArrowPaint,
      pointingUp: true,
    );

    _drawArrow(
      canvas,
      Offset(size.width / 2, centerY + arrowHeight * 0.3),
      arrowWidth,
      arrowHeight,
      bottomArrowPaint,
      pointingUp: false,
    );
  }

  void _drawArrow(
    Canvas canvas,
    Offset center,
    double width,
    double height,
    Paint paint, {
    required bool pointingUp,
  }) {
    final path = Path();
    final direction = pointingUp ? -1.0 : 1.0;

    final tip = Offset(center.dx + width * 0.35 * direction, center.dy - height * 0.5 * direction);
    final tailLeft = Offset(center.dx - width * 0.4, center.dy + height * 0.3 * direction);
    final tailRight = Offset(center.dx + width * 0.1, center.dy + height * 0.3 * direction);

    path.moveTo(tip.dx, tip.dy);
    path.lineTo(tailLeft.dx, tailLeft.dy);
    path.lineTo(tailLeft.dx + width * 0.15, tailLeft.dy - height * 0.08 * direction);
    path.lineTo(tailRight.dx + width * 0.15, tailRight.dy - height * 0.08 * direction);
    path.lineTo(tailRight.dx, tailRight.dy);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
