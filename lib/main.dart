import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenebris/widgets/Landing.dart';
import 'package:tenebris/providers/app_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tenebris/firebase_options.dart';
import 'package:tenebris/services/notification_service.dart';

void main() async { 
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) { 
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark, 
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const Landing(),    
    );
  }
}
