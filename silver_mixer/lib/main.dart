import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silver_mixer/screen/splash_screen.dart';

import 'services/language_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  final prefs = await SharedPreferences.getInstance();
  await StorageService.init(prefs);
  await LanguageService.init(prefs);
  
  // Set portrait orientation only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const SilverMixerApp());
}

class SilverMixerApp extends StatefulWidget {
  const SilverMixerApp({Key? key}) : super(key: key);

  @override
  State<SilverMixerApp> createState() => _SilverMixerAppState();
}

class _SilverMixerAppState extends State<SilverMixerApp> {
  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Silver Mixer Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const SplashScreen(), // This should be your only home
    );
  }
}