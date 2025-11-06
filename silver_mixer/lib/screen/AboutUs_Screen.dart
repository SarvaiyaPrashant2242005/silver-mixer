import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../services/language_service.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: -0.02, end: 0.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    try {
      final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);

      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      _showErrorSnackBar('Could not launch phone dialer: $e');
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    try {
      // Try direct WhatsApp URL first
      final Uri whatsappUri = Uri.parse('https://wa.me/91$phoneNumber');

      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      _showErrorSnackBar(
        'Could not open WhatsApp. Please ensure it is installed.',
      );
    }
  }

  Future<void> _openWebsite(String url) async {
    try {
      final Uri uri = Uri.parse(url);

      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      _showErrorSnackBar('Could not open website: $e');
    }
  }

  Future<void> _sendEmail(String email) async {
    try {
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: email,
        query: 'subject=Inquiry from Silver Mixer App',
      );

      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      // Fallback: Copy email to clipboard
      await Clipboard.setData(ClipboardData(text: email));
      _showSuccessSnackBar('Email address copied to clipboard');
    }
  }

  Future<void> _openGoogleMaps() async {
    try {
      // Coordinates for the address (you can get exact coordinates from Google Maps)
      // This is an approximate location for Rajkot, 150-ft Ring Road area
      const double latitude = 22.271447;
      const double longitude = 70.779615;

      // Try Google Maps URL with coordinates and place name
      final Uri googleMapsUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude&query_place_id=ChIJX8J51Y_P0zsRxMp3J8J7Jnc',
      );

      await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      // Fallback: Try with address string
      try {
        final Uri fallbackUri = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=205+Balaji+Hall+Complex+Mahapuja+Dham+Chowk+150ft+Ring+Road+Rajkot+360004',
        );
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      } catch (e) {
        _showErrorSnackBar('Could not open Google Maps');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildContactCard({
    required Widget icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color iconColor,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: icon),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LanguageService.currentLanguage == AppLanguage.english
              ? 'About Us'
              : 'અમારા વિશે',
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              Theme.of(context).colorScheme.background,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Animated Company Logo
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: Container(
                        width: 160,
                        height: 160,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/icons/company_logo_2.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              // Company Name
              Text(
                'AllySoft Solutions',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF757575),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                LanguageService.currentLanguage == AppLanguage.english
                    ? 'Your Technology Partner'
                    : 'તમારા ટેકનોલોજી પાર્ટનર',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // Contact Section Title
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  LanguageService.currentLanguage == AppLanguage.english
                      ? 'Get In Touch'
                      : 'સંપર્ક કરો',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF757575),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Contact Us Card
              _buildContactCard(
                icon: Icon(Icons.phone, color: Colors.blue, size: 26),

                title: LanguageService.currentLanguage == AppLanguage.english
                    ? 'Contact Us'
                    : 'ફોન કરો',
                subtitle: '88661 52292',
                onTap: () => _makePhoneCall('8866152292'),
                iconColor: Colors.blue,
              ),

              // WhatsApp Card
              _buildContactCard(
                icon: Image.asset(
                  'assets/icons/whatsapp.png',
                  width: 24,
                  height: 24,
                  // color: Colors.green, // optional if your icon is monochrome
                ),
                title: LanguageService.currentLanguage == AppLanguage.english
                    ? 'WhatsApp Us'
                    : 'વ્હોટ્સએપ કરો',
                subtitle: '88661 52292',
                onTap: () => _openWhatsApp('8866152292'),
                iconColor: Colors.green,
              ),

              // Website Card
              _buildContactCard(
                icon: Icon(Icons.web, color: Colors.orange, size: 26),
                title: LanguageService.currentLanguage == AppLanguage.english
                    ? 'Visit Us'
                    : 'વેબસાઇટ',
                subtitle: 'allysoftsolutions.com',
                onTap: () => _openWebsite('https://allysoftsolutions.com/'),
                iconColor: Colors.orange,
              ),

              // Email Card
              _buildContactCard(
                icon: Icon(Icons.email, color: Colors.red, size: 26),
                title: LanguageService.currentLanguage == AppLanguage.english
                    ? 'Email'
                    : 'ઈમેલ',
                subtitle: 'hr@allysoftsolutions.com',
                onTap: () => _sendEmail('hr@allysoftsolutions.com'),
                iconColor: Colors.red,
              ),

              const SizedBox(height: 30),

              // Address Section - Now Clickable
              InkWell(
                onTap: _openGoogleMaps,
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF757575), Color(0xFF9E9E9E)],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                LanguageService.currentLanguage ==
                                        AppLanguage.english
                                    ? 'Our Office'
                                    : 'અમારી ઓફિસ',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '205, Balaji Hall Complex,\nNr. Mahapuja Dham Chowk,\n150-ft Ring Road,\nRajkot - 360004',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.touch_app,
                            size: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            LanguageService.currentLanguage ==
                                    AppLanguage.english
                                ? 'Tap to open in Google Maps'
                                : 'Google Maps માં ખોલવા માટે ટેપ કરો',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Footer
              Text(
                LanguageService.currentLanguage == AppLanguage.english
                    ? 'Thank you for using our app!'
                    : 'અમારી એપ્લિકેશન વાપરવા બદલ આભાર!',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
