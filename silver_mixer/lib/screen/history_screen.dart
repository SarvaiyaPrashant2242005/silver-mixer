import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:silver_mixer/screen/EntryInputScreen.dart';
import '../controller/calculation_controller.dart';
import '../model/calculation_model.dart';
import '../services/language_service.dart';
import '../services/storage_service.dart';


class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<SavedCalculation> _calculations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCalculations();
    LanguageService.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    LanguageService.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    setState(() {});
  }

  Future<void> _loadCalculations() async {
    setState(() => _isLoading = true);
    final calculations = await StorageService.getAllCalculations();
    setState(() {
      _calculations = calculations;
      _isLoading = false;
    });
  }

  Future<void> _deleteCalculation(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LanguageService.delete),
        content: Text(LanguageService.deleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(LanguageService.no),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              LanguageService.yes,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StorageService.deleteCalculation(id);
      _loadCalculations();
    }
  }

  void _editCalculation(SavedCalculation calculation) {
    final controller = CalculationController();
    controller.loadCalculation(calculation);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EntryInputScreen(
          controller: controller,
          editId: calculation.id,
        ),
      ),
    ).then((_) => _loadCalculations());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LanguageService.history),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _calculations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        LanguageService.noHistory,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadCalculations,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _calculations.length,
                    itemBuilder: (context, index) {
                      final calculation = _calculations[index];
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => _editCalculation(calculation),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        calculation.title,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      onPressed: () => _editCalculation(calculation),
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 20),
                                      onPressed: () => _deleteCalculation(calculation.id),
                                      color: Colors.red,
                                    ),
                                  ],
                                ),
                                
                                if (calculation.description.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    calculation.description,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 12),

                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat('dd MMM yyyy, hh:mm a').format(calculation.date),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),
                                
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      _buildResultRow(
                                        LanguageService.kochCopper,
                                        calculation.result.step2.toStringAsFixed(0),
                                        Colors.green.shade700,
                                      ),
                                      const Divider(height: 16),
                                      _buildResultRow(
                                        LanguageService.gaalvaNear,
                                        calculation.result.step5.toStringAsFixed(0),
                                        Colors.purple.shade700,
                                      ),
                                      const Divider(height: 16),
                                      _buildResultRow(
                                        LanguageService.numberCopper,
                                        calculation.result.step6.toStringAsFixed(0),
                                        Colors.red.shade700,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildResultRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}