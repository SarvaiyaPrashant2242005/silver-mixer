import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:silver_mixer/screen/history_screen.dart';
import '../controller/calculation_controller.dart';
import '../model/calculation_model.dart';
import '../services/language_service.dart';
import '../services/storage_service.dart';

class ResultScreen extends StatefulWidget {
  final CalculationController controller;
  final String? editId;

  const ResultScreen({Key? key, required this.controller, this.editId})
    : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late final String today;
  int _calculationNumber = 0;

  @override
  void initState() {
    super.initState();
    today = DateFormat('dd MMM yyyy').format(DateTime.now());
    LanguageService.addListener(_onLanguageChanged);
    _loadCalculationNumber();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    LanguageService.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    setState(() {});
  }

  Future<void> _loadCalculationNumber() async {
    final allCalculations = await StorageService.getAllCalculations();
    setState(() {
      if (widget.editId != null) {
        // Find the index of the current calculation being edited
        final index = allCalculations.indexWhere(
          (calc) => calc.id == widget.editId,
        );
        _calculationNumber = index != -1
            ? index + 1
            : allCalculations.length + 1;
      } else {
        // For new calculation, it will be the next number
        _calculationNumber = allCalculations.length + 1;
      }
    });
  }

  Future<bool> _isTitleUnique(String title) async {
    final allCalculations = await StorageService.getAllCalculations();

    // If editing, allow same title for the same entry
    if (widget.editId != null) {
      return !allCalculations.any(
        (calc) =>
            calc.title.toLowerCase() == title.toLowerCase() &&
            calc.id != widget.editId,
      );
    }

    // For new entries, check if title exists
    return !allCalculations.any(
      (calc) => calc.title.toLowerCase() == title.toLowerCase(),
    );
  }

  Future<void> _saveCalculation() async {
    final title = _titleController.text.trim();

    // Check if title is empty
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LanguageService.enterTitle),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if title is unique
    final isUnique = await _isTitleUnique(title);
    if (!isUnique) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LanguageService.currentLanguage == AppLanguage.english
                ? 'This title already exists. Please use a different title.'
                : 'આ શીર્ષક પહેલેથી અસ્તિત્વમાં છે. કૃપા કરીને અલગ શીર્ષક વાપરો.',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // NEW: Check if limit of 10 calculations reached (only for new calculations)
    if (widget.editId == null) {
      final allCalculations = await StorageService.getAllCalculations();
      if (allCalculations.length >= 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              LanguageService.currentLanguage == AppLanguage.english
                  ? 'Maximum limit of 10 calculations reached. Please delete an old calculation to save a new one.'
                  : 'મહત્તમ 10 ગણતરીની મર્યાદા પહોંચી ગઈ છે. નવી ગણતરી સાચવવા માટે કૃપા કરીને જૂની ગણતરી કાઢી નાખો.',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: LanguageService.currentLanguage == AppLanguage.english
                  ? 'View History'
                  : 'ઇતિહાસ જુઓ',
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const HistoryScreen(),
                  ),
                  (route) => false, // Removes all previous routes
                );
              },
            ),
          ),
        );
        return;
      }
    }

    final calculation = SavedCalculation(
      id: widget.editId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: _descriptionController.text.trim(),
      date: DateTime.now(),
      entries: widget.controller.entries,
      result: widget.controller.result!,
    );

    final success = await StorageService.saveCalculation(calculation);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LanguageService.calculationSaved),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to home
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void _resetCalculation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          LanguageService.currentLanguage == AppLanguage.english
              ? 'Reset Calculation?'
              : 'ગણતરી રીસેટ કરીએ?',
        ),
        content: Text(
          LanguageService.currentLanguage == AppLanguage.english
              ? 'This will clear all entered values.'
              : 'આ બધા દાખલ કરેલા મૂલ્યો સાફ કરશે.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(LanguageService.cancel),
          ),
          TextButton(
            onPressed: () {
              widget.controller.reset();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text(
              LanguageService.reset,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationStep(
    String label,
    String value, {
    Color? labelColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: labelColor ?? Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Divider(color: Colors.grey.shade400, thickness: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.controller.result;
    if (result == null) return const SizedBox();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  LanguageService.calculation,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_calculationNumber > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(
                      '$_calculationNumber',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Text(
              today,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetCalculation,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Calculation Result Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LanguageService.currentLanguage == AppLanguage.english
                          ? 'Calculation Result'
                          : 'ગણતરીનું પરિણામ',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildCalculationStep(
                      '${widget.controller.totalFine} ÷ ${result.meTouch.toStringAsFixed(0)} ${LanguageService.meTouch}',
                      result.step1.toStringAsFixed(0),
                    ),
                    _buildDivider(),
                    _buildCalculationStep(
                      '${result.step1.toStringAsFixed(0)} - ${widget.controller.totalWeight.toStringAsFixed(0)} ${LanguageService.gaTopna}',
                      '${result.step2.toStringAsFixed(0)} ${LanguageService.kochCopper}',
                      labelColor: Colors.green.shade700,
                    ),
                    _buildDivider(),
                    _buildCalculationStep(
                      '${result.step2.toStringAsFixed(0)} × ${result.coTouch.toStringAsFixed(2)} ${LanguageService.coTouch}',
                      '${result.step3.toStringAsFixed(0)} ${LanguageService.silverFine}',
                      labelColor: Colors.orange.shade700,
                    ),
                    _buildDivider(),
                    _buildCalculationStep(
                      '${result.step3.round()} + ${widget.controller.totalFine} ${LanguageService.fine}',
                      result.step4.toStringAsFixed(0),
                    ),
                    _buildDivider(),
                    _buildCalculationStep(
                      '${result.step4.toStringAsFixed(0)} ÷ ${result.meTouch.toStringAsFixed(0)} ${LanguageService.meTouch}',
                      '${result.step5.toStringAsFixed(0)} ${LanguageService.gaalvaNear}',
                      labelColor: Colors.purple.shade700,
                    ),
                    _buildDivider(),
                    _buildCalculationStep(
                      '${result.step5.toStringAsFixed(0)} - ${widget.controller.totalWeight.toStringAsFixed(0)} ${LanguageService.gaTopna}',
                      '${result.step6.toStringAsFixed(0)} ${LanguageService.numberCopper}',
                      labelColor: Colors.red.shade700,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Save Section
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LanguageService.currentLanguage == AppLanguage.english
                          ? 'Save Calculation'
                          : 'ગણતરી સાચવો',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: LanguageService.title,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.title),
                        helperText:
                            LanguageService.currentLanguage ==
                                AppLanguage.english
                            ? 'Title must be unique'
                            : 'શીર્ષક અનન્ય હોવું આવશ્યક છે',
                        helperStyle: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: LanguageService.description,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.notes),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _resetCalculation,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Colors.red),
                            ),
                            child: Text(LanguageService.reset),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveCalculation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(LanguageService.save),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
