import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CurrentUser extends ChangeNotifier {
  static String fname = "";
  static String lname = "";
  static User? currUser;
  static int totalBlogs = 0;
  static List<Map<String, dynamic>> blogs = [];

  static late DocumentSnapshot? userSnapshot;

  static void onStart() async {
    currUser = FirebaseAuth.instance.currentUser!;
    userSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(currUser?.email)
        .get();

    fname = userSnapshot!['fname'];
    lname = userSnapshot!['lname'];

    fetchBlogs();
  }

  static void getDetails() async {
    //DocumentSnapshot
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

  void addBlog(Map<String, String> newBlog) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currUser?.email)
        .collection("blogs")
        .doc(newBlog['title'])
        .set(newBlog);
    blogs.add(newBlog);

    notifyListeners();
  }

  void updateBlog(Map<String, String> newBlog) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currUser?.email)
        .collection("blogs")
        .doc(newBlog['title'])
        .update(newBlog);

    notifyListeners();
  }

  void reset() {
    fname = "";
    lname = "";
    currUser = null;
    totalBlogs = 0;
    blogs = [];
    userSnapshot = null;

    notifyListeners();
  }
}
