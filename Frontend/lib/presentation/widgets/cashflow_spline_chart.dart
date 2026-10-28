import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';

class CashflowSplineChart extends StatefulWidget {
  final List<double> values;
  final List<String> labels;
  final String subtitleDate;
  final bool isMasked;

  const CashflowSplineChart({
    super.key,
    required this.values,
    required this.labels,
    required this.subtitleDate,
    this.isMasked = false,
  });

  @override
  State<CashflowSplineChart> createState() => _CashflowSplineChartState();
}

class _CashflowSplineChartState extends State<CashflowSplineChart> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex =
        widget.values.length > 4 ? 4 : (widget.values.length - 1).clamp(0, 10);
  }

  @override
  void didUpdateWidget(covariant CashflowSplineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedIndex >= widget.values.length) {
      _selectedIndex = (widget.values.length - 1).clamp(0, 10);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final p = context.palette;
        final currency = ref.watch(currencyFormatterProvider);

    final pts = widget.values.isEmpty
        ? [18400.0, 29200.0, 22800.0, 39100.0, 48840.24, 44200.0]
        : widget.values;
    final lbls = widget.labels.length == pts.length
        ? widget.labels
        : const ['Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov'];

    final minVal = pts.reduce((a, b) => a < b ? a : b);
    final maxVal = pts.reduce((a, b) => a > b ? a : b);
    final span = (maxVal - minVal).abs() < 1 ? 1000.0 : (maxVal - minVal);
    final chartMinY = (minVal - span * 0.35).clamp(0.0, double.infinity);
    final chartMaxY = maxVal + span * 0.42;

    final activeIdx = _selectedIndex.clamp(0, pts.length - 1);
    final selectedAmount =
        widget.isMasked ? currency.masked() : currency.format(pts[activeIdx]);

    final spots = List.generate(
      pts.length,
      (i) => FlSpot(i.toDouble(), pts[i]),
    );

    final lineBarData = LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.36,
      color: p.primaryBrand,
      barWidth: 2.5,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        checkToShowDot: (spot, barData) => spot.x.toInt() == activeIdx,
        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
          radius: 5.5,
          color: p.cardSurface,
          strokeWidth: 3.2,
          strokeColor: p.primaryBrand,
        ),
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            p.primaryBrand.withOpacity(p.isDark ? 0.28 : 0.16),
            p.primaryBrand.withOpacity(p.isDark ? 0.04 : 0.02),
          ],
        ),
      ),
    );

    return SizedBox(
      height: 225,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Subtle vertical stripe lines behind the curve matching Novbank's chart texture
          Positioned.fill(
            bottom: 32,
            child: CustomPaint(
              painter: _VerticalStripeTexturePainter(
                color: p.isDark
                    ? Colors.white.withOpacity(0.03)
                    : const Color(0xFF0A5C6B).withOpacity(0.045),
              ),
            ),
          ),
          LineChart(
            LineChartData(
              minX: 0,
              maxX: (pts.length - 1).toDouble(),
              minY: chartMinY,
              maxY: chartMaxY,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              showingTooltipIndicators: [
                ShowingTooltipIndicators([
                  LineBarSpot(lineBarData, 0, spots[activeIdx]),
                ]),
              ],
              lineTouchData: LineTouchData(
                enabled: true,
                handleBuiltInTouches: false,
                touchCallback:
                    (FlTouchEvent event, LineTouchResponse? response) {
                  if (response != null &&
                      response.lineBarSpots != null &&
                      response.lineBarSpots!.isNotEmpty) {
                    final idx = response.lineBarSpots!.first.spotIndex;
                    if (idx != _selectedIndex) {
                      setState(() => _selectedIndex = idx);
                    }
                  }
                },
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => p.tooltipBg,
                  tooltipRoundedRadius: 14,
                  tooltipPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  tooltipMargin: 12,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      return LineTooltipItem(
                        '$selectedAmount\n',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                        children: [
                          TextSpan(
                            text: '${lbls[activeIdx]} • ${widget.subtitleDate}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.78),
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      );
                    }).toList();
                  },
                ),
              ),
              titlesData: FlTitlesData(
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final idx = value.round();
                      if (idx < 0 || idx >= lbls.length)
                        return const SizedBox.shrink();
                      final isSelected = idx == activeIdx;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedIndex = idx),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            lbls[idx],
                            style: TextStyle(
                              color: isSelected ? p.textPrimary : p.textMuted,
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: [lineBarData],
            ),
          ),
        ],
      ),
    );
      },
    );
  }
}

class _VerticalStripeTexturePainter extends CustomPainter {
  final Color color;

  _VerticalStripeTexturePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    const step = 6.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(
          Offset(x, size.height * 0.25), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _VerticalStripeTexturePainter oldDelegate) =>
      oldDelegate.color != color;
}
