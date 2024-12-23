import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health/health.dart';

class ChartPage extends StatefulWidget {
  final List<HealthDataPoint> healthDataList;

  const ChartPage({Key? key, required this.healthDataList}) : super(key: key);

  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  String _selectedChartType = 'Height';
  final List<String> chartTypes = ['Height', 'Weight', 'Heart Rate'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Data Charts'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _selectedChartType,
              items: chartTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedChartType = newValue!;
                });
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _buildChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    // Lọc dữ liệu dựa trên loại biểu đồ đã chọn
    List<Map<String, dynamic>> numericData = _prepareNumericData();

    // Tạo danh sách các điểm dữ liệu cho biểu đồ
    List<FlSpot> spots = [];
    for (int i = 0; i < numericData.length; i++) {
      var entry = numericData[i];
      double xValue = i.toDouble();
      double yValue = entry['value'];

      spots.add(FlSpot(xValue, yValue));
    }

    if (spots.isEmpty) {
      return const Center(child: Text('No data available for selected chart type.'));
    }

    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index < 0 || index >= numericData.length) return Container();
                DateTime date = numericData[index]['date'];
                String formattedDate = '${_addZero(date.month)}/${_addZero(date.day)}';
                return Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _getInterval(),
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 2,
            color: Colors.blue,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
        ],
        minX: 0,
        maxX: spots.length.toDouble() - 1,
        minY: _getMinY(spots),
        maxY: _getMaxY(spots),
      ),
    );
  }

  List<Map<String, dynamic>> _prepareNumericData() {
  List<Map<String, dynamic>> numericData = [];
  for (var data in widget.healthDataList) {
    if (_isRelevantType(data.type)) {
      var value = _getNumericValue(data.value);
      if (value != null) {
        numericData.add({'date': data.dateFrom, 'value': value.toDouble()}); // Chuyển thành double
      }
    }
  }
  return numericData;
}


  bool _isRelevantType(HealthDataType type) {
    switch (_selectedChartType) {
      case 'Height':
        return type == HealthDataType.HEIGHT;
      case 'Weight':
        return type == HealthDataType.WEIGHT;
      case 'Heart Rate':
        return type == HealthDataType.HEART_RATE;
      default:
        return false;
    }
  }

  double? _getNumericValue(HealthValue value) {
  if (value is NumericHealthValue) {
    return value.numericValue.toDouble(); // Chuyển thành double
  }
  return null;
}


  double _getInterval() {
    switch (_selectedChartType) {
      case 'Height':
        return 10;
      case 'Weight':
        return 5;
      case 'Heart Rate':
        return 20;
      default:
        return 10;
    }
  }

  double _getMinY(List<FlSpot> spots) {
    double minY = spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    return minY.isFinite ? (minY - _getInterval()) : 0;
  }

  double _getMaxY(List<FlSpot> spots) {
    double maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    return maxY.isFinite ? (maxY + _getInterval()) : 100;
  }

  String _addZero(int number) {
    return number < 10 ? '0$number' : '$number';
  }
}
