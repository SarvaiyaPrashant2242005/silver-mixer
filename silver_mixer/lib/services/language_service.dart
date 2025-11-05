import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { english, gujarati }

class LanguageService {
  static SharedPreferences? _prefs;
  static AppLanguage _currentLanguage = AppLanguage.gujarati;
  static final List<Function> _listeners = [];

  static const String _languageKey = 'app_language';

  static Future<void> init(SharedPreferences prefs) async {
    _prefs = prefs;
    final savedLanguage = _prefs?.getString(_languageKey);
    if (savedLanguage == 'english') {
      _currentLanguage = AppLanguage.english;
    } else {
      _currentLanguage = AppLanguage.gujarati;
    }
  }

  static AppLanguage get currentLanguage => _currentLanguage;

  static Future<void> setLanguage(AppLanguage language) async {
    _currentLanguage = language;
    await _prefs?.setString(
      _languageKey,
      language == AppLanguage.english ? 'english' : 'gujarati',
    );
    _notifyListeners();
  }

  static void addListener(Function listener) {
    _listeners.add(listener);
  }

  static void removeListener(Function listener) {
    _listeners.remove(listener);
  }

  static void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  // Translation strings
  static String get appTitle =>
      _currentLanguage == AppLanguage.english ? 'Silver Mixer' : 'સિલ્વર-મિક્સર';

  static String get calculation =>
      _currentLanguage == AppLanguage.english ? 'Mixer Number' : 'ગયણા નંબર';

  static String get serialNumber =>
      _currentLanguage == AppLanguage.english ? 'Sr. No.' : 'ક્રમ';

  static String get weight =>
      _currentLanguage == AppLanguage.english ? 'Weight' : 'ગાઈણા વજન';

  static String get touch =>
      _currentLanguage == AppLanguage.english ? 'Touch' : 'ટચ';

  static String get fine =>
      _currentLanguage == AppLanguage.english ? 'Fine' : 'ફાઈન';

  static String get meTouch =>
      _currentLanguage == AppLanguage.english ? 'Get Touch' : 'મે.ટચ';

  static String get coTouch =>
      _currentLanguage == AppLanguage.english ? 'Copper Touch' : 'કોપર ટચ';

  static String get gaTouch =>
      _currentLanguage == AppLanguage.english ? 'Mixer Touch' : 'ગાઈણા ટચ';

  static String get kochCopper =>
      _currentLanguage == AppLanguage.english ? 'raw copper' : 'કાચું કોપર';

  static String get silverFine =>
      _currentLanguage == AppLanguage.english ? 'Silver Fine' : 'ચાંદી ફાઈન';

  static String get gaalvaNear =>
      _currentLanguage == AppLanguage.english ? 'Mixer net weight' : 'ગાઈણા નેટ વજન';

  static String get gaTopna =>
      _currentLanguage == AppLanguage.english ? 'Mixer Total' : 'ગાઈણા ટોટલ';

  static String get numberCopper =>
      _currentLanguage == AppLanguage.english ? 'Net Copper' : 'નેટ કોપર';

  static String get title =>
      _currentLanguage == AppLanguage.english ? 'Title' : 'શીર્ષક';

  static String get description =>
      _currentLanguage == AppLanguage.english ? 'Description' : 'નોંધ';

  static String get save =>
      _currentLanguage == AppLanguage.english ? 'Save' : 'સેવ';

  static String get reset =>
      _currentLanguage == AppLanguage.english ? 'Reset' : 'રીસેટ';

  static String get history =>
      _currentLanguage == AppLanguage.english ? 'History' : 'હિસ્ટ્રી';

  static String get addEntry =>
      _currentLanguage == AppLanguage.english ? 'Add Entry' : 'એડ';

  static String get calculate =>
      _currentLanguage == AppLanguage.english ? 'Calculate' : 'ગણતરી કરો';

  static String get next =>
      _currentLanguage == AppLanguage.english ? 'Next' : 'આગળ';

  static String get back =>
      _currentLanguage == AppLanguage.english ? 'Back' : 'પાછળ';

  static String get date =>
      _currentLanguage == AppLanguage.english ? 'Date' : 'તારીખ';

  static String get noHistory =>
      _currentLanguage == AppLanguage.english
          ? 'No calculations yet'
          : 'હજુ સુધી કોઈ ગણતરી નથી';

  static String get deleteConfirm =>
      _currentLanguage == AppLanguage.english
          ? 'Delete this calculation?'
          : 'આ ગણતરી કાઢી નાખીએ?';

  static String get yes =>
      _currentLanguage == AppLanguage.english ? 'Yes' : 'હા';

  static String get no =>
      _currentLanguage == AppLanguage.english ? 'No' : 'ના';

  static String get cancel =>
      _currentLanguage == AppLanguage.english ? 'Cancel' : 'રદ';

  static String get delete =>
      _currentLanguage == AppLanguage.english ? 'Delete' : 'કાઢી નાખો';

  static String get edit =>
      _currentLanguage == AppLanguage.english ? 'Edit' : 'સંપાદિત';

  static String get enterValue =>
      _currentLanguage == AppLanguage.english ? 'Enter value' : 'મૂલ્ય દાખલ કરો';

  static String get fillAllFields =>
      _currentLanguage == AppLanguage.english
          ? 'Please fill all fields'
          : 'કૃપા કરીને બધા ક્ષેત્રો ભરો';

  static String get enterTitle =>
      _currentLanguage == AppLanguage.english
          ? 'Please enter a title'
          : 'કૃપા કરીને શીર્ષક દાખલ કરો';

  static String get calculationSaved =>
      _currentLanguage == AppLanguage.english
          ? 'Calculation saved successfully'
          : 'ગણતરી સફળતાપૂર્વક સાચવી';

  static String get language =>
      _currentLanguage == AppLanguage.english ? 'Language' : 'ભાષા';

  static String get selectLanguage =>
      _currentLanguage == AppLanguage.english ? 'Select Language' : 'ભાષા પસંદ કરો';
}