import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/health_metric_model.dart';
import '../models/body_measurements.dart';
import '../providers/health_metric_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';

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
  final measurementFields = ["chest", "waist", "hips", "neck", "biceps", "thighs", "calves"];
  final topFields = ["weight", "height", "date"];
  final _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    initControllers(HealthMetric(
      weight: 0,
      height: 0,
      bmi: 0,
      date: DateTime.now(),
      bodyMeasurements: BodyMeasurements(
        chest: 0, waist: 0, hips: 0, neck: 0, biceps: 0, thighs: 0, calves: 0,
      ),
    ));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HealthMetricProvider>().fetchMetrics();
    });
  }

  @override
  void dispose() {
    controllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  void initControllers(HealthMetric metric) {
    controllers.clear();
    for (var f in topFields) {
      if (f == 'date') {
        controllers[f] = TextEditingController(
          text: metric.date != null ? _dateFormat.format(metric.date) : _dateFormat.format(DateTime.now()),
        );
      } else {
        controllers[f] = TextEditingController(text: metric.toJson()[f]?.toString() ?? '');
      }
    }
    for (var f in measurementFields) {
      controllers[f] = TextEditingController(text: metric.bodyMeasurements.toJson()[f]?.toString() ?? '');
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
    DateTime date = DateTime.tryParse(controllers['date']?.text ?? '') ?? DateTime.now();

    return HealthMetric(
      id: id,
      weight: weight,
      height: height,
      bmi: bmi,
      date: date,
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
    if (bmi < 18.5) return Colors.blue[400]!;
    if (bmi < 25) return Colors.green[500]!;
    return Colors.red[500]!;
  }

  String _getBmiStatus(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Healthy';
    return 'Overweight';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(controllers['date']?.text ?? '') ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controllers['date']?.text = _dateFormat.format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HealthMetricProvider>(
      builder: (context, provider, _) {
        double bmi = 0;
        if (controllers['weight']?.text.isNotEmpty == true && controllers['height']?.text.isNotEmpty == true) {
          final weight = double.tryParse(controllers['weight']!.text) ?? 0;
          final height = double.tryParse(controllers['height']!.text) ?? 0;
          bmi = height > 0 ? weight / ((height / 100) * (height / 100)) : 0;
        }

        return Scaffold(
          appBar: const CustomAppBar(
            title: 'Health Metrics',
            isDashboard: false,
            showActions: true,
          ),
          body: provider.loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Static Header
                      const Text(
                        'Track Your Health Metrics',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Motivational Tip
                      _buildMotivationalTip(),
                      const SizedBox(height: 24),

                      // BMI Status Counters
                      _buildBmiStatusCounters(provider),
                      const SizedBox(height: 24),

                      // Add Metric Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Your Metrics',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            child: ElevatedButton.icon(
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
                                      chest: 0, waist: 0, hips: 0, neck: 0, biceps: 0, thighs: 0, calves: 0,
                                    ),
                                  ));
                                });
                                if (showForm) {
                                  Scrollable.ensureVisible(
                                    context,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                              icon: const Icon(Icons.add),
                              label: Text(showForm ? 'Close Form' : 'Add Metric'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.blue900,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Form
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: showForm
                            ? Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                          editingMetric != null ? 'Edit Metric' : 'Add Metric',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: topFields
                                              .where((f) => f != 'date')
                                              .map(
                                                (f) => Expanded(
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    child: TextFormField(
                                                      controller: controllers[f],
                                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                                                      ],
                                                      decoration: InputDecoration(
                                                        labelText: f[0].toUpperCase() + f.substring(1),
                                                        prefixIcon: Icon(
                                                          f == 'weight' ? Icons.fitness_center : Icons.height,
                                                          color: AppColors.blue900,
                                                        ),
                                                        border: const OutlineInputBorder(),
                                                      ),
                                                      validator: (value) {
                                                        if (value == null || value.isEmpty) {
                                                          return '${f[0].toUpperCase()}${f.substring(1)} is required';
                                                        }
                                                        if (double.tryParse(value) == null) {
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
                                        TextFormField(
                                          enabled: false,
                                          decoration: InputDecoration(
                                            labelText: 'BMI (auto)',
                                            prefixIcon: const Icon(Icons.favorite, color: AppColors.blue900),
                                            border: const OutlineInputBorder(),
                                          ),
                                          controller: TextEditingController(
                                            text: bmi == 0 ? '—' : '${bmi.toStringAsFixed(1)} (${_getBmiStatus(bmi)})',
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          height: 8,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: FractionallySizedBox(
                                            widthFactor: bmi == 0 ? 0 : (bmi * 4 / 100).clamp(0, 1),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: _getBmiColor(bmi),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        TextFormField(
                                          controller: controllers['date'],
                                          readOnly: true,
                                          onTap: () => _selectDate(context),
                                          decoration: InputDecoration(
                                            labelText: 'Date',
                                            prefixIcon: const Icon(Icons.date_range, color: AppColors.blue900),
                                            border: const OutlineInputBorder(),
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Date is required';
                                            }
                                            if (DateTime.tryParse(value) == null) {
                                              return 'Enter a valid date';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              showMeasurements = !showMeasurements;
                                            });
                                          },
                                          child: Text(
                                            showMeasurements ? 'Hide Body Measurements' : 'Show Body Measurements',
                                            style: const TextStyle(color: AppColors.skyBrand, fontSize: 16),
                                          ),
                                        ),
                                        if (showMeasurements)
                                          LayoutBuilder(
                                            builder: (context, constraints) {
                                              return GridView.count(
                                                crossAxisCount: constraints.maxWidth > 400 ? 2 : 1,
                                                shrinkWrap: true,
                                                physics: const NeverScrollableScrollPhysics(),
                                                childAspectRatio: constraints.maxWidth > 400 ? 5.5 : 4.5,
                                                mainAxisSpacing: 8,
                                                crossAxisSpacing: 8,
                                                children: measurementFields
                                                    .map(
                                                      (f) => Padding(
                                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                                        child: TextFormField(
                                                          controller: controllers[f],
                                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                          inputFormatters: [
                                                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                                                          ],
                                                          decoration: InputDecoration(
                                                            labelText: f[0].toUpperCase() + f.substring(1),
                                                            prefixIcon: const Icon(Icons.straighten, color: AppColors.blue900),
                                                            border: const OutlineInputBorder(),
                                                          ),
                                                          validator: (value) {
                                                            if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                                                              return 'Enter a valid number';
                                                            }
                                                            return null;
                                                          },
                                                        ),
                                                      ),
                                                    )
                                                    .toList(),
                                              );
                                            },
                                          ),
                                        const SizedBox(height: 24),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            AnimatedContainer(
                                              duration: const Duration(milliseconds: 300),
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  if (_formKey.currentState!.validate()) {
                                                    final metric = readMetricFromControllers(id: editingMetric?.id);
                                                    await provider.saveMetric(metric);
                                                    Fluttertoast.showToast(
                                                      msg: editingMetric != null ? 'Metric updated successfully' : 'Metric added successfully',
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
                                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                ),
                                                child: Text(
                                                  editingMetric != null ? 'Update Metric' : 'Save Metric',
                                                  style: const TextStyle(fontSize: 16),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            AnimatedContainer(
                                              duration: const Duration(milliseconds: 300),
                                              child: OutlinedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    showForm = false;
                                                    editingMetric = null;
                                                  });
                                                },
                                                style: OutlinedButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Cancel',
                                                  style: TextStyle(fontSize: 16),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 16),

                      // Weight Trend Chart
                      if (provider.metrics.isNotEmpty)
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: Card(
                            key: ValueKey(provider.metrics.length),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Weight Trend',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
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
                                                // Sort metrics by date to get proper order
                                                final sortedMetrics = provider.metrics.toList()
                                                  ..sort((a, b) => a.date.compareTo(b.date));
                                                
                                                // Check if this value matches any actual data point
                                                final matchingMetric = sortedMetrics.firstWhere(
                                                  (m) => m.date.millisecondsSinceEpoch.toDouble() == value,
                                                  orElse: () => HealthMetric(
                                                    weight: 0,
                                                    height: 0,
                                                    bmi: 0,
                                                    date: DateTime.fromMillisecondsSinceEpoch(0),
                                                    bodyMeasurements: BodyMeasurements(
                                                      chest: 0, waist: 0, hips: 0, neck: 0,
                                                      biceps: 0, thighs: 0, calves: 0,
                                                    ),
                                                  ),
                                                );
                                                
                                                // Only show label if we found a matching metric
                                                if (matchingMetric.date.millisecondsSinceEpoch != 0) {
                                                  return Padding(
                                                    padding: const EdgeInsets.only(top: 8),
                                                    child: Text(
                                                      DateFormat('MM-dd').format(matchingMetric.date),
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: Theme.of(context).brightness == Brightness.dark
                                                            ? Colors.white
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                  );
                                                }
                                                return const SizedBox.shrink();
                                              },
                                            ),
                                          ),
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 40,
                                              getTitlesWidget: (value, meta) {
                                                // Check if this value matches any actual weight
                                                final hasPoint = provider.metrics.any(
                                                  (m) => (m.weight - value).abs() < 0.01,
                                                );
                                                
                                                if (hasPoint) {
                                                  return Text(
                                                    value.toInt().toString(),
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Theme.of(context).brightness == Brightness.dark
                                                          ? Colors.white
                                                          : Colors.black,
                                                    ),
                                                  );
                                                }
                                                return const SizedBox.shrink();
                                              },
                                            ),
                                          ),
                                          topTitles: const AxisTitles(
                                              sideTitles: SideTitles(showTitles: false)),
                                          rightTitles: const AxisTitles(
                                              sideTitles: SideTitles(showTitles: false)),
                                        ),
                                        borderData: FlBorderData(
                                          show: true,
                                          border: Border(
                                            left: BorderSide(
                                              color: Theme.of(context).brightness == Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black,
                                              width: 1,
                                            ),
                                            bottom: BorderSide(
                                              color: Theme.of(context).brightness == Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: provider.metrics
                                                .map((m) => FlSpot(
                                                      m.date.millisecondsSinceEpoch.toDouble(),
                                                      m.weight,
                                                    ))
                                                .toList()
                                              ..sort((a, b) => a.x.compareTo(b.x)),
                                            isCurved: true,
                                            color: AppColors.skyBrand,
                                            barWidth: 3,
                                            dotData: const FlDotData(show: true),
                                            belowBarData: BarAreaData(
                                              show: true,
                                              color: AppColors.skyBrand.withValues(alpha: 0.2),
                                            ),
                                          ),
                                        ],
                                        lineTouchData: LineTouchData(
                                          touchTooltipData: LineTouchTooltipData(
                                            getTooltipItems: (touchedSpots) =>
                                                touchedSpots.map((spot) {
                                              final metric = provider.metrics.firstWhere(
                                                (m) => m.date.millisecondsSinceEpoch.toDouble() == spot.x,
                                              );
                                              return LineTooltipItem(
                                                'Date: ${_dateFormat.format(metric.date)}\n'
                                                'Weight: ${metric.weight.toStringAsFixed(1)} kg\n'
                                                'Height: ${metric.height.toStringAsFixed(1)} cm\n'
                                                'BMI: ${metric.bmi.toStringAsFixed(1)}\n'
                                                'Chest: ${metric.bodyMeasurements.chest.toStringAsFixed(1)} cm\n'
                                                'Waist: ${metric.bodyMeasurements.waist.toStringAsFixed(1)} cm\n'
                                                'Hips: ${metric.bodyMeasurements.hips.toStringAsFixed(1)} cm\n'
                                                'Neck: ${metric.bodyMeasurements.neck.toStringAsFixed(1)} cm\n'
                                                'Biceps: ${metric.bodyMeasurements.biceps.toStringAsFixed(1)} cm\n'
                                                'Thighs: ${metric.bodyMeasurements.thighs.toStringAsFixed(1)} cm\n'
                                                'Calves: ${metric.bodyMeasurements.calves.toStringAsFixed(1)} cm',
                                                const TextStyle(color: Colors.white, fontSize: 12),
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
                        ),

                      // BMI Trend Chart
                      if (provider.metrics.isNotEmpty)
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: Card(
                            key: ValueKey('bmi-${provider.metrics.length}'),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'BMI Trend',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
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
                                                // Get all unique X values (timestamps) from actual data
                                                final dataPoints = provider.metrics
                                                    .map((m) => m.date.millisecondsSinceEpoch.toDouble())
                                                    .toSet()
                                                    .toList()
                                                  ..sort();
                                                
                                                // Only show label if this value is one of our actual data points
                                                if (dataPoints.contains(value)) {
                                                  final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                                                  return Padding(
                                                    padding: const EdgeInsets.only(top: 8),
                                                    child: Text(
                                                      DateFormat('MM-dd').format(date),
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: Theme.of(context).brightness == Brightness.dark
                                                            ? Colors.white
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                  );
                                                }
                                                
                                                return const SizedBox.shrink();
                                              },
                                            ),
                                          ),
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 40,
                                              getTitlesWidget: (value, meta) {
                                                // Get all unique BMI values from actual data
                                                final dataPoints = provider.metrics
                                                    .map((m) => m.bmi)
                                                    .toSet()
                                                    .toList();
                                                
                                                // Only show label if this value matches one of our BMI values
                                                // Use tolerance for floating point comparison
                                                final hasMatch = dataPoints.any(
                                                  (bmi) => (bmi - value).abs() < 0.1,
                                                );
                                                
                                                if (hasMatch) {
                                                  return Text(
                                                    value.toStringAsFixed(1),
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Theme.of(context).brightness == Brightness.dark
                                                          ? Colors.white
                                                          : Colors.black,
                                                    ),
                                                  );
                                                }
                                                
                                                return const SizedBox.shrink();
                                              },
                                            ),
                                          ),
                                          topTitles: const AxisTitles(
                                              sideTitles: SideTitles(showTitles: false)),
                                          rightTitles: const AxisTitles(
                                              sideTitles: SideTitles(showTitles: false)),
                                        ),
                                        borderData: FlBorderData(
                                          show: true,
                                          border: Border(
                                            left: BorderSide(
                                              color: Theme.of(context).brightness == Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black,
                                              width: 1,
                                            ),
                                            bottom: BorderSide(
                                              color: Theme.of(context).brightness == Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: provider.metrics
                                                .map((m) => FlSpot(
                                                      m.date.millisecondsSinceEpoch.toDouble(),
                                                      m.bmi,
                                                    ))
                                                .toList()
                                              ..sort((a, b) => a.x.compareTo(b.x)),
                                            isCurved: true,
                                            color: Colors.red[500],
                                            barWidth: 3,
                                            dotData: const FlDotData(show: true),
                                            belowBarData: BarAreaData(
                                              show: true,
                                              color: Colors.red.withValues(alpha: 0.2),
                                            ),
                                          ),
                                        ],
                                        lineTouchData: LineTouchData(
                                          touchTooltipData: LineTouchTooltipData(
                                            getTooltipItems: (touchedSpots) =>
                                                touchedSpots.map((spot) {
                                              final metric = provider.metrics.firstWhere(
                                                (m) => m.date.millisecondsSinceEpoch.toDouble() == spot.x,
                                              );
                                              return LineTooltipItem(
                                                'Date: ${_dateFormat.format(metric.date)}\n'
                                                'BMI: ${metric.bmi.toStringAsFixed(1)} (${_getBmiStatus(metric.bmi)})\n'
                                                'Weight: ${metric.weight.toStringAsFixed(1)} kg\n'
                                                'Height: ${metric.height.toStringAsFixed(1)} cm',
                                                const TextStyle(color: Colors.white, fontSize: 12),
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
                        ),
                      const SizedBox(height: 16),

                      // Metrics Table
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Your Metrics',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columnSpacing: 16,
                                  columns: const [
                                    DataColumn(
                                      label: Text(
                                        'Date',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Weight',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Height',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'BMI',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Actions',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                  rows: provider.metrics.isEmpty
                                      ? [
                                          DataRow(
                                            cells: [
                                              DataCell(
                                                Text(
                                                  'No metrics found',
                                                  style: Theme.of(context).textTheme.bodyMedium,
                                                ),
                                              ),
                                              const DataCell(SizedBox()),
                                              const DataCell(SizedBox()),
                                              const DataCell(SizedBox()),
                                              const DataCell(SizedBox()),
                                            ],
                                          ),
                                        ]
                                      : provider.metrics.asMap().entries.map((entry) {
                                          final metric = entry.value;
                                          final bmi = metric.bmi;
                                          return DataRow(
                                            cells: [
                                              DataCell(
                                                Text(
                                                  _dateFormat.format(metric.date),
                                                  style: Theme.of(context).textTheme.bodyMedium,
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  '${metric.weight.toStringAsFixed(1)} kg',
                                                  style: Theme.of(context).textTheme.bodyMedium,
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  '${metric.height.toStringAsFixed(1)} cm',
                                                  style: Theme.of(context).textTheme.bodyMedium,
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  bmi.toStringAsFixed(1),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: _getBmiColor(bmi),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(Icons.edit, color: AppColors.blue600),
                                                      onPressed: () {
                                                        setState(() {
                                                          editingMetric = metric;
                                                          showForm = true;
                                                          initControllers(metric);
                                                        });
                                                        Scrollable.ensureVisible(
                                                          context,
                                                          duration: const Duration(milliseconds: 300),
                                                          curve: Curves.easeInOut,
                                                        );
                                                      },
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(Icons.delete, color: Colors.red),
                                                      onPressed: () async {
                                                        final confirmed = await showDialog<bool>(
                                                          context: context,
                                                          builder: (BuildContext context) {
                                                            return AlertDialog(
                                                              title: const Text(
                                                                'Delete Metric',
                                                                style: TextStyle(
                                                                  fontSize: 24,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                              content: const Text(
                                                                'Are you sure you want to delete this metric? This action cannot be undone.',
                                                              ),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () => Navigator.of(context).pop(false),
                                                                  child: const Text(
                                                                    'Cancel',
                                                                    style: TextStyle(
                                                                      fontSize: 16,
                                                                      fontWeight: FontWeight.w600,
                                                                    ),
                                                                  ),
                                                                ),
                                                                TextButton(
                                                                  onPressed: () => Navigator.of(context).pop(true),
                                                                  style: TextButton.styleFrom(
                                                                    foregroundColor: Colors.red,
                                                                  ),
                                                                  child: const Text(
                                                                    'Delete',
                                                                    style: TextStyle(
                                                                      fontSize: 16,
                                                                      fontWeight: FontWeight.w600,
                                                                      color: Colors.red,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );

                                                        if (confirmed == true) {
                                                          await provider.deleteMetric(metric.id!);
                                                          Fluttertoast.showToast(
                                                            msg: 'Metric deleted successfully',
                                                            backgroundColor: Colors.green,
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
                            ],
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

  Widget _buildMotivationalTip() {
    const tips = [
      'Stay consistent with your measurements!',
      'Track your progress for better health!',
      'Every step counts towards a healthier you!',
      'Your body deserves your attention!',
    ];
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Container(
        key: ValueKey(DateTime.now().second),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.blue900.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lightbulb_outline, color: Colors.amber),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                tips[DateTime.now().second % tips.length],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBmiStatusCounters(HealthMetricProvider provider) {
    final statusCounts = {
      'Underweight': provider.metrics.where((m) => m.bmi < 18.5).length,
      'Healthy': provider.metrics.where((m) => m.bmi >= 18.5 && m.bmi < 25).length,
      'Overweight': provider.metrics.where((m) => m.bmi >= 25).length,
    };
    const statuses = [
      {'title': 'Underweight', 'key': 'Underweight', 'color': Colors.blue},
      {'title': 'Healthy', 'key': 'Healthy', 'color': Colors.green},
      {'title': 'Overweight', 'key': 'Overweight', 'color': Colors.red},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: statuses.map((status) {
        final count = statusCounts[status['key'] as String] ?? 0;
        final color = (status['color'] as MaterialColor)[500]!;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
            color: color.withOpacity(0.2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                status['title'] as String,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}