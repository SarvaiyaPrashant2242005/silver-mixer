import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  static String get bannerAdUnitId {
    if(Platform.isAndroid){
      // Use Google's test banner ad unit for development
      return 'ca-app-pub-3940256099942544/6300978111';
      
      // Replace with your production ad unit ID once ads are approved:
      // return 'ca-app-pub-2982666902258969/7519519092';
    }
    else if(Platform.isIOS){
      return 'ca-app-pub-3940256099942544/2934735716'; // Test ID for iOS
    }
    else{
      throw UnsupportedError('Platform not supported');
    }
  }

  static String get getIntertitialAdUnitId{
      if(Platform.isAndroid){
      // Use Google's test interstitial ad unit for development
      return 'ca-app-pub-3940256099942544/1033173712';
      
      // Replace with your production ad unit ID once ads are approved:
      // return 'ca-app-pub-2982666902258969/XXXXXXXXXX';
    }
    else if(Platform.isIOS){
      return 'ca-app-pub-3940256099942544/4411468910'; // Test ID for iOS
    }
    else{
      throw UnsupportedError('Platform not supported');
    }
  }
}