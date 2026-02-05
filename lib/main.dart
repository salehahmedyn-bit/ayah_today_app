import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const AyahTodayApp());
}

class AyahTodayApp extends StatelessWidget {
  const AyahTodayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'آية اليوم',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const AyahScreen(),
    );
  }
}

class AyahScreen extends StatefulWidget {
  const AyahScreen({super.key});

  @override
  State<AyahScreen> createState() => _AyahScreenState();
}

class _AyahScreenState extends State<AyahScreen> {
  Color primaryColor = const Color(0xFFFFB300);
  String ayahText = "جاري التحميل...";
  String ayahSource = "...";
  List<dynamic> quranData = [];
  final ScreenshotController screenshotController = ScreenshotController();

  final List<Color> themeColors = [
    const Color(0xFFFFB300), const Color(0xFF2E7D32), const Color(0xFF0288D1),
    const Color(0xFF7B1FA2), const Color(0xFFC2185B), const Color(0xFF00796B),
    const Color(0xFFF57C00), const Color(0xFF303F9F), const Color(0xFF5D4037),
    const Color(0xFF212121),
  ];

  @override
  void initState() {
    super.initState();
    loadLocalQuran();
  }

  Future<void> loadLocalQuran() async {
    try {
      final String response = await rootBundle.loadString('quran.txt');
      final data = json.decode(response);
      setState(() {
        quranData = data;
        getRandomAyah();
      });
    } catch (e) {
      setState(() => ayahText = "خطأ في تحميل الملف");
    }
  }

  void getRandomAyah() {
    if (quranData.isEmpty) return;
    final random = Random();
    final surah = quranData[random.nextInt(quranData.length)];
    final verse = surah['verses'][random.nextInt(surah['verses'].length)];
    setState(() {
      ayahText = verse['text'];
      ayahSource = "سورة ${surah['name']} • آية ${verse['id']}";
    });
  }

  Future<void> captureAndSave() async {
    final Uint8List? image = await screenshotController.capture(
      delay: const Duration(milliseconds: 10),
      pixelRatio: 3.0,
    );
    if (image != null) {
      final directory = await getTemporaryDirectory();
      final imagePath = File('${directory.path}/ayah_today.png');
      await imagePath.writeAsBytes(image);
      await Share.shareXFiles([XFile(imagePath.path)], text: 'آية اليوم');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0F2F1), Color(0xFFE1F5FE), Color(0xFFE8EAF6), Color(0xFFFCE4EC)],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 50),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              width: 320,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: themeColors.map((color) => GestureDetector(
                  onTap: () => setState(() => primaryColor = color),
                  child: Container(
                    width: 14, height: 14,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.black12, width: 0.5)),
                  ),
                )).toList(),
              ),
            ),
            const Spacer(),
            Screenshot(
              controller: screenshotController,
              child: Container(
                padding: const EdgeInsets.all(20),
                color: Colors.transparent,
                child: Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 280,
                      padding: const EdgeInsets.only(top: 40, bottom: 25, left: 20, right: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 30, offset: const Offset(0, 10))],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RichText(
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            text: TextSpan(
                              children: [
                                TextSpan(text: "﴿ ", style: TextStyle(color: primaryColor, fontSize: 20, fontWeight: FontWeight.bold)),
                                TextSpan(text: ayahText, style: const TextStyle(color: Color(0xFF444444), fontSize: 17, fontWeight: FontWeight.bold, height: 1.6)),
                                TextSpan(text: " ﴾", style: TextStyle(color: primaryColor, fontSize: 20, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(ayahSource, style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.bold, opacity: 0.7)),
                        ],
                      ),
                    ),
                    Positioned(
                      top: -15,
                      child: Container(
                        width: 40, height: 35,
                        decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(10), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))]),
                        child: const Icon(FontAwesomeIcons.quoteRight, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: getRandomAyah,
                    child: Container(
                      width: 45, height: 45,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15)]),
                      child: Icon(FontAwesomeIcons.rotateRight, size: 16, color: primaryColor),
                    ),
                  ),
                  const SizedBox(width: 15),
                  GestureDetector(
                    onTap: captureAndSave,
                    child: Container(
                      width: 45, height: 45,
                      decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle, boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 15)]),
                      child: const Icon(FontAwesomeIcons.camera, size: 16, color: Colors.white),
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
