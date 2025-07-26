import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'pages/loginpage.dart';
import 'pages/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init(); // ✅ initialize GetStorage

  final box = GetStorage();
  final bool isLoggedIn = box.hasData('userEmail'); // ✅ check saved email

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Classic Digital Libraries',
      home: isLoggedIn ? const CDLApp() : const LoginPage(),
    );
  }
}
