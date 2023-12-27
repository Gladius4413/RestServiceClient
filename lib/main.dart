import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kp_restaurant/Providers/userProvider.dart';
import 'package:kp_restaurant/domain/user.dart';
import 'package:kp_restaurant/screens/login.dart';
import 'package:kp_restaurant/screens/register.dart';
import 'dart:io';

import 'package:provider/provider.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid ?  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: 'AIzaSyBF5kW0Uq5LB5vVekY0EDqFpDmvoTQLDqU',
        appId: '1:469253139701:android:ec885e3f70181b9f0369bc',
        messagingSenderId: '469253139701',
        projectId: 'restaurant-dev-ea12b'

    )
  ) : await Firebase.initializeApp() ;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()), // Провайдер для пользователя
        // Другие провайдеры, если есть
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: LoginPage()
    );

  }
}

