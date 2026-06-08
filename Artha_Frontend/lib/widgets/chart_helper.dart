import 'package:flutter/material.dart';
import 'dart:math';

class ChartData {
  final double nominal;
  final Color color;
  ChartData(this.nominal, this.color);
}

class DynamicDoughnutPainter extends CustomPainter {
  final List<ChartData> dataList;
  DynamicDoughnutPainter({required this.dataList});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final Paint paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 26.0..strokeCap = StrokeCap.round;

    double total = dataList.fold(0, (sum, item) => sum + max(0.0, item.nominal));
    if (total <= 0) {
      paint.color = Colors.grey.shade300;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 0, 2 * pi, false, paint);
      return;
    }

    double startAngle = -pi / 2;
    for (var item in dataList) {
      if (item.nominal <= 0) continue;
      double sweepAngle = (item.nominal / total) * 2 * pi;
      paint.color = item.color;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle - 0.2, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}