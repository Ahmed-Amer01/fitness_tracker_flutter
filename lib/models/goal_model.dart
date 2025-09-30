enum GoalStatus { notStarted, inProgress, achieved, abandoned }

extension GoalStatusExtension on GoalStatus {
  String get statusDisplay {
    switch (this) {
      case GoalStatus.inProgress:
        return 'In Progress';
      case GoalStatus.achieved:
        return 'Achieved';
      case GoalStatus.abandoned:
        return 'Abandoned';
      default:
        return 'Not Started';
    }
  }

  String get serverValue {
    switch (this) {
      case GoalStatus.notStarted:
        return 'NOT_STARTED';
      case GoalStatus.inProgress:
        return 'IN_PROGRESS';
      case GoalStatus.achieved:
        return 'ACHIEVED';
      case GoalStatus.abandoned:
        return 'ABANDONED';
    }
  }
}

class Goal {
  String? id;
  String description;
  double targetWeight;
  double currentWeight;
  String deadline;
  GoalStatus status;
  DateTime createdAt;
  DateTime updatedAt;

  Goal({
    this.id,
    required this.description,
    required this.targetWeight,
    required this.currentWeight,
    required this.deadline,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id']?.toString(),
      description: json['description'] ?? '',
      targetWeight: (json['targetWeight'] as num?)?.toDouble() ?? 0.0,
      currentWeight: (json['currentWeight'] as num?)?.toDouble() ?? 0.0,
      deadline: json['deadline'] ?? '',
      status: _parseStatus(json['status'] ?? 'NOT_STARTED'),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'description': description,
        'targetWeight': targetWeight,
        'currentWeight': currentWeight,
        'deadline': deadline,
        'status': status.serverValue, // Use serverValue to match server enum
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  static GoalStatus _parseStatus(String status) {
    switch (status.toUpperCase()) {
      case 'IN_PROGRESS':
        return GoalStatus.inProgress;
      case 'ACHIEVED':
        return GoalStatus.achieved;
      case 'ABANDONED':
        return GoalStatus.abandoned;
      case 'NOT_STARTED':
        return GoalStatus.notStarted;
      default:
        return GoalStatus.notStarted;
    }
  }
}