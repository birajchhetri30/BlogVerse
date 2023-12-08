import 'package:blogapp/current_user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewBlog extends StatelessWidget {
  const ViewBlog({super.key, required this.blog});

  final Map<String, dynamic> blog;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<CurrentUser>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.colorScheme.primary,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                automaticallyImplyLeading: false,
                expandedHeight: 250,
                toolbarHeight: 200,
                centerTitle: false,
                pinned: false,
                backgroundColor: theme.colorScheme.primary,
                flexibleSpace: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 300,
                      child: FlexibleSpaceBar(
                        title: createDisplayText(context,
                            content: blog['title'], isTitle: true),
                        centerTitle: false,
                        titlePadding: const EdgeInsets.all(20),
                        expandedTitleScale: 1.3,
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, bottom: 10),
                      child: Container(
                        padding: EdgeInsets.zero,
                        width: 38,
                        child: IconButton(
                            onPressed: () {
                              Map<String, dynamic> newBlog = {
                                'title': blog['title'],
                                'body': blog['body'],
                                'likes': blog['likes'] + 1
                              };
                              var email = (blog['email'] == null)
                                  ? CurrentUser.currUser?.email
                                  : blog['email'];
                              appState.updateLikeCount(blog: newBlog, email: email);
                            },
                            icon: Icon(Icons.favorite)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 23, right: 15),
                      child: Text(blog['likes'].toString()),
                    )
                  ],
                ),
              ),
            ];
          },
          body: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 20),
            child: Container(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  createDisplayText(context, content: blog['body'])
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget createDisplayText(BuildContext context,
      {required String content, isTitle = false}) {
    var theme = Theme.of(context);
    var titleStyle = theme.textTheme.headlineSmall!;
    var bodyStyle = theme.textTheme.bodyLarge!.copyWith(fontFamily: "Cambria");

    var textStyle = isTitle ? titleStyle : bodyStyle;

    return Text(
      content,
      style: textStyle,
    );
  }
}
