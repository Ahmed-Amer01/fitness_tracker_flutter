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