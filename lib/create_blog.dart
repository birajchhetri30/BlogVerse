import 'package:blogapp/home.dart';
import 'package:blogapp/main.dart';
import 'package:blogapp/profile.dart';
import 'package:flutter/material.dart';
import 'package:blogapp/current_user.dart';
import 'package:provider/provider.dart';

class CreateBlog extends StatefulWidget {
  const CreateBlog({super.key});

  @override
  State<CreateBlog> createState() => _CreateBlogState();
}

class _CreateBlogState extends State<CreateBlog> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var reuse = ReusableWidgets(context);
    var appState = context.watch<CurrentUser>();

    TextEditingController titleController = TextEditingController();
    TextEditingController bodyController = TextEditingController();

    return Container(
      color: theme.colorScheme.background,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
            onPressed: () async {
              Map<String, String> blog = {
                'title': titleController.text.trim(),
                'body': bodyController.text.trim()
              };

              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return reuse.showLoaderDialog(
                        loadingText: "Publishing your blog");
                  });

              appState.addBlog(blog);

              await Future.delayed(const Duration(seconds: 3));

              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Home(currPage: Profile())),
                  (route) => false);
            },
            shape: const CircleBorder(),
            backgroundColor: theme.colorScheme.secondary,
            child: const Icon(Icons.save, size: 35)),
        body: SafeArea(
          minimum: const EdgeInsets.only(left: 15, right: 15),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                createTextField(
                    controller: titleController,
                    hintText: " Title",
                    isTitle: true),
                const SizedBox(height: 20),
                createTextField(
                    controller: bodyController, hintText: " Start writing!")
              ],
            ),
          ),
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
      textInputAction: isTitle ? TextInputAction.next : null,
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
