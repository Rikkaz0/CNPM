// lib/chart_page.dart
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
            // Dropdown để chọn loại biểu đồ
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
            // Biểu đồ
            Expanded(
              flex: 2,
              child: _buildChart(),
            ),
            const SizedBox(height: 20),
            // Danh sách dữ liệu
            Expanded(
              flex: 3,
              child: _buildDataList(),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm bổ trợ để thêm số 0 trước các số đơn vị
  String _addZero(int number) {
    return number < 10 ? '0$number' : '$number';
  }

  // Hàm để định dạng chỉ ngày và tháng
  String _formatDate(DateTime date) {
    String day = _addZero(date.day);
    String month = _addZero(date.month);
    return '$day/$month'; // Chỉ bao gồm ngày và tháng
  }

  // Hàm để định dạng ngày và giờ
  String _formatDateTime(DateTime date) {
    String day = _addZero(date.day);
    String month = _addZero(date.month);
    String year = date.year.toString();
    String hour = _addZero(date.hour);
    String minute = _addZero(date.minute);
    String second = _addZero(date.second);
    return '$day/$month/$year $hour:$minute:$second';
  }

  Widget _buildChart() {
    List<Map<String, dynamic>> numericData = _prepareNumericData();

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
                String formattedDate = _formatDate(date); // Định dạng ngày chỉ bao gồm ngày/tháng
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

  Widget _buildDataList() {
    List<Map<String, dynamic>> numericData = _prepareNumericData();

    return ListView.builder(
      itemCount: numericData.length,
      itemBuilder: (context, index) {
        var entry = numericData[index];
        DateTime date = entry['date'];
        double value = entry['value'];
        String formattedDateTime = _formatDateTime(date); // Định dạng ngày và giờ
        String displayValue = _selectedChartType == 'Height'
            ? '${value.toInt()} cm'
            : _selectedChartType == 'Weight'
                ? '${value.toInt()} kg'
                : '${value.toInt()} bpm';

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
          child: ListTile(
            leading: Icon(
              _selectedChartType == 'Height'
                  ? Icons.height
                  : _selectedChartType == 'Weight'
                      ? Icons.fitness_center
                      : Icons.favorite,
              color: Colors.blue,
            ),
            title: Text(formattedDateTime), // Hiển thị ngày và giờ
            trailing: Text(
              displayValue,
              style: TextStyle(
                color: _selectedChartType == 'Height'
                    ? Colors.green
                    : _selectedChartType == 'Weight'
                        ? Colors.orange
                        : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  // Hàm chuẩn bị dữ liệu numeric đã sắp xếp và chuyển đổi đơn vị
  List<Map<String, dynamic>> _prepareNumericData() {
    List<Map<String, dynamic>> numericData = [];

    for (var data in widget.healthDataList) {
      if (_isRelevantType(data.type)) {
        var value = _getNumericValue(data.value, data.type);
        if (value != null) {
          numericData.add({'date': data.dateFrom, 'value': value});
        }
      }
    }

    // Sắp xếp dữ liệu theo thời gian từ cũ nhất đến mới nhất
    numericData.sort((a, b) => a['date'].compareTo(b['date']));

    // Debug: In dữ liệu đã sắp xếp
    for (var entry in numericData) {
      debugPrint('Date: ${entry['date']}, Value: ${entry['value']}');
    }

    return numericData;
  }

  // Kiểm tra xem loại dữ liệu có phù hợp với biểu đồ hiện tại không
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

  // Trích xuất giá trị số từ HealthValue và chuyển đổi đơn vị nếu cần
  double? _getNumericValue(HealthValue value, HealthDataType type) {
    if (value is NumericHealthValue) {
      // Nếu loại dữ liệu là Height, chuyển từ meters sang centimeters
      if (type == HealthDataType.HEIGHT) {
        return value.numericValue * 100; // Đổi từ m -> cm
      }
      // Các loại dữ liệu khác: chuyển đổi sang double
      return value.numericValue.toDouble();
    }
    return null;
  }

  // Xác định khoảng cách giữa các điểm trên trục Y dựa trên loại biểu đồ
  double _getInterval() {
    switch (_selectedChartType) {
      case 'Height':
        return 10; // Centimeters
      case 'Weight':
        return 5; // Kilograms
      case 'Heart Rate':
        return 20; // Beats per minute
      default:
        return 10;
    }
  }

  // Tính giá trị Y nhỏ nhất cho biểu đồ
  double _getMinY(List<FlSpot> spots) {
    double minY = spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);

    // Nếu là Height và giá trị nhỏ hơn 0, đặt minY = 0
    if (_selectedChartType == 'Height' && minY < 0) {
      return 0;
    }

    return minY.isFinite ? (minY - _getInterval()) : 0;
  }

  // Tính giá trị Y lớn nhất cho biểu đồ
  double _getMaxY(List<FlSpot> spots) {
    double maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    return maxY.isFinite ? (maxY + _getInterval()) : 100;
  }
}
