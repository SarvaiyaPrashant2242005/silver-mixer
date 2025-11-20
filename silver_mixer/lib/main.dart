import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silver_mixer/screen/splash_screen.dart';
import 'package:silver_mixer/helper/ad_helper.dart';
import 'services/language_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  
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
  State createState() => _SilverMixerAppState();
}

class _SilverMixerAppState extends State {
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    LanguageService.addListener(_onLanguageChanged);
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('✓ Banner ad loaded successfully');
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('✗ Banner ad failed to load: ${error.message}');
          print('Error code: ${error.code}');
          ad.dispose();
          setState(() {
            _isAdLoaded = false;
          });
        },
        onAdOpened: (Ad ad) {
          print('Ad opened');
        },
        onAdClosed: (Ad ad) {
          print('Ad closed');
        },
        onAdImpression: (Ad ad) {
          print('Ad impression');
        },
      ),
    );
    _bannerAd.load();
  }

  @override
  void dispose() {
    LanguageService.removeListener(_onLanguageChanged);
    _bannerAd.dispose();
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
      builder: (context, child) {
        return Stack(
          children: [
            Column(
              children: [
                Expanded(child: child ?? const SizedBox.shrink()),
              ],
            ),
            if (_isAdLoaded)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SizedBox(
                  width: _bannerAd.size.width.toDouble(),
                  height: _bannerAd.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd),
                ),
              ),
          ],
        );
      },
      home: const SplashScreen(),
    );
  }
}