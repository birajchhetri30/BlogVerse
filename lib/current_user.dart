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
  static List<String> likedBlogs = [];

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
    fetchLikedBlogs();
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
    debugPrint("new blogID: ${newBlog['id']}");
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currUser?.email)
        .collection("blogs")
        .doc(newBlog['id'])
        .set(newBlog);
    blogs.add(newBlog);

    notifyListeners();
  }

  void updateBlog(Map<String, dynamic> newBlog) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currUser?.email)
        .collection("blogs")
        .doc(newBlog['id'])
        .update(newBlog);

    notifyListeners();
  }

  void updateLikeCount({
    required Map<String, dynamic> blog,
    String? email = "",
  }) async {
    Map<String, dynamic> updateBlog = {};
    if (email == "") {
      email = currUser?.email;
      // current user's blog's likes
      for (var each in blogs) {
        if (each['title'] == blog['title']) {
          updateBlog = each;
          if (!likedBlogs.contains(blog['id'])) {
            each['likes'] += 1;
            likedBlogs.add(blog['id']);
          } else {
            each['likes'] -= 1;
            likedBlogs.remove(blog['id']);
          }
          break;
        }
      }
    } else {
      // other user's blog's likes
      for (var each in feedBlogs) {
        if (each['title'] == blog['title']) {
          updateBlog = each;
          if (!likedBlogs.contains(blog['id'])) {
            debugPrint('Blog id to add: ${blog['id']}');
            each['likes'] += 1;
            likedBlogs.add(blog['id']);
          } else {
            each['likes'] -= 1;
            likedBlogs.remove(blog['id']);
          }
          break;
        }
      }
    }

    debugPrint("Liked blogs: $likedBlogs");

    await FirebaseFirestore.instance
        .collection("users")
        .doc(email)
        .collection("blogs")
        .doc(blog['id'])
        .update(updateBlog);

    CollectionReference currLikedBlogs = FirebaseFirestore.instance
        .collection("users")
        .doc(currUser?.email)
        .collection("likedBlogs");

    QuerySnapshot currLikedBlogsSnapshot = await currLikedBlogs.get();

    for (var doc in currLikedBlogsSnapshot.docs) {
      doc.reference.delete();
    }

    for (var each in likedBlogs) {
      currLikedBlogs.doc(each).set({'title': each});
    }
    debugPrint('Success');
    notifyListeners();
  }

  bool blogIsLiked(String id) {
    if (likedBlogs.contains(id)) {
      return true;
    }
    return false;
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
            'id': blog['id'],
            'title': blog['title'],
            'body': blog['body'],
            'likes': blog['likes'],
            'email': doc.id,
            'author': doc['fname'] + " " + doc['lname']
          };
          feedBlogs.add(blogMap);
        }
      }
    }
  }

  List<Map<String, dynamic>> getFeedBlogs() {
    return feedBlogs;
  }

  static void fetchLikedBlogs() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(currUser?.email)
        .collection("likedBlogs")
        .get();

    for (var doc in snapshot.docs) {
      likedBlogs.add(doc['title']);
    }
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
    likedBlogs = [];
    userSnapshot = null;

    notifyListeners();
  }
}
