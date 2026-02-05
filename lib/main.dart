import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // تثبيت اتجاه الشاشة طولي فقط
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const AyahApp());
}

class AyahApp extends StatelessWidget {
  const AyahApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, fontFamily: 'Arial'),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String ayahText = "جاري تحميل الآية...";
  String ayahSource = "";
  Color primaryColor = const Color(0xFFFFB300);
  final ScreenshotController screenshotController = ScreenshotController();
  bool isSplash = true;

  @override
  void initState() {
    super.initState();
    _startApp();
  }

  Future<void> _startApp() async {
    await loadRandomAyah();
    // إظهار الشاشة الافتتاحية لمدة 3 ثوانٍ
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) setState(() => isSplash = false);
  }

  Future<void> loadRandomAyah() async {
    try {
      final String response = await rootBundle.loadString('quran.txt');
      final List<dynamic> data = json.decode(response);
      final surah = data[Random().nextInt(data.length)];
      final verse = surah['verses'][Random().nextInt(surah['verses'].length)];
      setState(() {
        ayahText = verse['text'];
        ayahSource = "سورة ${surah['name']} - آية ${verse['id']}";
      });
    } catch (e) {
      setState(() => ayahText = "تأكد من وجود ملف quran.txt");
    }
  }

  Future<void> saveImage() async {
    try {
      final Uint8List? image = await screenshotController.capture(
        pixelRatio: 3.0 // جودة عالية للحفظ
      );
      
      if (image != null) {
        // طلب صلاحية الوصول للاستوديو وحفظ الصورة
        await Gal.putImageBytes(image);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ تم حفظ الصورة في الاستوديو')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ فشل الحفظ: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isSplash) {
      return Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: Image.asset('fdss.png', fit: BoxFit.cover),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // الخلفية الرئيسية fds.png
          Container(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset('fds.png', fit: BoxFit.cover),
          ),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // المنطقة التي سيتم التقاطها كصورة
                Screenshot(
                  controller: screenshotController,
                  child: Container(
                    width: 330,
                    padding: const EdgeInsets.all(35),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.format_quote_rounded, color: primaryColor, size: 50),
                        const SizedBox(height: 10),
                        Text(
                          "﴿ $ayahText ﴾",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2D2D),
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          ayahSource,
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                // أزرار التحكم
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIconBtn(Icons.refresh_rounded, Colors.white, primaryColor, loadRandomAyah),
                    const SizedBox(width: 30),
                    _buildIconBtn(Icons.download_rounded, primaryColor, Colors.white, saveImage, isLarge: true),
                  ],
                ),
              ],
            ),
          ),

          // شريط تغيير الألوان العلوي
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _colorDot(const Color(0xFFFFB300)),
                _colorDot(const Color(0xFF2E7D32)),
                _colorDot(const Color(0xFF1565C0)),
                _colorDot(const Color(0xFFC62828)),
                _colorDot(Colors.black87),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorDot(Color color) => GestureDetector(
    onTap: () => setState(() => primaryColor = color),
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
    ),
  );

  Widget _buildIconBtn(IconData icon, Color bg, Color iconCol, VoidCallback action, {bool isLarge = false}) =>
    GestureDetector(
      onTap: action,
      child: Container(
        padding: EdgeInsets.all(isLarge ? 20 : 15),
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
        ),
        child: Icon(icon, color: iconCol, size: isLarge ? 35 : 28),
      ),
    );
}
