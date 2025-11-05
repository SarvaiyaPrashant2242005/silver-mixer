import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../controller/calculation_controller.dart';
import '../services/language_service.dart';
import '../services/storage_service.dart';
import 'touch_input_screen.dart';

class EntryInputScreen extends StatefulWidget {
  final CalculationController controller;
  final String? editId;
  
  const EntryInputScreen({
    Key? key,
    required this.controller,
    this.editId,
  }) : super(key: key);

  @override
  State<EntryInputScreen> createState() => _EntryInputScreenState();
}

class _EntryInputScreenState extends State<EntryInputScreen> {
  final List<List<TextEditingController>> _controllers = [];
  final today = DateFormat('dd-MM-yyyy').format(DateTime.now());
  int _calculationNumber = 0;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadCalculationNumber();
    LanguageService.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    _disposeControllers();
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
        final index = allCalculations.indexWhere((calc) => calc.id == widget.editId);
        _calculationNumber = index != -1 ? index + 1 : allCalculations.length + 1;
      } else {
        // For new calculation, it will be the next number
        _calculationNumber = allCalculations.length + 1;
      }
    });
  }

  void _initControllers() {
    for (int i = 0; i < widget.controller.entries.length; i++) {
      final entry = widget.controller.entries[i];
      _controllers.add([
        TextEditingController(text: entry.weight > 0 ? entry.weight.toString() : ''),
        TextEditingController(text: entry.touch > 0 ? entry.touch.toString() : ''),
        TextEditingController(text: entry.fine > 0 ? entry.fine.toString() : ''),
      ]);
    }
  }

  void _disposeControllers() {
    for (var controllerList in _controllers) {
      for (var controller in controllerList) {
        controller.dispose();
      }
    }
  }

  void _addNewEntry() {
    widget.controller.addEntry();
    _controllers.add([
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
    ]);
    setState(() {});
  }

  bool _hasEntryData(int index) {
    return _controllers[index][0].text.isNotEmpty ||
           _controllers[index][1].text.isNotEmpty ||
           _controllers[index][2].text.isNotEmpty;
  }

  Future<void> _removeEntry(int index) async {
    if (_controllers.length <= 1) {
      return;
    }

    // Check if entry has data
    if (_hasEntryData(index)) {
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              LanguageService.currentLanguage == AppLanguage.english
                  ? 'Delete Entry'
                  : 'એન્ટ્રી કાઢી નાખો',
            ),
            content: Text(
              LanguageService.currentLanguage == AppLanguage.english
                  ? 'Are you sure you want to delete this entry? All data will be lost.'
                  : 'શું તમે ખરેખર આ એન્ટ્રી કાઢી નાખવા માંગો છો? બધો ડેટા ગુમ થઈ જશે.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  LanguageService.currentLanguage == AppLanguage.english
                      ? 'Cancel'
                      : 'રદ કરો',
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: Text(
                  LanguageService.currentLanguage == AppLanguage.english
                      ? 'Delete'
                      : 'કાઢી નાખો',
                ),
              ),
            ],
          );
        },
      );

      // If user cancelled or closed the dialog
      if (confirm != true) {
        return;
      }
    }

    // Proceed with deletion
    widget.controller.removeEntry(index);
    for (var controller in _controllers[index]) {
      controller.dispose();
    }
    _controllers.removeAt(index);
    setState(() {});
  }

  void _calculateAndUpdateFine(int index) {
    final weight = double.tryParse(_controllers[index][0].text) ?? 0;
    final touch = double.tryParse(_controllers[index][1].text) ?? 0;
    
    if (weight > 0 && touch > 0) {
      final fine = (weight * touch) / 100;
      _controllers[index][2].text = fine.toStringAsFixed(2);
    } else {
      _controllers[index][2].text = '';
    }
  }

  void _updateEntry(int index) {
    final weight = double.tryParse(_controllers[index][0].text) ?? 0;
    final touch = double.tryParse(_controllers[index][1].text) ?? 0;
    final fine = double.tryParse(_controllers[index][2].text) ?? 0;
    widget.controller.updateEntry(index, weight, touch, fine);
  }

  double _calculateTotalWeight() {
    double total = 0;
    for (var controllerList in _controllers) {
      total += double.tryParse(controllerList[0].text) ?? 0;
    }
    return total;
  }

  double _calculateTotalFine() {
    double total = 0;
    for (var controllerList in _controllers) {
      total += double.tryParse(controllerList[2].text) ?? 0;
    }
    return total;
  }

  void _proceedToNext() {
    // Update all entries
    for (int i = 0; i < _controllers.length; i++) {
      _updateEntry(i);
    }

    if (!widget.controller.validateEntries()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LanguageService.fillAllFields),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TouchInputScreen(
          controller: widget.controller,
          editId: widget.editId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      '${LanguageService.appTitle} - ${LanguageService.currentLanguage == AppLanguage.english ? 'Step 1' : 'પગલું 1'}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                 
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  today,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (_calculationNumber > 0)
                  Text(
                    '${LanguageService.calculation}: $_calculationNumber',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Total Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    LanguageService.currentLanguage == AppLanguage.english ? 'Total' : 'કુલ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Text(
                        LanguageService.weight,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _calculateTotalWeight().toStringAsFixed(2),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: const SizedBox(),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Text(
                        LanguageService.fine,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _calculateTotalFine().toStringAsFixed(2),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),
          // Header Row (below total)
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    LanguageService.serialNumber,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    LanguageService.weight,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    LanguageService.touch,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    LanguageService.fine,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),
          // Input Fields List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _controllers.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _controllers[index][0],
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                            ],
                            decoration: InputDecoration(
                              hintText: LanguageService.enterValue,
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            ),
                            textAlign: TextAlign.center,
                            onChanged: (_) {
                              _calculateAndUpdateFine(index);
                              _updateEntry(index);
                              setState(() {}); // Real-time update
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _controllers[index][1],
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                            ],
                            decoration: InputDecoration(
                              hintText: LanguageService.enterValue,
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            ),
                            textAlign: TextAlign.center,
                            onChanged: (_) {
                              _calculateAndUpdateFine(index);
                              _updateEntry(index);
                              setState(() {}); // Real-time update
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _controllers[index][2],
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                            ],
                            decoration: InputDecoration(
                              hintText: LanguageService.enterValue,
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              filled: true,
                              fillColor: Colors.grey.shade200,
                            ),
                            textAlign: TextAlign.center,
                            enabled: false,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_controllers.length > 1)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeEntry(index),
                          )
                        else
                          const SizedBox(width: 40),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _addNewEntry,
            heroTag: 'add',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            onPressed: _proceedToNext,
            heroTag: 'next',
            label: Text(LanguageService.next),
            icon: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }
}