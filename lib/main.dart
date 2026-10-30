import 'package:flutter/material.dart';
import 'presentation/tanda_screen.dart';

void main() => runApp(const TandaApp());

class TandaApp extends StatelessWidget {
  const TandaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tanda Doloreña',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const TandaScreen(),
    );
  }
}
