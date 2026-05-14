import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/line_data.dart';

class HexagramLinePainter extends CustomPainter {
  final List<LineData> lines;
  final double animationProgress;
  final bool showChangingMarks;

  HexagramLinePainter({
    required this.lines,
    this.animationProgress = 1.0,
    this.showChangingMarks = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (lines.isEmpty) return;

    final lineSpacing = size.height / (lines.length + 1);
    final maxLineWidth = size.width * 0.75;
    final startX = (size.width - maxLineWidth) / 2;

    for (int i = 0; i < lines.length; i++) {
      final y = size.height - (i + 1) * lineSpacing;
      _drawBrushLine(
        canvas,
        y: y,
        startX: startX,
        endX: startX + maxLineWidth,
        lineData: lines[i],
        progress: animationProgress,
      );
    }
  }

  void _drawBrushLine(
    Canvas canvas, {
    required double y,
    required double startX,
    required double endX,
    required LineData lineData,
    required double progress,
  }) {
    final paint = Paint()
      ..color = AppColors.inkBlack
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final path = Path();

    if (lineData.nature == LineNature.yang) {
      // 阳爻：一条连续的波浪线
      path.moveTo(startX, y);
      _addWavyLine(path, startX, y, endX, y);
    } else {
      // 阴爻：两段短线，中间留空
      final gap = 24.0;
      final halfWidth = (endX - startX - gap) / 2;
      path.moveTo(startX, y);
      _addWavyLine(path, startX, y, startX + halfWidth, y);
      path.moveTo(startX + halfWidth + gap, y);
      _addWavyLine(path, startX + halfWidth + gap, y, endX, y);
    }

    // 动画进度裁剪
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      final extractPath = metric.extractPath(0, metric.length * progress);
      canvas.drawPath(extractPath, paint);
    }

    // 动爻标记
    if (showChangingMarks && lineData.isChanging && progress > 0.9) {
      final markPaint = Paint()
        ..color = AppColors.cinnabarRed
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;
      final centerX = (startX + endX) / 2;

      if (lineData.type == LineType.oldYang) {
        // 老阳: 朱砂圈
        final markAlpha = ((progress - 0.9) / 0.1).clamp(0.0, 1.0);
        markPaint.color = AppColors.cinnabarRed.withValues(alpha: markAlpha);
        canvas.drawCircle(Offset(centerX, y), 6.0, markPaint);
        final innerPaint = Paint()
          ..color = AppColors.antiquePaper
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(centerX, y), 3.0, innerPaint);
      } else if (lineData.type == LineType.oldYin) {
        // 老阴: 朱砂叉
        final markAlpha = ((progress - 0.9) / 0.1).clamp(0.0, 1.0);
        markPaint.color = AppColors.cinnabarRed.withValues(alpha: markAlpha);
        markPaint.style = PaintingStyle.stroke;
        markPaint.strokeWidth = 2.5;
        final crossPath = Path();
        crossPath.moveTo(centerX - 4, y - 4);
        crossPath.lineTo(centerX + 4, y + 4);
        crossPath.moveTo(centerX + 4, y - 4);
        crossPath.lineTo(centerX - 4, y + 4);
        canvas.drawPath(crossPath, markPaint);
      }
    }
  }

  void _addWavyLine(Path path, double x1, double y1, double x2, double y2) {
    final dx = (x2 - x1) / 6;
    final random = Random(42); // 固定种子保证一致外观
    for (int i = 0; i < 6; i++) {
      final cx = x1 + dx * i + dx / 2;
      final waveAmp = (random.nextDouble() - 0.5) * 1.2;
      final cy = y1 + waveAmp;
      final ex = x1 + dx * (i + 1);
      path.quadraticBezierTo(cx, cy, ex, y2);
    }
  }

  @override
  bool shouldRepaint(covariant HexagramLinePainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.lines != lines ||
        oldDelegate.showChangingMarks != showChangingMarks;
  }
}
