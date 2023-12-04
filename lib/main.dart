// ignore_for_file: use_build_context_synchronously

import 'package:blogapp/current_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:blogapp/login.dart';
import 'package:blogapp/theme.dart';
import 'package:blogapp/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // QuerySnapshot snapshot =
  //     await FirebaseFirestore.instance.collection("users").get();

  // for (var doc in snapshot.docs) {
  //   debugPrint("Id: ${doc.id}, Data: ${doc.data()}");
  // }

  if (FirebaseAuth.instance.currentUser != null) {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get();

    debugPrint("USer: ${snapshot.data()}");
    Map<String, dynamic> user = snapshot.data() as Map<String, dynamic>;
    CurrentUser.fname = user['fname'];
    CurrentUser.lname = user['lname'];
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var systemTheme = SystemUiOverlayStyle(
      systemNavigationBarColor: CustomTheme().getTheme().colorScheme.primary,
    );
    SystemChrome.setSystemUIOverlayStyle(systemTheme);
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

class ReusableWidgets {
  BuildContext context;

  ReusableWidgets(this.context);

  Widget createTextField(
      {required String labelText,
      TextEditingController? controller,
      bool isName = false,
      bool isEmail = false,
      bool isPassword = false}) {
    var theme = Theme.of(context);
    return SizedBox(
      width: 300,
      child: TextFormField(
        controller: controller,
        contextMenuBuilder: contextMenu,
        textCapitalization:
            isName ? TextCapitalization.words : TextCapitalization.none,
        keyboardType: (isEmail) ? TextInputType.emailAddress : null,
        cursorColor: theme.colorScheme.secondary,
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

  Widget createIconButton({required Icon icon, required Function() onPressed}) {
    var theme = Theme.of(context);
    var isSelected = false;
    return IconButton(
      onPressed: onPressed,
      icon: icon,
      isSelected: isSelected,
      selectedIcon: Icon(
        icon.icon,
        color: theme.colorScheme.secondary,
      ),
      iconSize: 35,
    );
  }

  ScaffoldFeatureController createSnackBar(BuildContext context,
      {required String content, bool isError = true}) {
    var theme = Theme.of(context);
    var textStyle =
        theme.textTheme.bodyLarge!.copyWith(color: theme.colorScheme.onError);

    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        content,
        style: textStyle,
        textAlign: TextAlign.center,
      ),
      backgroundColor:
          (isError) ? theme.colorScheme.error : theme.colorScheme.secondary,
      elevation: 2,
      duration: const Duration(seconds: 3),
    ));
  }

  Widget contextMenu(
      BuildContext context, EditableTextState editableTextState) {
    var theme = Theme.of(context);
    return AdaptiveTextSelectionToolbar(
        anchors: editableTextState.contextMenuAnchors,
        children: editableTextState.contextMenuButtonItems
            .map((ContextMenuButtonItem buttonItem) {
          return CupertinoButton(
            borderRadius: null,
            color: theme.colorScheme.primary,
            padding: const EdgeInsets.all(8),
            onPressed: buttonItem.onPressed,
            pressedOpacity: 0.5,
            child: SizedBox(
              width: 60,
              child: Text(
                CupertinoTextSelectionToolbarButton.getButtonLabel(
                    context, buttonItem),
                style: const TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }).toList());
  }
}
