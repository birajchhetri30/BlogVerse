import 'package:blogapp/account.dart';
import 'package:blogapp/current_user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Follow extends StatefulWidget {
  const Follow({super.key, this.followers = true});

  final bool followers;

  @override
  State<Follow> createState() => _FollowState();
}

class _FollowState extends State<Follow> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<CurrentUser>();

    String title = widget.followers ? "Followers" : "Following";
    var titleStyle = theme.textTheme.headlineLarge!
        .copyWith(color: theme.colorScheme.onPrimary);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: titleStyle,
        ),
        automaticallyImplyLeading: false,
        backgroundColor: theme.colorScheme.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 30),
        children: [
          for (var user in (widget.followers
              ? appState.getFollowers()
              : appState.getFollowing()))
            createUserCard(user: user)
        ],
      ),
    );
  }

  Widget createUserCard({required Map<String, dynamic> user}) {
    var theme = Theme.of(context);
    var titleStyle = theme.textTheme.headlineSmall!;

    return GestureDetector(
      onTap: () async {
        CurrentUser.fetchExtUserDetails(email: user['email']);
        await Future.delayed(Duration(seconds: 3));
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => Account(user: user)));
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
                "${user['fname']} ${user['lname']}",
                style: titleStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
