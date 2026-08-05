import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme_model.dart';
import 'theme_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeModel(),
      child: const MyApp(),
    ),
  );
}

/// This is the root widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeModel.isDark
          ? ThemeData.dark()
          : ThemeData.light(),
      home: const MyHomePage(),
    );
  }
}

/// this demonstrates Ephemeral State using setState().
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/// Stores the counter locally.
class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  /// Increments the counter.
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ephemeral State Example"),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Text(
              "You have pushed the button this many times:",
            ),

            Text(
              "$_counter",
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            const SizedBox(height: 25),

            ElevatedButton(
              child: const Text("Go to Theme Settings"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ThemeScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: "Increment",
        child: const Icon(Icons.add),
      ),
    );
  }
}