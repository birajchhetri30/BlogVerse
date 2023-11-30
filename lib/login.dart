// ignore_for_file: use_build_context_synchronously

import 'package:blogapp/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginControl {}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text('BlogVerse Login'),
          backgroundColor: theme.colorScheme.inversePrimary,
        ),
        body: loginPage(context));
  }

  Widget loginPage(BuildContext context) {
    var theme = Theme.of(context);
    var reuse = ReusableWidgets();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          reuse.createTextField(
              labelText: "Email", controller: emailController),
          const SizedBox(height: 20),
          reuse.createTextField(
              labelText: "Password",
              controller: passwordController,
              isPassword: true),
          const SizedBox(height: 20),
          reuse.createButton(buttonText: "Login", onPressed: loginAccount),
          const SizedBox(height: 30),
          reuse.createButton(
              buttonText: "Create account",
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => SignUp()));
              })
        ],
      ),
    );
  }

  void loginAccount() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Home()),
            (route) => false);
      }
    } on FirebaseAuthException catch (ex) {
      debugPrint(ex.code.toString());
    }
  }
}

class SignUp extends StatefulWidget {
  SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController fnameController = TextEditingController();

  final TextEditingController lnameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text("Create BlogVerse account"),
          backgroundColor: theme.colorScheme.inversePrimary,
        ),
        body: signUpPage(context));
  }

  Widget signUpPage(BuildContext context) {
    var reuse = ReusableWidgets();
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        reuse.createTextField(
            labelText: "First Name", controller: fnameController),
        const SizedBox(height: 20),
        reuse.createTextField(
            labelText: "Last Name", controller: lnameController),
        const SizedBox(height: 20),
        reuse.createTextField(labelText: "Email", controller: emailController),
        const SizedBox(height: 20),
        reuse.createTextField(
            labelText: "Password",
            controller: passwordController,
            isPassword: true),
        const SizedBox(height: 50),
        reuse.createButton(
            buttonText: "Create account", onPressed: createAccount)
      ],
    ));
  }

  void createAccount() async {
    String fname = fnameController.text.trim();
    String lname = lnameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      debugPrint('User created');

      if (userCredential.user != null) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (ex) {
      debugPrint(ex.code.toString());
    }
  }
}
