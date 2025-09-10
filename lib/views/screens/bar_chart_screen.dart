import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:jnk_app/consts/app_constants.dart';

class BarChartScreen extends StatelessWidget {
  final String type;
  final List<DataModel> data;
  const BarChartScreen({super.key, required this.type, required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                buildLegendItem(
                  color: AppConstants.accentColor,
                  label: 'Planned - ${data[0].value.toInt()}',
                ),
                SizedBox(width: 10),
                buildLegendItem(
                  color: AppConstants.primaryColor,
                  label: 'Acheived - ${data[1].value.toInt()}',
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              height: 300.0,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceEvenly,
                  maxY: data
                      .map((e) => e.value)
                      .reduce((a, b) => a > b ? a : b),
                  // barTouchData: BarTouchData(
                  //   touchTooltipData: BarTouchTooltipData(
                  //     tooltipBgColor: Colors.blueGrey,
                  //   ),
                  // ),
                  borderData: FlBorderData(
                    border: Border(
                      bottom: BorderSide(
                        color: AppConstants.secondaryColor,
                        width: 1,
                      ),
                      left: BorderSide(
                        color: AppConstants.secondaryColor,
                        width: 1,
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    horizontalInterval: type == 'daily' ? 10 : 200,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppConstants.secondaryColor,
                        strokeWidth: 0.3,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            data[value.toInt()].key,
                            style: TextStyle(
                              color: AppConstants.secondaryColor,
                              fontSize: 14,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: type == 'daily' ? 10 : 200,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: AppConstants.secondaryColor,
                              fontSize: 14,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(),
                    rightTitles: AxisTitles(),
                  ),
                  barGroups: data
                      .map(
                        (e) => BarChartGroupData(
                          x: data.indexOf(e),
                          barRods: [
                            BarChartRodData(
                              toY: e.value,
                              width: 35,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(5),
                              ),
                              color: e.key == 'planned'
                                  ? AppConstants.accentColor
                                  : AppConstants.primaryColor,
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
          SizedBox(height: 500),
        ],
      ),
    );
  }
}

Widget buildLegendItem({required Color color, required String label}) {
  return Row(
    children: [
      Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      SizedBox(width: 5),
      Text(label, style: TextStyle(fontSize: 16)),
    ],
  );
}

class DataModel {
  final String key;
  final double value;

  DataModel({required this.key, required this.value});
}
