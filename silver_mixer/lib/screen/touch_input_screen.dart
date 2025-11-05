import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../controller/calculation_controller.dart';
import '../services/language_service.dart';
import '../services/storage_service.dart';
import 'result_screen.dart';

class TouchInputScreen extends StatefulWidget {
  final CalculationController controller;
  final String? editId;

  const TouchInputScreen({
    Key? key,
    required this.controller,
    this.editId,
  }) : super(key: key);

  @override
  State<TouchInputScreen> createState() => _TouchInputScreenState();
}

class _TouchInputScreenState extends State<TouchInputScreen> {
  late TextEditingController _meTouchController;
  late TextEditingController _coTouchController;
  late TextEditingController _gaTouchController;
  final today = DateFormat('dd MMM yyyy').format(DateTime.now());
  int _calculationNumber = 0;

  @override
  void initState() {
    super.initState();
    _meTouchController = TextEditingController(
      text: widget.controller.meTouch > 0 ? widget.controller.meTouch.toString() : '',
    );
    _coTouchController = TextEditingController(
      text: widget.controller.coTouch > 0 ? widget.controller.coTouch.toString() : '',
    );
    _gaTouchController = TextEditingController(
      text: widget.controller.gaTouch > 0 ? widget.controller.gaTouch.toString() : '',
    );
    _gaTouchController.text = _meTouchController.text;
    _loadCalculationNumber();
    LanguageService.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    _meTouchController.dispose();
    _coTouchController.dispose();
    _gaTouchController.dispose();
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

  void _calculate() {
    final meTouch = double.tryParse(_meTouchController.text) ?? 0;
    final coTouch = double.tryParse(_coTouchController.text) ?? 0;

    if (meTouch <= 0 || coTouch <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LanguageService.fillAllFields),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    widget.controller.setMeTouch(meTouch);
    widget.controller.setCoTouch(coTouch);
    widget.controller.calculateResult();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
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
                      '${LanguageService.appTitle} - ${LanguageService.currentLanguage == AppLanguage.english ? 'Step 2' : 'પગલું 2'}',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LanguageService.currentLanguage == AppLanguage.english
                          ? 'Enter Touch Values'
                          : 'ટચ મૂલ્યો દાખલ કરો',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 24),

                    // Me. Touch
                    Text(
                      LanguageService.meTouch,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _meTouchController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      decoration: InputDecoration(
                        hintText: LanguageService.enterValue,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.touch_app),
                        filled: true,
                        fillColor: Colors.blue.shade50,
                      ),
                      style: const TextStyle(fontSize: 18),
                      onChanged: (value) {
                        setState(() {
                          _gaTouchController.text = value;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    // Co. Touch
                    Text(
                      LanguageService.coTouch,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _coTouchController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      decoration: InputDecoration(
                        hintText: LanguageService.enterValue,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.touch_app),
                        filled: true,
                        fillColor: Colors.green.shade50,
                      ),
                      style: const TextStyle(fontSize: 18),
                    ),

                    const SizedBox(height: 20),

                    // Ga. Touch (Auto-filled)
                    Text(
                      '${LanguageService.gaTouch} (${LanguageService.currentLanguage == AppLanguage.english ? 'Auto-filled' : 'સ્વતઃ ભરાયેલ'})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _gaTouchController,
                      enabled: false,
                      decoration: InputDecoration(
                        hintText: LanguageService.enterValue,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                      ),
                      style: const TextStyle(fontSize: 18),
                    ),

                    const SizedBox(height: 8),
                    Text(
                      LanguageService.currentLanguage == AppLanguage.english
                          ? '* Ga. Touch is automatically same as Me. Touch'
                          : '* ગા.ટચ આપોઆપ મે.ટચ જેટલું જ હોય છે',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calculate, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    LanguageService.calculate,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}