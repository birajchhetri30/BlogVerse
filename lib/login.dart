// ignore_for_file: use_build_context_synchronously

import 'package:blogapp/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:blogapp/theme.dart';

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
        body: Container(
            color: theme.colorScheme.background,
            child: Padding(
              padding: const EdgeInsets.only(top: 20, left: 45.0, right: 45),
              child: loginPage(context),
            )));
  }

  Widget loginPage(BuildContext context) {
    var theme = Theme.of(context);
    var reuse = ReusableWidgets(context);

    var titleStyle = theme.textTheme.displayLarge!.copyWith(
        color: theme.colorScheme.onPrimary, fontFamily: 'Typographica');
    var textButtonStyle = theme.textTheme.bodyMedium!
        .copyWith(color: theme.colorScheme.secondary);

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "BlogVerse",
              style: titleStyle,
            ),
            const SizedBox(height: 60),
            reuse.createTextField(
                labelText: "Email", controller: emailController),
            const SizedBox(height: 20),
            reuse.createTextField(
                labelText: "Password",
                controller: passwordController,
                isPassword: true),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () {},
                    child: Text("Forgot password?", style: textButtonStyle)),
              ],
            ),
            const SizedBox(height: 30),
            reuse.createButton(buttonText: "Sign in", onPressed: loginAccount),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?"),
                TextButton(
                    style:
                        TextButton.styleFrom(padding: const EdgeInsets.all(1)),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => SignUp()));
                    },
                    child: Text("Sign up", style: textButtonStyle)),
              ],
            )
          ],
        ),
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      }
    } on FirebaseAuthException catch (ex) {
      debugPrint(ex.code.toString());
    }
  }
}

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController fnameController = TextEditingController();
  final TextEditingController lnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
        body: Container(
            color: theme.colorScheme.background,
            child: Padding(
              padding: const EdgeInsets.only(left: 45, right: 45),
              child: signUpPage(context),
            )));
  }

  Widget signUpPage(BuildContext context) {
    var theme = Theme.of(context);
    var reuse = ReusableWidgets(context);

    var titleStyle = theme.textTheme.displayLarge!
        .copyWith(color: theme.colorScheme.onPrimary, fontFamily: 'Banschrift');
    var textButtonStyle = theme.textTheme.bodyMedium!
        .copyWith(color: theme.colorScheme.secondary);

    return Center(
        child: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Sign up",
            style: titleStyle,
          ),
          SizedBox(height: 60),
          reuse.createTextField(
              labelText: "First Name", controller: fnameController),
          const SizedBox(height: 20),
          reuse.createTextField(
              labelText: "Last Name", controller: lnameController),
          const SizedBox(height: 20),
          reuse.createTextField(
              labelText: "Email", controller: emailController),
          const SizedBox(height: 20),
          reuse.createTextField(
              labelText: "Password",
              controller: passwordController,
              isPassword: true),
          const SizedBox(height: 20),
          reuse.createTextField(
              labelText: "Confirm password",
              controller: confirmPasswordController,
              isPassword: true),
          const SizedBox(height: 50),
          reuse.createButton(
              buttonText: "Create account", onPressed: createAccount)
        ],
      ),
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
