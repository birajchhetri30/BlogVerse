import 'package:blogapp/current_user.dart';
import 'package:blogapp/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Drafts extends StatefulWidget {
  const Drafts({super.key});

  @override
  State<Drafts> createState() => _DraftsState();
}

class _DraftsState extends State<Drafts> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<CurrentUser>();
    var reuse = ReusableWidgets(context);

    var textStyle = theme.textTheme.titleLarge!;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.colorScheme.primary,
        title: Text(
          "Your drafts",
          style: textStyle,
        ),
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 0, right: 0),
        child: (appState.getDrafts().isNotEmpty)
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 30),
                      children: [
                        for (var draft in appState.getDrafts())
                          reuse.createCard(
                              blog: draft,
                              isFeed: false,
                              isDraft: true,
                              onLiked: () {})
                      ],
                    ),
                  ),
                ],
              )
            : Center(
                child: Text(
                "No drafts",
                style: theme.textTheme.displaySmall!
                    .copyWith(color: theme.colorScheme.onBackground),
                textAlign: TextAlign.center,
              )),
      ),
    );
  }
}
