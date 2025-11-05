import 'package:flutter/material.dart';
import '../model/calculation_model.dart';

class CalculationController extends ChangeNotifier {
  List<CalculationEntry> _entries = [
    CalculationEntry(weight: 0, touch: 0, fine: 0),
  ];

  double _meTouch = 0;
  double _coTouch = 0;
  double _gaTouch = 0;

  CalculationResult? _result;

  // Getters
  List<CalculationEntry> get entries => _entries;
  double get meTouch => _meTouch;
  double get coTouch => _coTouch;
  double get gaTouch => _gaTouch;
  CalculationResult? get result => _result;

  // Get total weight from all entries
  double get totalWeight {
    return _entries.fold(0, (sum, entry) => sum + entry.weight);
  }

  // Get total fine from all entries
  double get totalFine {
    return _entries.fold(0, (sum, entry) => sum + entry.fine);
  }

  // Add new entry
  void addEntry() {
    _entries.add(CalculationEntry(weight: 0, touch: 0, fine: 0));
    notifyListeners();
  }

  // Remove entry at index
  void removeEntry(int index) {
    if (_entries.length > 1) {
      _entries.removeAt(index);
      notifyListeners();
    }
  }

  // Update entry at index
  void updateEntry(int index, double weight, double touch, double fine) {
    if (index < _entries.length) {
      _entries[index] = CalculationEntry(
        weight: weight,
        touch: touch,
        fine: fine,
      );
      notifyListeners();
    }
  }

  // Set touch values
  void setMeTouch(double value) {
    _meTouch = value;
    _gaTouch = value; // ga.touch is always same as me.touch
    notifyListeners();
  }

  void setCoTouch(double value) {
    _coTouch = value;
    notifyListeners();
  }

  // Calculate the result based on the screenshot formula
void calculateResult() {
    // Step 1: totalFine + meTouch
    final step1 = (totalFine / _meTouch) * 100;

    // Step 2: step1 - totalWeight = koch copper
    final step2 = step1 - totalWeight;

    // Step 3: step2 * coTouch, divide by 100, and remove fractions = silver fine
    final step3 = ((step2 * _coTouch) / 100).truncate().toDouble();

    // Step 4: (step3 rounded) + totalFine
    final step4 = step3.round() + totalFine;

    // Step 5: step4 - meTouch = gaalva number near
    final step5 =(( step4 / _meTouch) * 100).truncate().toDouble();

    // Step 6: step5 - totalWeight = number copper
    final step6 = step5 - totalWeight;

    _result = CalculationResult(
      meTouch: _meTouch,
      coTouch: _coTouch,
      gaTouch: _gaTouch,
      step1: step1,
      step2: step2,
      step3: step3,
      step4: step4.toDouble(),
      step5: step5,
      step6: step6,
    );

    notifyListeners();
  }

  // Load calculation for editing
  void loadCalculation(SavedCalculation calculation) {
    _entries = List.from(calculation.entries);
    _meTouch = calculation.result.meTouch;
    _coTouch = calculation.result.coTouch;
    _gaTouch = calculation.result.gaTouch;
    _result = calculation.result;
    notifyListeners();
  }

  // Reset all values
  void reset() {
    _entries = [
      CalculationEntry(weight: 0, touch: 0, fine: 0),
    ];
    _meTouch = 0;
    _coTouch = 0;
    _gaTouch = 0;
    _result = null;
    notifyListeners();
  }

  // Validate if all entries have values
  bool validateEntries() {
    for (var entry in _entries) {
      if (entry.weight <= 0 || entry.touch <= 0 || entry.fine <= 0) {
        return false;
      }
    }
    return true;
  }

  // Validate touch values
  bool validateTouchValues() {
    return _meTouch > 0 && _coTouch > 0;
  }
}