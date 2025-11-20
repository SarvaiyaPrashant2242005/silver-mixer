import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:silver_mixer/helper/ad_helper.dart';
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
  List<SavedCalculation> _filteredCalculations = [];
  bool _isLoading = true;

  // Search and filter controllers
  final TextEditingController _searchController = TextEditingController();
  DateTimeRange? _selectedDateRange;
  bool _isSearching = false;

  // Interstitial Ad
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadCalculations();
    _loadInterstitialAd();
    LanguageService.addListener(_onLanguageChanged);
    _searchController.addListener(_filterCalculations);
  }

  @override
  void dispose() {
    LanguageService.removeListener(_onLanguageChanged);
    _searchController.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  void _onLanguageChanged() {
    setState(() {});
  }

  // Load Interstitial Ad
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.getIntertitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          print('✓ Interstitial ad loaded successfully');
          _interstitialAd = ad;
          setState(() {
            _isInterstitialAdLoaded = true;
          });
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('✗ Interstitial ad failed to load: ${error.message}');
          print('Error code: ${error.code}');
          setState(() {
            _isInterstitialAdLoaded = false;
          });
        },
      ),
    );
  }

  // Show Interstitial Ad
  Future<void> _showInterstitialAd() async {
    if (_isInterstitialAdLoaded && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (InterstitialAd ad) {
          print('Ad showed full screen content.');
        },
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          print('Ad dismissed full screen content.');
          ad.dispose();
          // Load a new ad after the previous one is dismissed
          _loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          print('Ad failed to show full screen content. Error: ${error.message}');
          ad.dispose();
          // Load a new ad if the previous one failed to show
          _loadInterstitialAd();
        },
      );
      _interstitialAd!.show();
      setState(() {
        _isInterstitialAdLoaded = false;
      });
    } else {
      print('Interstitial ad not loaded yet');
      // Load ad if not already loaded
      _loadInterstitialAd();
    }
  }

  Future<void> _loadCalculations() async {
    setState(() => _isLoading = true);
    final calculations = await StorageService.getAllCalculations();
    setState(() {
      _calculations = calculations;
      _filteredCalculations = calculations;
      _isLoading = false;
    });
    _filterCalculations();
  }

  void _filterCalculations() {
    setState(() {
      _filteredCalculations = _calculations.where((calc) {
        // Search filter
        final searchQuery = _searchController.text.toLowerCase();
        final matchesSearch = searchQuery.isEmpty ||
            calc.title.toLowerCase().contains(searchQuery) ||
            calc.description.toLowerCase().contains(searchQuery) ||
            calc.id.toString().contains(searchQuery);

        // Date range filter
        final matchesDate = _selectedDateRange == null ||
            (calc.date.isAfter(
              _selectedDateRange!.start.subtract(const Duration(days: 1)),
            ) &&
                calc.date.isBefore(
                  _selectedDateRange!.end.add(const Duration(days: 1)),
                ));

        return matchesSearch && matchesDate;
      }).toList();
    });
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
      _filterCalculations();
    }
  }

  void _clearDateFilter() {
    setState(() {
      _selectedDateRange = null;
    });
    _filterCalculations();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
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
      // Show interstitial ad before deleting
      await _showInterstitialAd();
      
      // Delete the calculation
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
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search by name or number...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  border: InputBorder.none,
                ),
              )
            : Text(LanguageService.history),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          if (_isSearching)
            IconButton(icon: const Icon(Icons.close), onPressed: _clearSearch)
          else
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          IconButton(
            icon: Icon(
              _selectedDateRange != null
                  ? Icons.filter_alt
                  : Icons.filter_alt_outlined,
            ),
            onPressed: _selectDateRange,
          ),
        ],
      ),
      body: Column(
        children: [
          // Active filters display
          if (_selectedDateRange != null || _searchController.text.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  const Icon(Icons.filter_list, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (_selectedDateRange != null)
                          Chip(
                            label: Text(
                              '${DateFormat('dd/MM/yy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yy').format(_selectedDateRange!.end)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: _clearDateFilter,
                            backgroundColor: Colors.blue.shade100,
                          ),
                        if (_searchController.text.isNotEmpty)
                          Chip(
                            label: Text(
                              'Search: ${_searchController.text}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: _clearSearch,
                            backgroundColor: Colors.green.shade100,
                          ),
                      ],
                    ),
                  ),
                  Text(
                    '${_filteredCalculations.length} results',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          // Main content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCalculations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _calculations.isEmpty
                                  ? Icons.history
                                  : Icons.search_off,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _calculations.isEmpty
                                  ? LanguageService.noHistory
                                  : 'No results found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            if (_calculations.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  _clearSearch();
                                  _clearDateFilter();
                                },
                                child: const Text('Clear filters'),
                              ),
                            ],
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadCalculations,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredCalculations.length,
                          itemBuilder: (context, index) {
                            final calculation = _filteredCalculations[index];
                            return Card(
                              elevation: 3,
                              margin: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: () => _editCalculation(calculation),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          // Serial number badge
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              '#${index + 1}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
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
                                            icon: const Icon(Icons.edit,
                                                size: 20),
                                            onPressed: () =>
                                                _editCalculation(calculation),
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              size: 20,
                                            ),
                                            onPressed: () => _deleteCalculation(
                                                calculation.id),
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
                                            DateFormat('dd MMM yyyy, hh:mm a')
                                                .format(calculation.date),
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
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          children: [
                                            _buildResultRow(
                                              LanguageService.kochCopper,
                                              calculation.result.step2
                                                  .toStringAsFixed(0),
                                              Colors.green.shade700,
                                            ),
                                            const Divider(height: 16),
                                            _buildResultRow(
                                              LanguageService.gaalvaNear,
                                              calculation.result.step5
                                                  .toStringAsFixed(0),
                                              Colors.purple.shade700,
                                            ),
                                            const Divider(height: 16),
                                            _buildResultRow(
                                              LanguageService.numberCopper,
                                              calculation.result.step6
                                                  .toStringAsFixed(0),
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
          ),
        ],
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