// ignore_for_file: use_build_context_synchronously

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:blogapp/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: (FirebaseAuth.instance.currentUser != null)
          ? const Home()
          : const Login(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    var reuse = ReusableWidgets();

    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Center(
          child: reuse.createButton(
              buttonText: "Sign out", onPressed: logoutAccount)),
    );
  }

  void logoutAccount() async {
    await FirebaseAuth.instance.signOut();
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const Login()));
  }
}

class ReusableWidgets {
  Widget createTextField(
      {required String labelText,
      TextEditingController? controller,
      bool isPassword = false}) {
    return SizedBox(
      width: 300,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: labelText, isDense: true),
        obscureText: isPassword,
      ),
    );
  }

  Widget createButton(
      {required String buttonText, required Function() onPressed}) {
    return ElevatedButton(onPressed: onPressed, child: Text(buttonText));
  }

  Widget createIconButton({Icon? icon, String? buttonText}) {
    return IconButton(
      onPressed: () {},
      icon: icon!,
    );
  }
}
