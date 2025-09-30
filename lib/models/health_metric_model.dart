import 'body_measurements.dart';

class HealthMetric {
  String? id;
  double weight;
  double height;
  double bmi;
  DateTime date;
  BodyMeasurements bodyMeasurements;

  HealthMetric({
    this.id,
    required this.weight,
    required this.height,
    required this.bmi,
    required this.date,
    required this.bodyMeasurements,
  });

  factory HealthMetric.fromJson(Map<String, dynamic> json) {
    return HealthMetric(
      id: json['id']?.toString(),
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      height: (json['height'] as num?)?.toDouble() ?? 0.0,
      bmi: (json['bmi'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      bodyMeasurements:
          BodyMeasurements.fromJson(json['bodyMeasurements'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'weight': weight,
        'height': height,
        'bmi': bmi,
        'date': date.toIso8601String().split('T')[0], // yyyy-MM-dd
        'bodyMeasurements': bodyMeasurements.toJson(),
      };
}