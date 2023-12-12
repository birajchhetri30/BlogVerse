import 'package:blogapp/drafts.dart';
import 'package:blogapp/follow.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provider/provider.dart';

import 'package:blogapp/main.dart';
import 'package:blogapp/current_user.dart';

import 'package:firebase_auth/firebase_auth.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  var currUser = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<CurrentUser>();
    var reuse = ReusableWidgets(context);

    var titleStyle = theme.textTheme.headlineLarge!
        .copyWith(color: theme.colorScheme.onPrimary);
    var textStyle = theme.textTheme.bodyLarge!;
    var numberStyle = theme.textTheme.headlineLarge!;

    return SafeArea(
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              title: Text("${CurrentUser.fname} ${CurrentUser.lname}",
                  style: titleStyle),
              expandedHeight: 80,
              floating: true,
              pinned: false,
              toolbarHeight: 80,
              stretch: false,
              backgroundColor: theme.colorScheme.background,
              surfaceTintColor: theme.colorScheme.background,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: reuse.createIconButton(
                      icon: const Icon(Icons.edit),
                      isSelected: false,
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Drafts()));
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: reuse.createIconButton(
                      icon: const Icon(Icons.logout),
                      isSelected: false,
                      onPressed: logoutAccount),
                )
              ],
            ),
            SliverAppBar(
              toolbarHeight: 100,
              expandedHeight: 100,
              backgroundColor: theme.colorScheme.background,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Follow()));
                    },
                    child: Column(
                      children: [
                        Text(appState.getFollowers(size: true).toString(),
                            style: numberStyle),
                        Text("Followers", style: textStyle),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Follow(
                                    followers: false,
                                  )));
                    },
                    child: Column(
                      children: [
                        Text(appState.getFollowing(size: true).toString(),
                            style: numberStyle),
                        Text("Following", style: textStyle),
                      ],
                    ),
                  )
                ],
              ),
              centerTitle: true,
            ),
            SliverAppBar(
              title: const Text("Your blogs"),
              backgroundColor: theme.colorScheme.background,
              surfaceTintColor: theme.colorScheme.background,
              pinned: true,
            )
          ];
        },
        body: Container(
          padding: const EdgeInsets.only(left: 0, right: 0),
          child: (appState.getBlogs().isNotEmpty)
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.only(bottom: 30),
                        children: [
                          for (var blog in appState.getBlogs())
                            reuse.createCard(
                                blog: blog,
                                isFeed: false,
                                onLiked: () {
                                  setState(() {
                                    appState.updateLikeCount(blog: blog);
                                  });
                                })
                        ],
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Text(
                  "No blogs\ncreated",
                  style: theme.textTheme.displaySmall!
                      .copyWith(color: theme.colorScheme.onBackground),
                  textAlign: TextAlign.center,
                )),
        ),
      ),
    );
  }

  void logoutAccount() async {
    var appState = Provider.of<CurrentUser>(context, listen: false);
    appState.reset();
    await FirebaseAuth.instance.signOut();
    Phoenix.rebirth(context);
  }
}
