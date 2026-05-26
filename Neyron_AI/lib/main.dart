import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/app_state.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'games/ikki_qaror_game.dart';

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
    const bool openIkkiGame = bool.fromEnvironment('OPEN_IK_GAME', defaultValue: false);

    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'Neyron AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: openIkkiGame ? const IkkiQarorGameScreen() : const SplashScreen(),
      ),
    );
  }
}
