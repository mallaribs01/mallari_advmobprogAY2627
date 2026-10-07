import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/signup_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: 'assets/.env');

  // Initialize Firebase.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MallariAdvMobProg());
}

class MallariAdvMobProg extends StatelessWidget {
  const MallariAdvMobProg({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: ScreenUtilInit(
        designSize: const Size(412, 715),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Mallari Mall',

                themeMode: themeProvider.isDark
                    ? ThemeMode.dark
                    : ThemeMode.light,

                theme: ThemeData(
                  brightness: Brightness.light,
                  fontFamily: 'Poppins',
                  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
                  useMaterial3: true,
                ),

                darkTheme: ThemeData(
                  brightness: Brightness.dark,
                  fontFamily: 'Poppins',
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: Colors.blue,
                    brightness: Brightness.dark,
                  ),
                  useMaterial3: true,
                ),

                initialRoute: '/splash',

                routes: {
                  '/splash': (context) => const SplashScreen(),

                  '/signin': (context) => const SignInScreen(),

                  // NEW: Firebase Sign Up
                  '/signup': (context) => const SignUpScreen(),

                  '/home': (context) {
                    final arguments = ModalRoute.of(
                      context,
                    )?.settings.arguments;

                    Map<String, dynamic>? userData;

                    if (arguments is Map<String, dynamic>) {
                      userData = arguments;
                    }

                    return HomeScreen(userData: userData);
                  },

                  '/settings': (context) => const SettingsScreen(),
                },
              );
            },
          );
        },
      ),
    );
  }
}
