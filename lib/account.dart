import 'package:blogapp/current_user.dart';
import 'package:blogapp/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Account extends StatefulWidget {
  const Account({super.key, required this.user});

  final Map<String, dynamic> user;

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<CurrentUser>();
    var reuse = ReusableWidgets(context);

    var titleStyle = theme.textTheme.headlineLarge!
        .copyWith(color: theme.colorScheme.onPrimary);
    var textStyle = theme.textTheme.bodyLarge!;
    var numberStyle = theme.textTheme.headlineLarge!;

    Map<String, dynamic> userDetails = appState.getExtUserDetails();

    return Container(
      color: theme.colorScheme.background,
      child: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                  title: Text("${widget.user['fname']} ${widget.user['lname']}",
                      style: titleStyle),
                  expandedHeight: 80,
                  floating: true,
                  pinned: false,
                  toolbarHeight: 80,
                  stretch: false,
                  backgroundColor: theme.colorScheme.background,
                  surfaceTintColor: theme.colorScheme.background,
                  automaticallyImplyLeading: false,
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if (appState.isFollowing(
                                  email: widget.user['email'])) {
                                userDetails['followers'] -= 1;
                                appState.removeFollowing(
                                    email: widget.user['email']);
                              } else {
                                userDetails['followers'] += 1;
                                appState.addFollowing(widget.user);
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: !appState.isFollowing(
                                      email: widget.user['email'])
                                  ? theme.colorScheme.secondary
                                  : Colors.transparent,
                              side: !appState.isFollowing(
                                      email: widget.user['email'])
                                  ? null
                                  : BorderSide(
                                      color: theme.colorScheme.secondary)),
                          child: Text(
                            appState.isFollowing(email: widget.user['email'])
                                ? "Following"
                                : "Follow",
                            style:
                                TextStyle(color: theme.colorScheme.onSecondary),
                          )),
                    )
                  ]),
              SliverAppBar(
                toolbarHeight: 100,
                expandedHeight: 100,
                backgroundColor: theme.colorScheme.background,
                automaticallyImplyLeading: false,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Column(
                        children: [
                          Text(userDetails['followers'].toString(),
                              style: numberStyle),
                          Text("Followers", style: textStyle),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Column(
                        children: [
                          Text(userDetails['following'].toString(),
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
                title: Text("${widget.user['fname']}'s blogs"),
                backgroundColor: theme.colorScheme.background,
                surfaceTintColor: theme.colorScheme.background,
                pinned: true,
                automaticallyImplyLeading: false,
              )
            ];
          },
          body: Container(
            padding: const EdgeInsets.only(left: 0, right: 0),
            child: (userDetails['blogs'].isNotEmpty)
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.only(bottom: 30),
                          children: [
                            for (var blog
                                in appState.getExtUserDetails()['blogs'])
                              reuse.createCard(
                                  blog: blog,
                                  isFeed: false,
                                  onLiked: () {
                                    setState(() {
                                      appState.updateLikeCount(
                                          blog: blog, email: blog['email']);
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
      ),
    );
  }
}
