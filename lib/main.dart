import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:blogapp/login.dart';
import 'package:blogapp/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: CustomTheme().getTheme(),
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
    var reuse = ReusableWidgets(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
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
  BuildContext context;

  ReusableWidgets(this.context);

  Widget createTextField(
      {required String labelText,
      TextEditingController? controller,
      bool isPassword = false}) {
    var theme = Theme.of(context);
    return SizedBox(
      width: 300,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
            labelText: labelText,
            labelStyle: TextStyle(color: theme.colorScheme.onBackground),
            floatingLabelStyle:
                TextStyle(color: theme.colorScheme.onBackground),
            isDense: true,
            enabledBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: theme.colorScheme.secondary, width: 2)),
            focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: theme.colorScheme.secondary, width: 2))),
        obscureText: isPassword,
      ),
    );
  }

  Widget createButton(
      {required String buttonText,
      required Function() onPressed,
      double width = 300,
      double height = 60,
      OutlinedBorder? shape,
      Color? buttonColor,
      Color? textColor}) {
    var theme = Theme.of(context);
    var textStyle = theme.textTheme.bodyLarge!.copyWith(
        color: (textColor != null) ? textColor : theme.colorScheme.onSecondary);

    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              (buttonColor != null) ? buttonColor : theme.colorScheme.secondary,
          fixedSize: Size(width, height),
          shape: (shape != null)
              ? shape
              : RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: onPressed,
        child: Text(buttonText, style: textStyle));
  }

  Widget createIconButton({Icon? icon, String? buttonText}) {
    return IconButton(
      onPressed: () {},
      icon: icon!,
    );
  }
}
