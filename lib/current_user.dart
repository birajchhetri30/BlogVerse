import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CurrentUser extends ChangeNotifier {
  static String fname = "";
  static String lname = "";
  static User? currUser;
  static int totalBlogs = 0;
  static List<Map<String, dynamic>> blogs = [];
  static List<Map<String, dynamic>> feedBlogs = [];

  static late DocumentSnapshot? userSnapshot;

  static void onStart() async {
    currUser = FirebaseAuth.instance.currentUser!;
    userSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(currUser?.email)
        .get();

    fname = userSnapshot!['fname'];
    lname = userSnapshot!['lname'];

    fetchFeedBlogs();
    fetchBlogs();
  }

  static void fetchBlogs() async {
    QuerySnapshot blogSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(currUser?.email)
        .collection("blogs")
        .get();

    for (var doc in blogSnapshot.docs) {
      Map<String, dynamic> blogMap = doc.data() as Map<String, dynamic>;
      blogs.add(blogMap);
    }
  }

  List<Map<String, dynamic>> getBlogs() {
    return blogs;
  }

  void addBlog(Map<String, dynamic> newBlog) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currUser?.email)
        .collection("blogs")
        .doc(newBlog['title'])
        .set(newBlog);
    blogs.add(newBlog);

    notifyListeners();
  }

  void updateBlog(Map<String, dynamic> newBlog) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currUser?.email)
        .collection("blogs")
        .doc(newBlog['title'])
        .update(newBlog);

    notifyListeners();
  }

  void updateLikeCount(Map<String, dynamic> blog, String email) async {
    if (email == currUser?.email) {
      for (var each in blogs) {
        if (each['title'] == blog['title']) {
          each['likes'] += 1;
        }
      }
    } else {
      for (var each in feedBlogs) {
        if (each['title'] == blog['title']) {
          each['likes'] += 1;
        }
      }
    }
    await FirebaseFirestore.instance
        .collection("users")
        .doc(email)
        .collection("blogs")
        .doc(blog['title'])
        .update(blog);
    debugPrint('Success');
    notifyListeners();
  }

  static void fetchFeedBlogs() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection("users").get();
    for (var doc in snapshot.docs) {
      if (doc.id != currUser?.email) {
        QuerySnapshot feedBlogSnapshot = await FirebaseFirestore.instance
            .collection("users")
            .doc(doc.id)
            .collection("blogs")
            .get();
        for (var blog in feedBlogSnapshot.docs) {
          Map<String, dynamic> blogMap = {
            'title': blog['title'],
            'body': blog['body'],
            'likes': blog['likes'],
            'email': doc.id,
            'author': doc['fname'] + doc['lname']
          };
          feedBlogs.add(blogMap);
        }
      }
    }
  }

  List<Map<String, dynamic>> getFeedBlogs() {
    return feedBlogs;
  }

  bool checkBlogExists(String newBlogTitle) {
    for (var each in blogs) {
      if (newBlogTitle == each['title']) {
        return true;
      }
    }
    return false;
  }

  void reset() {
    fname = "";
    lname = "";
    currUser = null;
    totalBlogs = 0;
    blogs = [];
    feedBlogs = [];
    userSnapshot = null;

    notifyListeners();
  }
}
