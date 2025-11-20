  import 'package:flutter/material.dart';
  import 'package:intl/intl.dart';
  import 'package:silver_mixer/screen/AboutUs_Screen.dart';
  import 'package:silver_mixer/screen/EntryInputScreen.dart';

  import '../controller/calculation_controller.dart';
  import '../services/language_service.dart';
  import 'history_screen.dart';

  class HomeScreen extends StatefulWidget {
    const HomeScreen({Key? key}) : super(key: key);

    @override
    State<HomeScreen> createState() => _HomeScreenState();
  }

  class _HomeScreenState extends State<HomeScreen> {
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

    void _showLanguageDialog() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(LanguageService.selectLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<AppLanguage>(
                title: const Text('English'),
                value: AppLanguage.english,
                groupValue: LanguageService.currentLanguage,
                onChanged: (value) {
                  if (value != null) {
                    LanguageService.setLanguage(value);
                    Navigator.pop(context);
                  }
                },
              ),
              RadioListTile<AppLanguage>(
                title: const Text('ગુજરાતી'),
                value: AppLanguage.gujarati,
                groupValue: LanguageService.currentLanguage,
                onChanged: (value) {
                  if (value != null) {
                    LanguageService.setLanguage(value);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      final today = DateFormat('dd-MM-yyyy').format(DateTime.now());
      final screenHeight = MediaQuery.of(context).size.height;
      final appBarHeight = AppBar().preferredSize.height;
      final statusBarHeight = MediaQuery.of(context).padding.top;
      final availableHeight = screenHeight - appBarHeight - statusBarHeight;

      return Scaffold(
        appBar: AppBar(
          title: Text(LanguageService.appTitle),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          actions: [
            IconButton(
              icon: const Icon(Icons.language),
              onPressed: _showLanguageDialog,
            ),
          ],
        ),
        body: SizedBox(
          height: availableHeight,
          child: Stack(
            children: [
              // Main Content - Full Screen
              Positioned.fill(
                child: Container(
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
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: availableHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 20),
                                    
                                    // App Logo
                                    Container(
                                      width: 180,
                                      height: 180,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            const Color(0xFFB8B8B8),
                                            const Color(0xFF909090),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(35),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.3),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10),
                                          ),
                                          BoxShadow(
                                            color: const Color(0xFFD4915D).withOpacity(0.2),
                                            blurRadius: 15,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(35),
                                        child: Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Image.asset(
                                            'assets/icons/app_icon.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 30),

                                    // Title
                                    Text(
                                      LanguageService.appTitle,
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF757575),
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    // Date
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE0E0E0),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.calendar_today,
                                            size: 16,
                                            color: Color(0xFF757575),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${LanguageService.date}: $today',
                                            style: const TextStyle(
                                              color: Color(0xFF757575),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 50),

                                    // Start Button
                                    ElevatedButton(
                                      onPressed: () {
                                        final controller = CalculationController();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EntryInputScreen(controller: controller),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context).colorScheme.primary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 50,
                                          vertical: 18,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        elevation: 5,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.add_circle_outline, size: 24),
                                          const SizedBox(width: 12),
                                          Text(
                                            LanguageService.currentLanguage == AppLanguage.english
                                                ? 'New Calculation'
                                                : 'નવી ગણતરી',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    // History Button
                                    OutlinedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const HistoryScreen(),
                                          ),
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Theme.of(context).colorScheme.primary,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 50,
                                          vertical: 18,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        side: BorderSide(
                                          color: Theme.of(context).colorScheme.primary,
                                          width: 2,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.history, size: 24),
                                          const SizedBox(width: 12),
                                          Text(
                                            LanguageService.history,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ),
                            
                            // Spacer for bottom wave - increased
                            const SizedBox(height: 200),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Wave Section with Company Info - Moved higher and larger logo
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutUsScreen(),
                      ),
                    );
                  },
                  child: CustomPaint(
                    size: Size(MediaQuery.of(context).size.width, 200),
                    painter: WavePainter(),
                    child: Container(
                      height: 200,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(top: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Text(
                          //   LanguageService.currentLanguage == AppLanguage.english
                          //       ? 'Developed by'
                          //       : 'વિકસિત કરનાર',
                          //   style: TextStyle(
                          //     fontSize: 14,
                          //     color: Colors.white.withOpacity(0.9),
                          //     fontWeight: FontWeight.w500,
                          //   ),
                          // ),
                          // const SizedBox(height: 1),
                          Container(
                            width: 160,
                            height: 70,
                            padding: const EdgeInsets.all(12),
                            // decoration: BoxDecoration(
                            //   borderRadius: BorderRadius.circular(15),
                            //   // boxShadow: [
                            //   //   BoxShadow(
                            //   //     color: Colors.black.withOpacity(0.15),
                            //   //     blurRadius: 12,
                            //   //     offset: const Offset(0, 4),
                            //   //   ),
                            //   // ],
                            // ),
                            child: Image.asset(
                              'assets/icons/company_logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          // const SizedBox(height: 1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                LanguageService.currentLanguage == AppLanguage.english
                                    ? 'Tap to know more'
                                    : 'વધુ જાણવા માટે ટેપ કરો',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.85),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.touch_app,
                                size: 14,
                                color: Colors.white.withOpacity(0.85),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  // Custom Wave Painter for Bottom Section
  class WavePainter extends CustomPainter {
    @override
    void paint(Canvas canvas, Size size) {
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF757575),
            Color(0xFF9E9E9E),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill;

      final path = Path();
      
      // Start from bottom left
      path.lineTo(0, size.height);
      
      // Draw bottom line
      path.lineTo(size.width, size.height);
      
      // Draw right side up
      path.lineTo(size.width, size.height * 0.35);
      
      // Create wave curve
      path.quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.1,
        size.width * 0.5,
        size.height * 0.25,
      );
      
      path.quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.4,
        0,
        size.height * 0.35,
      );
      
      path.close();

      canvas.drawPath(path, paint);
      
      // Add shadow effect
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      
      canvas.drawPath(path, shadowPaint);
    }

    @override
    bool shouldRepaint(CustomPainter oldDelegate) => false;
  }