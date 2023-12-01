import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateBlog extends StatefulWidget {
  @override
  State<CreateBlog> createState() => _CreateBlogState();
}

class _CreateBlogState extends State<CreateBlog> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    TextEditingController titleController = TextEditingController();
    TextEditingController bodyController = TextEditingController();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Map<String, dynamic> blog = {
              'title': titleController.text.trim(),
              'body': bodyController.text.trim()
            };

            String email = FirebaseAuth.instance.currentUser!.email.toString();
            FirebaseFirestore.instance
                .collection("users")
                .doc(email)
                .collection("blogs")
                .add(blog);

            Navigator.pop(context);
          },
          shape: const CircleBorder(),
          backgroundColor: theme.colorScheme.secondary,
          child: const Icon(Icons.save, size: 35)),
      body: SafeArea(
        minimum: const EdgeInsets.only(left: 15, right: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            createTextField(
                controller: titleController, hintText: " Title", isTitle: true),
            const SizedBox(height: 20),
            createTextField(
                controller: bodyController, hintText: " Start writing!")
          ],
        ),
      ),
    );
  }

  Widget createTextField(
      {required TextEditingController controller,
      required String hintText,
      isTitle = false}) {
    var theme = Theme.of(context);
    var titleStyle = theme.textTheme.displaySmall!;
    var bodyStyle = theme.textTheme.bodyLarge!.copyWith(fontFamily: "Cambria");

    var textStyle = isTitle ? titleStyle : bodyStyle;
    double vertPadding = isTitle ? 30 : 0;

    return TextFormField(
      controller: controller,
      maxLines: null,
      style: textStyle,
      cursorColor: theme.colorScheme.secondary,
      textCapitalization:
          isTitle ? TextCapitalization.words : TextCapitalization.sentences,
      decoration: InputDecoration(
          hintText: hintText,
          hintStyle: textStyle,
          contentPadding: EdgeInsets.symmetric(vertical: vertPadding),
          enabledBorder: isTitle
              ? const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black))
              : InputBorder.none,
          focusedBorder: isTitle
              ? UnderlineInputBorder(
                  borderSide: BorderSide(color: theme.colorScheme.secondary))
              : InputBorder.none),
    );
  }
}