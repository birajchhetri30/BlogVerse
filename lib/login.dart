// ignore_for_file: use_build_context_synchronously

import 'package:blogapp/feed.dart';
import 'package:blogapp/main.dart';
import 'package:blogapp/home.dart';
import 'package:blogapp/current_user.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
                labelText: "Email", controller: emailController, isEmail: true),
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
    var reuse = ReusableWidgets(context);

    if (email.isEmpty || password.isEmpty) {
      reuse.createSnackBar(context, content: "Please fill all the fields");
    } else {
      try {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return reuse.showLoaderDialog(loadingText: "Signing in");
            });

        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        if (userCredential.user != null) {
          CurrentUser.onStart();
          await Future.delayed(const Duration(seconds: 3));
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => const Home(currPage: Feed())),
            (route) => false,
          );
        }
      } on FirebaseAuthException catch (ex) {
        var error = ex.code.toString();

        if (error == "invalid-email") {
          reuse.createSnackBar(context,
              content: "Please enter a valid email address");
        } else if (error == "user-not-found") {
          reuse.createSnackBar(context,
              content: "Entered email is not regestered");
        } else if (error == "invalid-credential") {
          reuse.createSnackBar(context, content: "Incorrect email/password");
        }
        debugPrint(ex.code.toString());
      }
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
          const SizedBox(height: 60),
          reuse.createTextField(
              labelText: "First Name",
              controller: fnameController,
              isName: true),
          const SizedBox(height: 20),
          reuse.createTextField(
              labelText: "Last Name",
              controller: lnameController,
              isName: true),
          const SizedBox(height: 20),
          reuse.createTextField(
              labelText: "Email", controller: emailController, isEmail: true),
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
              buttonText: "Create account", onPressed: createAccount),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Already have an account?"),
              TextButton(
                  style: TextButton.styleFrom(padding: const EdgeInsets.all(1)),
                  onPressed: () {
                    Navigator.pop(context,
                        MaterialPageRoute(builder: (context) => const Login()));
                  },
                  child: Text("Sign in", style: textButtonStyle)),
            ],
          )
        ],
      ),
    ));
  }

  void createAccount() async {
    String fname = fnameController.text.trim();
    String lname = lnameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    var reuse = ReusableWidgets(context);

    if (fname.isEmpty ||
        lname.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      reuse.createSnackBar(context, content: "Please fill all the fields");
    } else if (password != confirmPassword) {
      reuse.createSnackBar(context, content: "Passwords do not match");
    } else {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return reuse.showLoaderDialog(loadingText: "Creating account");
          },
        );

        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        debugPrint('User created');

        await Future.delayed(const Duration(seconds: 2));

        if (userCredential.user != null) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Login()),
              (route) => false);
        }

        Map<String, dynamic> newUser = {'fname': fname, 'lname': lname};
        FirebaseFirestore.instance.collection("users").doc(email).set(newUser);
      } on FirebaseAuthException catch (ex) {
        var error = ex.code.toString();
        if (error == "email-already-in-use") {
          reuse.createSnackBar(context,
              content: "Entered email is already in use");
        } else if (error == "invalid-email") {
          reuse.createSnackBar(context,
              content: "Please enter a valid email address");
        } else if (error == "weak-password") {
          reuse.createSnackBar(context,
              content: "Password must be at least 6 characters long");
        }
        debugPrint(ex.code.toString());
      }
    }
  }
}
