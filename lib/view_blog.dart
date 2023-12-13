import 'package:blogapp/account.dart';
import 'package:blogapp/current_user.dart';
import 'package:blogapp/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    var reuse = ReusableWidgets(context);

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
                                const Icon(Icons.favorite, color: Colors.red),
                            icon: const Icon(Icons.favorite_outline)),
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
            padding: const EdgeInsets.only(bottom: 20),
            child: Container(
              padding: const EdgeInsets.only(left: 20, right: 20),
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
                  createDisplayText(context, content: widget.blog['body']),
                  const SizedBox(height: 30),
                  Text(
                    "Posted on ${(DateFormat('dd MMMM yyyy, h:mm a').format((widget.blog['timestamp'] as Timestamp).toDate()))}",
                    style: TextStyle(color: theme.colorScheme.onBackground),
                  ),
                  const SizedBox(height: 30),
                  if (widget.blog['email'] != CurrentUser.currUser?.email)
                    GestureDetector(
                        onTap: () async {
                          showDialog<void>(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              return reuse.showLoaderDialog(
                                  loadingText: "Loading");
                            },
                          );
                          CurrentUser.fetchExtUserDetails(
                              email: widget.blog['email']);
                          var name =
                              widget.blog['author'].toString().split(" ");
                          Map<String, dynamic> user = {
                            'email': widget.blog['email'],
                            'fname': name[0],
                            'lname': name[1]
                          };
                          await Future.delayed(Duration(seconds: 3));
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Account(user: user)));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                                "Visit ${widget.blog['author'].toString().split(" ")[0]}'s profile",
                                style: theme.textTheme.bodyLarge!.copyWith(
                                    color: theme.colorScheme.onBackground)),
                          ],
                        ))
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
