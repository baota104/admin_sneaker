import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dashboard_provider.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetch();
  }

  void fetch() {
    Provider.of<DashboardProvider>(context, listen: false)
        .fetchDataByRange(startDate, endDate);
  }

  Future<void> _selectDate({required bool isStart}) async {
    DateTime initial = isStart ? startDate : endDate;
    DateTime first = DateTime(2022);
    DateTime last = DateTime.now();

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
          if (startDate.isAfter(endDate)) endDate = startDate;
        } else {
          endDate = picked;
          if (endDate.isBefore(startDate)) startDate = endDate;
        }
        fetch();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Revenue Statistics")),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          final total = provider.totalRevenue;
          final brandData = provider.brandRevenue;
          final totalFormatted = NumberFormat("#,##0").format(total);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text("Start Date: ${DateFormat.yMMMd().format(startDate)}"),
                      ElevatedButton(
                        onPressed: () => _selectDate(isStart: true),
                        child: Text("Select Start Date"),
                      ),
                    ]),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text("End Date: ${DateFormat.yMMMd().format(endDate)}"),
                      ElevatedButton(
                        onPressed: () => _selectDate(isStart: false),
                        child: Text("Select End Date"),
                      ),
                    ]),
                  ],
                ),
                SizedBox(height: 20),
                Text("Total Revenue: $totalFormatted Dollars",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Text("Revenue by Brand", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ...brandData.entries.map((e) {
                  final value = NumberFormat("#,##0").format(e.value);
                  return ListTile(title: Text(e.key), trailing: Text("$value Dollars"));
                }),
                SizedBox(height: 30),
                if (brandData.isNotEmpty) ...[
                  Text("Pie Chart", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: brandData.entries.map((entry) {
                          final percent = (entry.value / total * 100).toStringAsFixed(1);
                          return PieChartSectionData(
                            value: entry.value,
                            title: '${entry.key}\n$percent%',
                            radius: 50,
                            titleStyle: TextStyle(fontSize: 12, color: Colors.white),
                            color: _brandColor(entry.key),
                          );
                        }).toList(),
                        sectionsSpace: 4,
                        centerSpaceRadius: 30,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Text("Bar Chart", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        barGroups: brandData.entries.mapIndexed((index, entry) {
                          return BarChartGroupData(x: index, barRods: [
                            BarChartRodData(toY: entry.value, color: _brandColor(entry.key), width: 18)
                          ]);
                        }).toList(),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final keys = brandData.keys.toList();
                                if (value.toInt() < keys.length) {
                                  return Text(keys[value.toInt()], style: TextStyle(fontSize: 10));
                                }
                                return Text("");
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ]
              ],
            ),
          );
        },
      ),
    );
  }

  Color _brandColor(String brand) {
    switch (brand) {
      case 'Jordan': return Colors.redAccent;
      case 'Adidas': return Colors.blueAccent;
      case 'Nike': return Colors.black87;
      case 'Puma': return Colors.green;
      case 'Converse': return Colors.orange;
      case 'New Balance': return Colors.deepPurple;
      default: return Colors.grey;
    }
  }
}
