import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controllers/AkuntansiController.dart';

// ==========================================================
// 1. GRAFIK KEUNTUNGAN & KERUGIAN HARIAN (BAR CHART)
// ==========================================================
class DailyProfitBarChart extends StatelessWidget {
  final AkuntansiController controller;
  const DailyProfitBarChart({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Kita reverse agar tanggal terlama ada di kiri, terbaru di kanan
      var logs = controller.dailyLogs.reversed.toList();

      if (logs.isEmpty) {
        return const EmptyStateWidget(text: "Belum ada transaksi harian");
      }

      double maxY = 0;
      double minY = 0;

      for (var log in logs) {
        double laba = (log['laba'] as num).toDouble();
        if (laba > maxY) maxY = laba;
        if (laba < minY) minY = laba;
      }

      maxY = maxY == 0 ? 50000.0 : maxY * 1.2;
      minY = minY == 0 ? 0.0 : minY * 1.2;

      return Container(
        height: 300,
        padding: const EdgeInsets.fromLTRB(16, 24, 24, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Statistik Keuntungan Harian",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  minY: minY,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey.shade900,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String dateStr = logs[group.x.toInt()]['date'];
                        String formattedDate = DateFormat(
                          'dd MMM yyyy',
                          'id_ID',
                        ).format(DateTime.parse(dateStr));
                        bool isProfit = rod.toY >= 0;

                        return BarTooltipItem(
                          '$formattedDate\n',
                          const TextStyle(color: Colors.white, fontSize: 10),
                          children: [
                            TextSpan(
                              text: controller.formatRupiah(rod.toY.toInt()),
                              style: TextStyle(
                                color: isProfit
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index < 0 || index >= logs.length)
                            return const SizedBox();

                          // Sembunyikan beberapa label jika datanya terlalu banyak agar tidak bertumpuk
                          if (logs.length > 7 && index % 2 != 0)
                            return const SizedBox();

                          DateTime date = DateTime.parse(logs[index]['date']);
                          String text = DateFormat('d MMM').format(date);

                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              text,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 45,
                        getTitlesWidget: (value, meta) {
                          if (value == 0)
                            return const Text(
                              '0',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            );
                          String text = value.abs() >= 1000000
                              ? '${(value / 1000000).toStringAsFixed(1)}jt'
                              : '${(value / 1000).toStringAsFixed(0)}rb';
                          return Text(
                            text,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (v) => FlLine(
                      color: v == 0 ? Colors.black45 : Colors.grey.shade200,
                      strokeWidth: v == 0 ? 1.5 : 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: logs.asMap().entries.map((entry) {
                    int idx = entry.key;
                    double laba = (entry.value['laba'] as num).toDouble();
                    return BarChartGroupData(
                      x: idx,
                      barRods: [
                        BarChartRodData(
                          toY: laba,
                          color: laba >= 0 ? Colors.green : Colors.red,
                          width: logs.length > 15 ? 12 : 20,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(laba >= 0 ? 4 : 0),
                            bottom: Radius.circular(laba < 0 ? 4 : 0),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ==========================================================
// 2. GRAFIK TREN PENJUALAN / OMSET (LINE CHART)
// ==========================================================
class DailyOmsetLineChart extends StatelessWidget {
  final AkuntansiController controller;
  const DailyOmsetLineChart({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var logs = controller.dailyLogs.reversed.toList();

      if (logs.isEmpty) {
        return const EmptyStateWidget(text: "Belum ada data penjualan harian");
      }

      List<FlSpot> spots = [];
      double maxY = 0;

      for (int i = 0; i < logs.length; i++) {
        double omset = (logs[i]['omset'] as num).toDouble();
        if (omset > maxY) maxY = omset;
        spots.add(FlSpot(i.toDouble(), omset));
      }

      maxY = maxY == 0 ? 50000.0 : maxY * 1.2;

      return Container(
        height: 300,
        padding: const EdgeInsets.fromLTRB(16, 24, 24, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tren Omset Penjualan",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (v) =>
                        FlLine(color: Colors.grey.shade100, strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index < 0 || index >= logs.length)
                            return const SizedBox();
                          if (logs.length > 7 && index % 2 != 0)
                            return const SizedBox();

                          DateTime dt = DateTime.parse(logs[index]['date']);
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat('d MMM').format(dt),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value == 0)
                            return const Text(
                              '0',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            );
                          String text = value >= 1000000
                              ? '${(value / 1000000).toStringAsFixed(1)}jt'
                              : '${(value / 1000).toStringAsFixed(0)}rb';
                          return Text(
                            text,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (logs.length - 1).toDouble() < 0
                      ? 0
                      : (logs.length - 1).toDouble(),
                  minY: 0,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blueAccent,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (s, p, b, i) => FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: Colors.blueAccent,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blueAccent.withOpacity(0.15),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey.shade900,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((barSpot) {
                          int index = barSpot.x.toInt();
                          String date = DateFormat(
                            'dd MMM yyyy',
                            'id_ID',
                          ).format(DateTime.parse(logs[index]['date']));
                          return LineTooltipItem(
                            '$date\n',
                            const TextStyle(color: Colors.white, fontSize: 10),
                            children: [
                              TextSpan(
                                text: controller.formatRupiah(
                                  barSpot.y.toInt(),
                                ),
                                style: const TextStyle(
                                  color: Colors.yellow,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ==========================================================
// 3. GRAFIK RASIO MARGIN (PIE CHART)
// ==========================================================
class MarginPieChart extends StatelessWidget {
  final AkuntansiController controller;
  const MarginPieChart({super.key, required this.controller});

  Widget _chartLegend(Color color, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      int hpp = controller.totalHPP.value > 0 ? controller.totalHPP.value : 0;
      int labaBersih = controller.labaBersih.value > 0
          ? controller.labaBersih.value
          : 0;
      int totalOmset = hpp + labaBersih;

      if (totalOmset <= 0) {
        return const EmptyStateWidget(text: "Belum ada data penjualan");
      }

      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Rasio Margin & Modal Bahan",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                SizedBox(
                  height: 130,
                  width: 130,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 35,
                      sections: [
                        if (labaBersih > 0)
                          _buildSection(labaBersih, totalOmset, Colors.green),
                        if (hpp > 0)
                          _buildSection(hpp, totalOmset, Colors.orange),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _chartLegend(
                        Colors.green,
                        "Laba Bersih",
                        controller.formatRupiah(labaBersih),
                      ),
                      _chartLegend(
                        Colors.orange,
                        "Modal (HPP)",
                        controller.formatRupiah(hpp),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  PieChartSectionData _buildSection(int value, int total, Color color) {
    double percentage = (value / total) * 100;
    return PieChartSectionData(
      color: color,
      value: value.toDouble(),
      title: percentage > 5 ? '${percentage.toStringAsFixed(0)}%' : '',
      radius: 40,
      titleStyle: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}

// ==========================================================
// WIDGET KOSONG
// ==========================================================
class EmptyStateWidget extends StatelessWidget {
  final String text;
  const EmptyStateWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
