// ignore_for_file: use_build_context_synchronously

import 'package:blogapp/create_blog.dart';
import 'package:blogapp/feed.dart';
import 'package:blogapp/view_blog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:blogapp/current_user.dart';
import 'package:blogapp/login.dart';
import 'package:blogapp/theme.dart';
import 'package:blogapp/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (FirebaseAuth.instance.currentUser != null) {
    CurrentUser.onStart();
    await Future.delayed(const Duration(seconds: 3));
  }

  // QuerySnapshot snapshot =
  //     await FirebaseFirestore.instance.collection("users").get();

  // for (var doc in snapshot.docs) {
  //   debugPrint("Id: ${doc.id}, Data: ${doc.data()}");
  // }
  runApp(Phoenix(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var systemTheme = SystemUiOverlayStyle(
      systemNavigationBarColor: CustomTheme().getTheme().colorScheme.primary,
    );
    SystemChrome.setSystemUIOverlayStyle(systemTheme);
    return ChangeNotifierProvider(
      create: (context) => CurrentUser(),
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: CustomTheme().getTheme(),
        home: (FirebaseAuth.instance.currentUser != null)
            ? const Home(currPage: Feed())
            : const Login(),
      ),
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

  Widget createIconButton(
      {required Icon icon,
      required bool isSelected,
      required Function() onPressed}) {
    var theme = Theme.of(context);
    return IconButton(
      onPressed: onPressed,
      icon: icon,
      isSelected: isSelected,
      selectedIcon: Icon(icon.icon, color: theme.colorScheme.secondary),
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

  Widget createCard(
      {required Map<String, dynamic> blog,
      required void Function() onLiked,
      bool isFeed = true,
      bool isDraft = false}) {
    var theme = Theme.of(context);
    var appState = context.watch<CurrentUser>();

    var titleStyle = theme.textTheme.headlineMedium!;
    var bodyStyle = theme.textTheme.bodyLarge!.copyWith(fontFamily: 'Cambria');
    int shortBlog = blog['body']!.toString().indexOf(".");

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => isDraft
                    ? CreateBlog(
                        initialTitle: blog['title'], initialBody: blog['body'])
                    : ViewBlog(blog: blog)));
      },
      child: Card(
        color: theme.colorScheme.primary,
        elevation: 5,
        margin: const EdgeInsets.all(10),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                blog['title']!,
                style: titleStyle,
              ),
              const SizedBox(height: 10),
              Container(
                  constraints: const BoxConstraints(maxHeight: 50),
                  child: Text(
                    blog['body'].toString().substring(0, shortBlog + 1),
                    style: bodyStyle,
                  )),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Read more',
                style:
                    bodyStyle.copyWith(color: theme.colorScheme.onBackground),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (!isDraft)
                    Container(
                      padding: EdgeInsets.zero,
                      width: 40,
                      child: IconButton(
                        onPressed: onLiked,
                        icon: const Icon(Icons.favorite_outline),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        isSelected: appState.blogIsLiked(blog['id']),
                        selectedIcon:
                            const Icon(Icons.favorite, color: Colors.red),
                        style: IconButton.styleFrom(),
                      ),
                    ),
                  if (!isDraft)
                    Text(
                      blog['likes'].toString(),
                      style: theme.textTheme.bodyMedium!,
                    ),
                  const Spacer(),
                  if (blog['author'] != null && isFeed)
                    Text("${blog['author']}")
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget showLoaderDialog({required String loadingText}) {
    var theme = Theme.of(context);

    return Dialog(
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        shape: RoundedRectangleBorder(
            side: BorderSide(color: theme.colorScheme.onPrimary),
            borderRadius: BorderRadius.circular(10)),
        child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: theme.colorScheme.onPrimary,
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  loadingText,
                  style: TextStyle(color: theme.colorScheme.onPrimary),
                )
              ],
            )));
  }
}
