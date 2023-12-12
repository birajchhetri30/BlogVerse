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
  static List<Map<String, dynamic>> drafts = [];
  static List<String> likedBlogs = [];
  static List<Map<String, dynamic>> followers = [];
  static List<Map<String, dynamic>> following = [];
  static Map<String, dynamic> extUser = {};

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
    fetchFollowers();
    fetchFollowing();
    fetchDrafts();
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

  bool checkBlogExists(String newBlogTitle) {
    for (var each in blogs) {
      if (newBlogTitle == each['title']) {
        return true;
      }
    }
    return false;
  }

  void saveDraft(Map<String, dynamic> draft) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currUser?.email)
        .collection("drafts")
        .doc(draft['id'])
        .set(draft);
    drafts.add(draft);

    notifyListeners();
  }

  static void fetchDrafts() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(currUser?.email)
        .collection("drafts")
        .get();

    for (var doc in snapshot.docs) {
      Map<String, dynamic> draft = doc.data() as Map<String, dynamic>;
      drafts.add(draft);
    }
  }

  void removeDraft(String draftTitle) async {
    for (var draft in drafts) {
      if (draft['title'] == draftTitle) {
        drafts.remove(draft);
        break;
      }
    }
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(currUser?.email)
        .collection("drafts")
        .get();

    for (var doc in snapshot.docs) {
      if (doc['title'] == draftTitle) {
        doc.reference.delete();
        break;
      }
    }
    notifyListeners();
  }

  List<Map<String, dynamic>> getDrafts() {
    return drafts;
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

  static Future<void> fetchFeedBlogs() async {
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
            'email': blog['email'],
            'author': blog['author']
          };
          feedBlogs.add(blogMap);
        }
      }
    }
  }

  List<Map<String, dynamic>> getFeedBlogs() {
    return feedBlogs;
  }

  void addFollowing(Map<String, dynamic> acc) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currUser?.email)
        .collection("following")
        .doc(acc['email'])
        .set(acc);
    following.add(acc);

    Map<String, dynamic> currUserMap = {
      'email': currUser?.email,
      'fname': fname,
      'lname': lname
    };
    await FirebaseFirestore.instance
        .collection("users")
        .doc(acc['email'])
        .collection("followers")
        .doc(currUser?.email)
        .set(currUserMap);

    notifyListeners();
  }

  void removeFollowing({required String email}) async {
    for (var acc in following) {
      if (acc['email'] == email) {
        following.remove(acc);
        break;
      }
    }

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(currUser?.email)
        .collection("following")
        .get();

    for (var doc in snapshot.docs) {
      if (doc['email'] == email) {
        doc.reference.delete();
        break;
      }
    }

    snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(email)
        .collection("followers")
        .get();

    for (var doc in snapshot.docs) {
      if (doc['email'] == currUser?.email) {
        doc.reference.delete();
        break;
      }
    }
  }

  static void fetchFollowers() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(currUser?.email)
        .collection("followers")
        .get();

    for (var doc in snapshot.docs) {
      Map<String, dynamic> acc = doc.data() as Map<String, dynamic>;
      followers.add(acc);
    }
  }

  static void fetchFollowing() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(currUser?.email)
        .collection("following")
        .get();

    for (var doc in snapshot.docs) {
      Map<String, dynamic> acc = doc.data() as Map<String, dynamic>;
      following.add(acc);
    }
  }

  dynamic getFollowers({bool size = false}) {
    if (size) {
      return followers.length;
    }
    return followers;
  }

  dynamic getFollowing({bool size = false}) {
    if (size) {
      return following.length;
    }
    return following;
  }

  bool isFollowing({required String email}) {
    for (var user in following) {
      if (user['email'] == email) {
        return true;
      }
    }
    return false;
  }

  static void fetchExtUserDetails({required String email}) async {
    DocumentReference user =
        FirebaseFirestore.instance.collection("users").doc(email);

    QuerySnapshot followerSnapshot = await user.collection("followers").get();
    int followerCount = followerSnapshot.size;

    QuerySnapshot followingSnapshot = await user.collection("following").get();
    int followingCount = followingSnapshot.size;

    List<Map<String, dynamic>> userBlogs = [];
    QuerySnapshot snapshot = await user.collection("blogs").get();

    for (var doc in snapshot.docs) {
      Map<String, dynamic> blog = doc.data() as Map<String, dynamic>;
      userBlogs.add(blog);
    }

    extUser = {
      'followers': followerCount,
      'following': followingCount,
      'blogs': userBlogs
    };
  }

  Map<String, dynamic> getExtUserDetails() {
    return extUser;
  }

  Future<void> refresh() async {
    feedBlogs = [];
    await fetchFeedBlogs();
    blogs = [];
    fetchBlogs();
    debugPrint("Feed blogs: $feedBlogs");
    notifyListeners();
  }

  void reset() {
    fname = "";
    lname = "";
    currUser = null;
    totalBlogs = 0;
    blogs = [];
    feedBlogs = [];
    likedBlogs = [];
    drafts = [];
    userSnapshot = null;
    followers = [];
    following = [];

    notifyListeners();
  }
}
