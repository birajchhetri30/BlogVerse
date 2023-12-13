import 'package:blogapp/home.dart';
import 'package:blogapp/main.dart';
import 'package:blogapp/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:blogapp/current_user.dart';
import 'package:provider/provider.dart';

import 'dart:math' as math;

class CreateBlog extends StatefulWidget {
  const CreateBlog({super.key, this.initialTitle, this.initialBody});

  final String? initialTitle;
  final String? initialBody;

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
    titleController.text = widget.initialTitle ?? "";

    TextEditingController bodyController = TextEditingController();
    bodyController.text = widget.initialBody ?? "";

    return Container(
      color: theme.colorScheme.background,
      child: Scaffold(
        floatingActionButton: ExpandableFab(
          distance: 120,
          children: [
            ActionButton(
              onPressed: () async {
                Map<String, dynamic> draft = {
                  'id':
                      "${CurrentUser.currUser?.email}${titleController.text.trim()}",
                  'title': titleController.text.trim(),
                  'body': bodyController.text.trim(),
                  'likes': 0,
                  'author': "${CurrentUser.fname} ${CurrentUser.lname}",
                  'email': CurrentUser.currUser?.email,
                  'timestamp': FieldValue.serverTimestamp()
                };

                if (titleController.text.isEmpty) {
                  reuse.createSnackBar(context,
                      content: "Title cannot be empty");
                } else {
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return reuse.showLoaderDialog(
                            loadingText: "Saving draft");
                      });

                  appState.saveDraft(draft);
                  if (widget.initialTitle != null) {
                    appState.removeDraft(widget.initialTitle!);
                  }

                  await Future.delayed(const Duration(seconds: 3));

                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const Home(currPage: Profile())),
                      (route) => false);
                }
              },
              icon: Icon(
                Icons.save_as,
                color: theme.colorScheme.onSecondary,
              ),
              tooltip: "Save draft",
            ),
            ActionButton(
                onPressed: () async {
                  Map<String, dynamic> blog = {
                    'id':
                        "${CurrentUser.currUser?.email}${titleController.text.trim()}",
                    'title': titleController.text.trim(),
                    'body': bodyController.text.trim(),
                    'likes': 0,
                    'author': "${CurrentUser.fname} ${CurrentUser.lname}",
                    'email': CurrentUser.currUser?.email,
                    'timestamp': FieldValue.serverTimestamp()
                  };

                  if (titleController.text.isEmpty) {
                    reuse.createSnackBar(context,
                        content: "Title cannot be empty");
                  } else if (appState.checkBlogExists(blog['title'])) {
                    reuse.createSnackBar(context,
                        content: "You already have a blog with that title");
                  } else if (!blog['body'].toString().contains(".")) {
                    reuse.createSnackBar(context,
                        content: "Your blog should have at least one sentence");
                  } else {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return reuse.showLoaderDialog(
                              loadingText: "Publishing your blog");
                        });

                    appState.addBlog(blog);
                    if (widget.initialTitle != null) {
                      appState.removeDraft(widget.initialTitle!);
                    }

                    await Future.delayed(const Duration(seconds: 3));

                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const Home(currPage: Profile())),
                        (route) => false);
                  }
                },
                icon:
                    Icon(Icons.post_add, color: theme.colorScheme.onSecondary),
                tooltip: "Publish blog")
          ],
        ),
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
      isTitle = false,
      String? initialText}) {
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

class ExpandableFab extends StatefulWidget {
  const ExpandableFab(
      {super.key,
      this.initialOpen,
      required this.distance,
      required this.children});

  final bool? initialOpen;
  final double distance;
  final List<Widget> children;

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen ?? false;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab()
        ],
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    final theme = Theme.of(context);

    return IconButton(
      onPressed: _toggle,
      style: IconButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          fixedSize: const Size.fromRadius(22)),
      icon: Icon(
        Icons.close,
        color: theme.colorScheme.onPrimary,
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    //final step = 90.0 / (count - 1);
    const step = 60;
    for (var i = 0, angleInDegrees = 90.0;
        i < count;
        i++, angleInDegrees += step) {
      children.add(
        _ExpandingActionButton(
          directionInDegrees: angleInDegrees,
          maxDistance: widget.distance,
          progress: _expandAnimation,
          child: widget.children[i],
        ),
      );
    }
    return children;
  }

  Widget _buildTapToOpenFab() {
    final theme = Theme.of(context);
    return SizedBox(
      height: 50,
      width: 50,
      child: IgnorePointer(
        ignoring: _open,
        child: AnimatedOpacity(
          opacity: _open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton(
              onPressed: _toggle,
              shape: const CircleBorder(),
              backgroundColor: theme.colorScheme.secondary,
              child: const Icon(
                Icons.save,
                size: 30,
              )),
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  const ActionButton(
      {super.key, this.onPressed, required this.icon, required this.tooltip});

  final void Function()? onPressed;
  final Widget icon;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      onPressed: onPressed,
      icon: icon,
      color: theme.colorScheme.secondary,
      tooltip: tooltip,
      style: IconButton.styleFrom(
          backgroundColor: theme.colorScheme.secondary,
          fixedSize: const Size.fromRadius(25)),
    );
  }
}

class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionInDegrees * (math.pi / 180),
          progress.value * maxDistance,
        );
        return Positioned(
          right: 0,
          bottom: 4.0 + offset.dy,
          child: child!,
        );
      },
      child: FadeTransition(
        opacity: progress,
        child: child,
      ),
    );
  }
}
