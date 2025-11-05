class CalculationEntry {
  final double weight;
  final double touch;
  final double fine;

  CalculationEntry({
    required this.weight,
    required this.touch,
    required this.fine,
  });

  Map<String, dynamic> toJson() => {
    'weight': weight,
    'touch': touch,
    'fine': fine,
  };

  factory CalculationEntry.fromJson(Map<String, dynamic> json) {
    return CalculationEntry(
      weight: (json['weight'] ?? 0).toDouble(),
      touch: (json['touch'] ?? 0).toDouble(),
      fine: (json['fine'] ?? 0).toDouble(),
    );
  }
}

class CalculationResult {
  final double meTouch;
  final double coTouch;
  final double gaTouch;
  
  final double step1; // 2500 + 42 મે.ટચ = 5952
  final double step2; // 5952 - 5000 ગા.ટોચના = 952 કોચ કોપર
  final double step3; // 952 × 2.75 કો.ટચ = 2617 ચાંદી ફાઈન
  final double step4; // 26 + 2500 ફાઈન = 2526
  final double step5; // 2526 - 42 મે.ટચ = 6014 ગાળવા નંબર નજીક
  final double step6; // 6014 - 5000 ગા.ટોચના = 1014 નંબર કોપર

  CalculationResult({
    required this.meTouch,
    required this.coTouch,
    required this.gaTouch,
    required this.step1,
    required this.step2,
    required this.step3,
    required this.step4,
    required this.step5,
    required this.step6,
  });

  Map<String, dynamic> toJson() => {
    'meTouch': meTouch,
    'coTouch': coTouch,
    'gaTouch': gaTouch,
    'step1': step1,
    'step2': step2,
    'step3': step3,
    'step4': step4,
    'step5': step5,
    'step6': step6,
  };

  factory CalculationResult.fromJson(Map<String, dynamic> json) {
    return CalculationResult(
      meTouch: (json['meTouch'] ?? 0).toDouble(),
      coTouch: (json['coTouch'] ?? 0).toDouble(),
      gaTouch: (json['gaTouch'] ?? 0).toDouble(),
      step1: (json['step1'] ?? 0).toDouble(),
      step2: (json['step2'] ?? 0).toDouble(),
      step3: (json['step3'] ?? 0).toDouble(),
      step4: (json['step4'] ?? 0).toDouble(),
      step5: (json['step5'] ?? 0).toDouble(),
      step6: (json['step6'] ?? 0).toDouble(),
    );
  }
}

class SavedCalculation {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final List<CalculationEntry> entries;
  final CalculationResult result;

  SavedCalculation({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.entries,
    required this.result,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'date': date.toIso8601String(),
    'entries': entries.map((e) => e.toJson()).toList(),
    'result': result.toJson(),
  };

  factory SavedCalculation.fromJson(Map<String, dynamic> json) {
    return SavedCalculation(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      entries: (json['entries'] as List? ?? [])
          .map((e) => CalculationEntry.fromJson(e))
          .toList(),
      result: CalculationResult.fromJson(json['result'] ?? {}),
    );
  }
}