class BodyMeasurements {
  double chest;
  double waist;
  double hips;
  double neck;
  double biceps;
  double thighs;
  double calves;

  BodyMeasurements({
    required this.chest,
    required this.waist,
    required this.hips,
    required this.neck,
    required this.biceps,
    required this.thighs,
    required this.calves,
  });

  factory BodyMeasurements.fromJson(Map<String, dynamic> json) {
    return BodyMeasurements(
      chest: (json['chest'] as num?)?.toDouble() ?? 0.0,
      waist: (json['waist'] as num?)?.toDouble() ?? 0.0,
      hips: (json['hips'] as num?)?.toDouble() ?? 0.0,
      neck: (json['neck'] as num?)?.toDouble() ?? 0.0,
      biceps: (json['biceps'] as num?)?.toDouble() ?? 0.0,
      thighs: (json['thighs'] as num?)?.toDouble() ?? 0.0,
      calves: (json['calves'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'chest': chest,
        'waist': waist,
        'hips': hips,
        'neck': neck,
        'biceps': biceps,
        'thighs': thighs,
        'calves': calves,
      };
}

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