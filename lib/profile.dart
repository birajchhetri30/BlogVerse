import 'package:blogapp/main.dart';
import 'package:blogapp/login.dart';
import 'package:flutter/material.dart';
import 'package:blogapp/current_user.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:convert';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  var currUser = FirebaseAuth.instance.currentUser!;
  Map<String, dynamic> user = {};

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var reuse = ReusableWidgets(context);

    var titleStyle = theme.textTheme.displayMedium!
        .copyWith(color: theme.colorScheme.onBackground);
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 250,
              floating: true,
              pinned: true,
              toolbarHeight: 100,
              stretch: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text("Hello ${CurrentUser.fname}", style: titleStyle),
                centerTitle: false,
                titlePadding: EdgeInsets.all(20),
                stretchModes: [StretchMode.fadeTitle],
              ),
              //onStretchTrigger: () {},
              backgroundColor: theme.colorScheme.background,
              //surfaceTintColor: theme.colorScheme.onBackground,
            )
          ];
        },
        body: Center(
            child: reuse.createButton(
                buttonText: "Sign out", onPressed: logoutAccount)),
      ),
    );
  }

  void logoutAccount() async {
    CurrentUser.fname = "";
    CurrentUser.lname = "";
    await FirebaseAuth.instance.signOut();
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const Login()));
  }
}
