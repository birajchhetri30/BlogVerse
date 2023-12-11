import 'package:blogapp/drafts.dart';
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

    var titleStyle = theme.textTheme.displayMedium!
        .copyWith(color: theme.colorScheme.onPrimary);

    return SafeArea(
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: false,
              toolbarHeight: 100,
              stretch: false,
              backgroundColor: theme.colorScheme.background,
              flexibleSpace: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 250,
                    child: FlexibleSpaceBar(
                      title:
                          Text("Hello ${CurrentUser.fname}", style: titleStyle),
                      centerTitle: false,
                      titlePadding:
                          const EdgeInsets.only(top: 20, bottom: 20, left: 20),
                      // stretchModes: const [StretchMode.fadeTitle],
                    ),
                  ),
                  const Spacer(),
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
            ),
            SliverPersistentHeader(
                delegate: CustomSliverDelegate(title: "Your blogs"),
                pinned: true),
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

class CustomSliverDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final double topSafeArea;
  final double maxExtent;

  CustomSliverDelegate({
    required this.title,
    this.maxExtent = 56,
    this.topSafeArea = 0,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    var theme = Theme.of(context);
    var textStyle = theme.textTheme.titleLarge!;

    return Theme(
      data: ThemeData.dark(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: maxExtent),
        child: Stack(
          children: [
            AppBar(
              title: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(title, style: textStyle),
              ),
              backgroundColor: theme.colorScheme.background,
              //surfaceTintColor: theme.colorScheme.primary,
              elevation: 0,
            ),
          ],
        ),
      ),
    );
  }

  @override
  OverScrollHeaderStretchConfiguration get stretchConfiguration =>
      OverScrollHeaderStretchConfiguration();

  @override
  double get minExtent => kToolbarHeight + topSafeArea;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
