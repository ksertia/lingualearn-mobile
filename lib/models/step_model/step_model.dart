/*class StepModel {
  final String label;
  final String status;

  StepModel({required this.label, required this.status});

  // Convertir depuis JSON
  factory StepModel.fromJson(Map<String, dynamic> json) {
    return StepModel(
      label: json['label'] ?? 'Étape inconnue',
      status: json['status'] ?? 'Verrouillé',
    );
  }

  // Convertir vers JSON si besoin
  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'status': status,
    };
  }
}*/
