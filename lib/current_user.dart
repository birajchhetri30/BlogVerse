import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CurrentUser {
  static String fname = "";
  static String lname = "";
  static User currUser = FirebaseAuth.instance.currentUser!;
  static int totalBlogs = 0;
  static List<Map<String, dynamic>> blogs = [];

  static late DocumentSnapshot userSnapshot;

  static void onStart({required String fname, required String lname}) async {
    CurrentUser.fname = fname;
    CurrentUser.lname = lname;

    userSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(currUser.email)
        .get();

    getBlogs();
  }

  static void reset() {
    fname = "";
    lname = "";
  }

  static void getDetails() async {
    //DocumentSnapshot
  }

  static void getBlogs() async {
    QuerySnapshot blogSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(currUser.email)
        .collection("blogs")
        .get();

    for (var doc in blogSnapshot.docs) {
      Map<String, dynamic> blogMap = doc.data() as Map<String, dynamic>;
      blogs.add(blogMap);
    }
  }

  static void addBlog(Map<String, String> newBlog) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currUser.email)
        .collection("blogs")
        .doc(newBlog['title'])
        .set(newBlog);
    blogs.add(newBlog);
  }

  static void updateBlog(Map<String, String> newBlog) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currUser.email)
        .collection("blogs")
        .doc(newBlog['title'])
        .update(newBlog);
  }
}
