import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import '../models/health_metric_model.dart';
import '../providers/health_metric_provider.dart';
import '../theme/app_theme.dart'; // Assuming you have this for colors

class HealthMetricScreen extends StatefulWidget {
  const HealthMetricScreen({super.key});

  @override
  State<HealthMetricScreen> createState() => _HealthMetricScreenState();
}

class _HealthMetricScreenState extends State<HealthMetricScreen> {
  bool showForm = false;
  bool showMeasurements = true;
  HealthMetric? editingMetric;
  final _formKey = GlobalKey<FormState>();

  final Map<String, TextEditingController> controllers = {};
  final measurementFields = [
    "chest",
    "waist",
    "hips",
    "neck",
    "biceps",
    "thighs",
    "calves"
  ];
  final topFields = ["weight", "height"];

  @override
  void dispose() {
    controllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  void initControllers(HealthMetric metric) {
    for (var f in topFields) {
      controllers[f] =
          TextEditingController(text: metric.toJson()[f].toString());
    }
    for (var f in measurementFields) {
      controllers[f] = TextEditingController(
          text: metric.bodyMeasurements.toJson()[f].toString());
    }
  }

  HealthMetric readMetricFromControllers({String? id}) {
    Map<String, double> body = {};
    for (var f in measurementFields) {
      body[f] = double.tryParse(controllers[f]?.text ?? '0') ?? 0;
    }
    double weight = double.tryParse(controllers['weight']?.text ?? '0') ?? 0;
    double height = double.tryParse(controllers['height']?.text ?? '0') ?? 0;
    double bmi = height > 0 ? weight / ((height / 100) * (height / 100)) : 0;

    return HealthMetric(
      id: id,
      weight: weight,
      height: height,
      bmi: bmi,
      date: DateTime.now(),
      bodyMeasurements: BodyMeasurements(
        chest: body['chest']!,
        waist: body['waist']!,
        hips: body['hips']!,
        neck: body['neck']!,
        biceps: body['biceps']!,
        thighs: body['thighs']!,
        calves: body['calves']!,
      ),
    );
  }

  Color _getBmiColor(double bmi) {
    if (bmi < 18.5) return Colors.yellow[400]!;
    if (bmi < 25) return Colors.green[500]!;
    return Colors.red[500]!;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HealthMetricProvider>(
      builder: (context, provider, _) {
        double bmi = 0;
        if (controllers['weight']?.text.isNotEmpty == true &&
            controllers['height']?.text.isNotEmpty == true) {
          final weight = double.tryParse(controllers['weight']!.text) ?? 0;
          final height = double.tryParse(controllers['height']!.text) ?? 0;
          bmi = height > 0 ? weight / ((height / 100) * (height / 100)) : 0;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Health Metrics'),
            backgroundColor: AppColors.beige, // From your theme
          ),
          body: provider.loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Health Metrics',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                showForm = !showForm;
                                editingMetric = null;
                                initControllers(HealthMetric(
                                  weight: 0,
                                  height: 0,
                                  bmi: 0,
                                  date: DateTime.now(),
                                  bodyMeasurements: BodyMeasurements(
                                    chest: 0,
                                    waist: 0,
                                    hips: 0,
                                    neck: 0,
                                    biceps: 0,
                                    thighs: 0,
                                    calves: 0,
                                  ),
                                ));
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blue900,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(showForm ? 'Close Form' : 'Add Metric +'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (showForm)
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  Row(
                                    children: topFields
                                        .map(
                                          (f) => Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8),
                                              child: TextFormField(
                                                controller: controllers[f],
                                                keyboardType:
                                                    TextInputType.numberWithOptions(
                                                        decimal: true),
                                                inputFormatters: [
                                                  FilteringTextInputFormatter.allow(
                                                      RegExp(r'^\d*\.?\d*$')),
                                                ],
                                                decoration: InputDecoration(
                                                  labelText: f[0].toUpperCase() +
                                                      f.substring(1),
                                                  border:
                                                      const OutlineInputBorder(),
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return '${f[0].toUpperCase()}${f.substring(1)} is required';
                                                  }
                                                  if (double.tryParse(value) ==
                                                      null) {
                                                    return 'Enter a valid number';
                                                  }
                                                  return null;
                                                },
                                                onChanged: (_) => setState(() {}),
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          enabled: false,
                                          decoration: InputDecoration(
                                            labelText: 'BMI (auto)',
                                            border: const OutlineInputBorder(),
                                            labelStyle: TextStyle(
                                              color: AppColors.primaryDark,
                                            ),
                                          ),
                                          controller: TextEditingController(
                                            text: bmi == 0
                                                ? '—'
                                                : bmi.toStringAsFixed(1),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: FractionallySizedBox(
                                      widthFactor: bmi == 0
                                          ? 0
                                          : (bmi * 4 / 100).clamp(0, 1),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: _getBmiColor(bmi),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        showMeasurements = !showMeasurements;
                                      });
                                    },
                                    child: Text(
                                      showMeasurements
                                          ? 'Hide Body Measurements'
                                          : 'Show Body Measurements',
                                      style:
                                          TextStyle(color: AppColors.skyBrand),
                                    ),
                                  ),
                                  if (showMeasurements)
                                    ...measurementFields.map(
                                      (f) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        child: TextFormField(
                                          controller: controllers[f],
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  decimal: true),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d*\.?\d*$')),
                                          ],
                                          decoration: InputDecoration(
                                            labelText: f[0].toUpperCase() +
                                                f.substring(1),
                                            border: const OutlineInputBorder(),
                                          ),
                                          validator: (value) {
                                            if (value != null &&
                                                value.isNotEmpty &&
                                                double.tryParse(value) == null) {
                                              return 'Enter a valid number';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () async {
                                          if (_formKey.currentState!.validate()) {
                                            final metric =
                                                readMetricFromControllers(
                                                    id: editingMetric?.id);
                                            await provider.saveMetric(metric);
                                            Fluttertoast.showToast(
                                              msg: editingMetric != null
                                                  ? 'Metric updated successfully'
                                                  : 'Metric added successfully',
                                              backgroundColor: Colors.green,
                                              textColor: Colors.white,
                                            );
                                            setState(() {
                                              showForm = false;
                                              editingMetric = null;
                                            });
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.blue900,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: Text(
                                          editingMetric != null
                                              ? 'Update Metric'
                                              : 'Save Metric',
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      OutlinedButton(
                                        onPressed: () {
                                          setState(() {
                                            showForm = false;
                                            editingMetric = null;
                                          });
                                        },
                                        style: OutlinedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text('Cancel'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (provider.metrics.isNotEmpty)
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Weight Trend',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 200,
                                  child: LineChart(
                                    LineChartData(
                                      gridData: const FlGridData(show: false),
                                      titlesData: FlTitlesData(
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 30,
                                            getTitlesWidget: (value, meta) {
                                              final date = DateTime
                                                  .fromMillisecondsSinceEpoch(
                                                      value.toInt());
                                              return Text(
                                                '${date.month}-${date.day}',
                                                style: const TextStyle(
                                                    fontSize: 12),
                                              );
                                            },
                                          ),
                                        ),
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 40,
                                          ),
                                        ),
                                        topTitles: const AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false)),
                                        rightTitles: const AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false)),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: provider.metrics
                                              .asMap()
                                              .entries
                                              .map((e) => FlSpot(
                                                  e.value.date
                                                      .millisecondsSinceEpoch
                                                      .toDouble(),
                                                  e.value.weight))
                                              .toList(),
                                          isCurved: true,
                                          color: AppColors.blue900,
                                          barWidth: 2,
                                          dotData: const FlDotData(show: true),
                                        ),
                                      ],
                                      lineTouchData: LineTouchData(
                                        touchTooltipData: LineTouchTooltipData(
                                          getTooltipItems: (touchedSpots) =>
                                              touchedSpots.map((spot) {
                                            final date = DateTime
                                                .fromMillisecondsSinceEpoch(
                                                    spot.x.toInt());
                                            return LineTooltipItem(
                                              'Date: ${date.month}-${date.day}\nWeight: ${spot.y} kg',
                                              const TextStyle(color: Colors.white),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(
                                  label: Text('Date',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('Weight',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('Height',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('BMI',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('Actions',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                            ],
                            rows: provider.metrics.isEmpty
                                ? [
                                    const DataRow(cells: [
                                      DataCell(Text('No metrics found')),
                                      DataCell(SizedBox()),
                                      DataCell(SizedBox()),
                                      DataCell(SizedBox()),
                                      DataCell(SizedBox()),
                                    ])
                                  ]
                                : provider.metrics.asMap().entries.map((entry) {
                                    final metric = entry.value;
                                    final bmi = metric.height > 0
                                        ? metric.weight /
                                            ((metric.height / 100) *
                                                (metric.height / 100))
                                        : 0;
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(
                                            '${metric.date.toLocal()}'
                                                .split(' ')[0])),
                                        DataCell(
                                            Text('${metric.weight} kg')),
                                        DataCell(
                                            Text('${metric.height} cm')),
                                        DataCell(
                                          Text(
                                            bmi.toStringAsFixed(1),
                                            style: TextStyle(
                                              color: AppColors.primaryDark,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit),
                                                onPressed: () {
                                                  setState(() {
                                                    editingMetric = metric;
                                                    showForm = true;
                                                    initControllers(metric);
                                                  });
                                                  Scrollable.ensureVisible(
                                                    context,
                                                    duration: const Duration(
                                                        milliseconds: 300),
                                                    curve: Curves.easeInOut,
                                                  );
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete),
                                                onPressed: () async {
                                                  final confirmed =
                                                      await showDialog<bool>(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: const Text(
                                                            'Delete Metric'),
                                                        content: const Text(
                                                            'Are you sure you want to delete this metric? This action cannot be undone.'),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(false),
                                                            child: const Text(
                                                                'Cancel'),
                                                          ),
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(true),
                                                            style: TextButton
                                                                .styleFrom(
                                                                    foregroundColor:
                                                                        Colors
                                                                            .red),
                                                            child: const Text(
                                                                'Delete'),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );

                                                  if (confirmed == true) {
                                                    await provider.deleteMetric(
                                                        metric.id!);
                                                    Fluttertoast.showToast(
                                                      msg:
                                                          'Metric deleted successfully',
                                                      backgroundColor:
                                                          Colors.green,
                                                      textColor: Colors.white,
                                                    );
                                                  }
                                                },
                                              ),
                                            ],
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
                ),
        );
      },
    );
  }
}