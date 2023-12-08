import 'package:blogapp/current_user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewBlog extends StatefulWidget {
  const ViewBlog({super.key, required this.blog});

  final Map<String, dynamic> blog;

  @override
  State<ViewBlog> createState() => _ViewBlogState();
}

class _ViewBlogState extends State<ViewBlog> {
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
                            content: widget.blog['title'], isTitle: true),
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
                              var email = (widget.blog['email'] == null)
                                  ? ""
                                  : widget.blog['email'];
                              setState(() {
                                appState.updateLikeCount(
                                    blog: widget.blog, email: email);
                              });
                            },
                            isSelected: appState.blogIsLiked(widget.blog['id']),
                            selectedIcon:
                                Icon(Icons.favorite, color: Colors.red),
                            icon: Icon(Icons.favorite_outline)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 23, right: 15),
                      child: Text(widget.blog['likes'].toString()),
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
                  createDisplayText(context,
                      content: (widget.blog['author'] != null)
                          ? "Written by ${widget.blog['author']}"
                          : "Written by ${CurrentUser.fname} ${CurrentUser.lname}",
                      isHint: true),
                  const SizedBox(height: 20),
                  createDisplayText(context, content: widget.blog['body'])
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget createDisplayText(BuildContext context,
      {required String content, isTitle = false, isHint = false}) {
    var theme = Theme.of(context);
    var titleStyle = theme.textTheme.headlineSmall!;
    var bodyStyle = theme.textTheme.bodyLarge!.copyWith(
        fontFamily: isHint ? null : "Cambria",
        fontStyle: isHint ? FontStyle.italic : null,
        color: isHint ? theme.colorScheme.onBackground : null);

    var textStyle = isTitle ? titleStyle : bodyStyle;

    return Text(
      content,
      style: textStyle,
    );
  }
}
