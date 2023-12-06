import 'package:flutter/material.dart';
import 'package:blogapp/main.dart';
import 'package:blogapp/feed.dart';
import 'package:blogapp/profile.dart';
import 'package:blogapp/notifications.dart';
import 'package:blogapp/search.dart';
import 'package:blogapp/create_blog.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.currPage});
  final dynamic currPage;

  @override
  State<Home> createState() => _HomeState(currPage: currPage);
}

class _HomeState extends State<Home> {
  _HomeState({required this.currPage});
  dynamic currPage;

  @override
  Widget build(BuildContext context) {
    var reuse = ReusableWidgets(context);
    var theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.background,
      child: Scaffold(
          body: currPage,
          floatingActionButton: SizedBox(
            width: 65,
            height: 65,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CreateBlog()));
              },
              shape: const CircleBorder(),
              elevation: 10,
              backgroundColor: theme.colorScheme.secondary,
              child: const Icon(Icons.add, size: 35),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomAppBar(
            color: theme.colorScheme.primary,
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                reuse.createIconButton(
                    icon: const Icon(Icons.home_rounded),
                    onPressed: () {
                      setState(() {
                        currPage = const Feed();
                      });
                    }),
                reuse.createIconButton(
                    icon: Icon(Icons.notifications),
                    onPressed: () {
                      setState(() {
                        currPage = Notifications();
                      });
                    }),
                const SizedBox(width: 50),
                reuse.createIconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      setState(() {
                        currPage = Search();
                      });
                    }),
                reuse.createIconButton(
                    icon: Icon(Icons.person),
                    onPressed: () {
                      setState(() {
                        currPage = Profile();
                      });
                    }),
              ],
            ),
          )),
    );
  }
}
