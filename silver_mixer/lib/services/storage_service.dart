import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/calculation_model.dart';

class StorageService {
  static SharedPreferences? _prefs;
  static const String _calculationsKey = 'saved_calculations';

  static Future<void> init(SharedPreferences prefs) async {
    _prefs = prefs;
  }

  // Save a calculation
  static Future<bool> saveCalculation(SavedCalculation calculation) async {
    try {
      final calculations = await getAllCalculations();
      
      // Check if calculation with same ID exists, update it
      final index = calculations.indexWhere((c) => c.id == calculation.id);
      if (index != -1) {
        calculations[index] = calculation;
      } else {
        calculations.insert(0, calculation); // Add to beginning
      }

      final jsonList = calculations.map((c) => c.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      
      return await _prefs?.setString(_calculationsKey, jsonString) ?? false;
    } catch (e) {
      print('Error saving calculation: $e');
      return false;
    }
  }

  // Get all calculations
  static Future<List<SavedCalculation>> getAllCalculations() async {
    try {
      final jsonString = _prefs?.getString(_calculationsKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((json) => SavedCalculation.fromJson(json))
          .toList();
    } catch (e) {
      print('Error loading calculations: $e');
      return [];
    }
  }

  // Delete a calculation
  static Future<bool> deleteCalculation(String id) async {
    try {
      final calculations = await getAllCalculations();
      calculations.removeWhere((c) => c.id == id);

      final jsonList = calculations.map((c) => c.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      
      return await _prefs?.setString(_calculationsKey, jsonString) ?? false;
    } catch (e) {
      print('Error deleting calculation: $e');
      return false;
    }
  }

  // Get calculation by ID
  static Future<SavedCalculation?> getCalculationById(String id) async {
    try {
      final calculations = await getAllCalculations();
      return calculations.firstWhere(
        (c) => c.id == id,
        orElse: () => throw Exception('Not found'),
      );
    } catch (e) {
      return null;
    }
  }

  // Clear all calculations
  static Future<bool> clearAllCalculations() async {
    try {
      return await _prefs?.remove(_calculationsKey) ?? false;
    } catch (e) {
      print('Error clearing calculations: $e');
      return false;
    }
  }
}