import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/app_state.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const NeyronAiApp());
}

class NeyronAiApp extends StatelessWidget {
  const NeyronAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      // Til o'zgarganda butun ilova qayta render bo'ladi (faqat languageCode'ga ulangan)
      child: Selector<AppState, String>(
        selector: (_, state) => state.languageCode,
        builder: (context, lang, child) => MaterialApp(
          title: 'Neyron AI',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
