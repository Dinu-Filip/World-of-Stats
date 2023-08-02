import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DiscreteGraph extends StatelessWidget {
  final Map<String, dynamic> barData;
  final String lower;
  final String upper;
  const DiscreteGraph(
      {super.key,
      required this.barData,
      required this.lower,
      required this.upper});

  BarChartData generateBarData() {
    List<BarChartGroupData> bars = [];
    int? lowerX = 0;
    int? upperX = 0;
    if (int.tryParse(lower) == null) {
      lowerX = null;
      upperX = int.parse(upper);
    } else if (int.tryParse(upper) == null) {
      upperX = null;
      lowerX = int.parse(lower);
    } else {
      upperX = int.parse(upper);
      lowerX = int.parse(lower);
    }
    for (String x in barData.keys.toList()) {
      int xVal = int.parse(x);
      double p = double.parse(barData[x]!);
      if (lowerX == null) {
        if (xVal <= upperX!) {
          bars.add(BarChartGroupData(
              barRods: [BarChartRodData(fromY: 0, toY: p, color: Colors.red)],
              x: xVal));
        } else {
          bars.add(BarChartGroupData(
              barRods: [BarChartRodData(fromY: 0, toY: p)], x: xVal));
        }
      } else if (upperX == null) {
        if (lowerX <= xVal) {
          bars.add(BarChartGroupData(
              barRods: [BarChartRodData(fromY: 0, toY: p, color: Colors.red)],
              x: xVal));
        } else {
          bars.add(BarChartGroupData(
              barRods: [BarChartRodData(fromY: 0, toY: p)], x: xVal));
        }
      } else {
        if (lowerX <= xVal && xVal <= upperX) {
          bars.add(BarChartGroupData(
              barRods: [BarChartRodData(fromY: 0, toY: p, color: Colors.red)],
              x: xVal));
        } else {
          bars.add(BarChartGroupData(
              barRods: [BarChartRodData(fromY: 0, toY: p)], x: xVal));
        }
      }
    }

    return BarChartData(
      barGroups: bars,
      // titlesData: const FlTitlesData(
      //     topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      //     rightTitles:
      //         AxisTitles(sideTitles: SideTitles(showTitles: false)))
    );
  }

  @override
  Widget build(BuildContext context) {
    return BarChart(generateBarData());
  }
}

class ContinuousGraph extends StatelessWidget {
  final Map<String, dynamic> lineData;
  final String lower;
  final String upper;
  const ContinuousGraph(
      {super.key,
      required this.lineData,
      required this.lower,
      required this.upper});

  LineChartData generateLineData() {
    List<FlSpot> curvePoints = [];
    List<FlSpot> areaPoints = [];
    double? lowerX = 0;
    double? upperX = 0;
    if (double.tryParse(lower) == null) {
      upperX = double.parse(upper);
      lowerX = null;
    } else if (double.tryParse(upper) == null) {
      lowerX = double.parse(lower);
      upperX = null;
    } else {
      lowerX = double.parse(lower);
      upperX = double.parse(lower);
    }
    for (String x in lineData.keys.toList()) {
      double xVal = double.parse(x);
      double p = double.parse(lineData[x]!);
      if (lowerX == null) {
        if (xVal <= upperX!) {
          areaPoints.add(FlSpot(xVal, p));
        }
      } else if (upperX == null) {
        if (xVal >= lowerX) {
          areaPoints.add(FlSpot(xVal, p));
        }
      } else {
        if (lowerX <= xVal && xVal <= upperX) {
          areaPoints.add(FlSpot(xVal, p));
        }
      }
      curvePoints.add(FlSpot(xVal, p));
    }
    return LineChartData(
        lineBarsData: [
          LineChartBarData(
              spots: areaPoints,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true)),
          LineChartBarData(
              spots: curvePoints, dotData: const FlDotData(show: false))
        ],
        titlesData: const FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                AxisTitles(sideTitles: SideTitles(showTitles: false))));
  }

  @override
  Widget build(BuildContext context) {
    return LineChart(generateLineData());
  }
}
