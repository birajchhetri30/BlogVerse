import 'package:blogapp/current_user.dart';
import 'package:blogapp/main.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<CurrentUser>();
    var reuse = ReusableWidgets(context);

    var appTitleStyle =
        theme.textTheme.displaySmall!.copyWith(fontFamily: "Typographica");

    return Scaffold(
      appBar: AppBar(
        title: Text("BlogVerse", style: appTitleStyle),
        backgroundColor: theme.colorScheme.primary,
        toolbarHeight: 70,
      ),
      body: LiquidPullToRefresh(
        onRefresh: () async {
          appState.refresh;
        },
        showChildOpacityTransition: false,
        height: 70,
        color: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.background,
        animSpeedFactor: 2,
        child: ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 30),
          children: [
            for (var blog in appState.getFeedBlogs())
              reuse.createCard(
                  blog: blog,
                  onLiked: () {
                    setState(() {
                      appState.updateLikeCount(
                          blog: blog, email: blog['email']);
                    });
                  })
          ],
        ),
      ),
    );
  }
}
