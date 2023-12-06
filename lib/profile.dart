import 'package:flutter/material.dart';
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
    var textStyle = theme.textTheme.titleLarge!;
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            expandedHeight: 250,
            floating: false,
            pinned: true,
            toolbarHeight: 80,
            stretch: false,
            backgroundColor: theme.colorScheme.background,
            surfaceTintColor: theme.colorScheme.background,
            flexibleSpace: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: 300,
                  child: FlexibleSpaceBar(
                    title:
                        Text("Hello ${CurrentUser.fname}", style: titleStyle),
                    centerTitle: false,
                    titlePadding: const EdgeInsets.all(20),
                    //stretchModes: const [StretchMode.fadeTitle],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: reuse.createIconButton(
                      icon: Icon(Icons.logout), onPressed: logoutAccount),
                )
              ],
            ),
          ),
          SliverAppBar(
            title: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text("Your blogs", style: textStyle),
            ),
            centerTitle: false,
            pinned: true,
            backgroundColor: theme.colorScheme.background,
            surfaceTintColor: theme.colorScheme.background,
            toolbarHeight: 50,
          )
        ];
      },
      body: Container(
        color: theme.colorScheme.background,
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                children: [
                  for (var blog in appState.getBlogs())
                    reuse.createCard(blog: blog)
                ],
              ),
            ),
          ],
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

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._text);

  final Text _text;

  @override
  double get minExtent => 31;

  @override
  double get maxExtent => 31;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    var theme = Theme.of(context);
    return SizedBox(
      height: 50,
      child: Container(
        color: theme.colorScheme.background,
        child: Padding(
          padding: const EdgeInsets.only(left: 25),
          child: _text,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
