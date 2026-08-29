import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:mallari_mobprog/providers/theme_provider.dart';
import 'package:mallari_mobprog/screens/login_screen.dart';
import 'package:mallari_mobprog/screens/register_screen.dart';
import 'package:mallari_mobprog/screens/splash_screen.dart';

void main() {
  runApp(
    const FacebookReplication(),
  );
}

class FacebookReplication extends StatelessWidget {
  const FacebookReplication({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(412, 715),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          child: Consumer<ThemeProvider>(
            builder: (
              context,
              themeProvider,
              child,
            ) {
              return MaterialApp(
                color: Colors.white,
                debugShowCheckedModeBanner: false,
                title: 'Facebook Replication',

                theme: ThemeData(
                  brightness: Brightness.light,
                  scaffoldBackgroundColor:
                      Colors.white,
                  colorScheme:
                      ColorScheme.fromSeed(
                    seedColor: const Color.fromARGB(
                      255,
                      39,
                      100,
                      39,
                    ),
                  ),
                ),

                darkTheme: ThemeData(
                  brightness: Brightness.dark,
                  colorScheme:
                      ColorScheme.fromSeed(
                    seedColor: const Color.fromARGB(
                      255,
                      39,
                      100,
                      39,
                    ),
                    brightness: Brightness.dark,
                  ),
                ),

                themeMode: themeProvider.themeMode,

                initialRoute: '/splash',

                routes: {
                  '/login': (context) =>
                      const LogInScreen(),

                  '/register': (context) =>
                      const RegisterScreen(),

                  '/splash': (context) =>
                      const SplashScreen(),
                },
              );
            },
          ),
        );
      },
    );
  }
}