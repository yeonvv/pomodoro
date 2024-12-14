import 'package:flutter/material.dart';

class DiagonalPainter extends CustomPainter {
  final Color surfaceColor;
  final bool isRest;

  DiagonalPainter({
    required this.surfaceColor,
    required this.isRest,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..style = PaintingStyle.fill;

    Path greenPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0) // 오른쪽 위
      ..lineTo(size.width, size.height * 1 / 4) // 오른쪽 2/3 지점
      ..lineTo(0, size.height * 1 / 4) // 왼쪽 1/3 지점
      ..close();
    paint.color = !isRest ? Colors.green : Colors.green.shade200;
    canvas.drawPath(greenPath, paint);

    Path redPath = Path()
      ..moveTo(0, size.height * 1 / 4)
      ..lineTo(size.width, size.height * 0.4 / 4)
      ..lineTo(size.width, size.height * 4 / 5)
      ..lineTo(0, size.height * 4 / 5)
      ..close();
    paint.color = !isRest ? surfaceColor : Colors.green;

    canvas.drawPath(redPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
