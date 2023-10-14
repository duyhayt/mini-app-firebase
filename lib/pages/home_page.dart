import 'package:firebase_social_app/components/my_drawer.dart';
import 'package:firebase_social_app/components/my_post_button.dart';
import 'package:firebase_social_app/components/my_textfield.dart';
import 'package:firebase_social_app/database/firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreDatabase database = FirestoreDatabase();

  TextEditingController newPostController = TextEditingController();

  void postMessage() {
    if (newPostController.text.isNotEmpty) {
      String message = newPostController.text;
      database.addPost(message);
    }

    newPostController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("W A L L"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      drawer: const MyDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Row(
              children: [
                Expanded(child: MyTextField(hintText: "Say something...", obscureText: false, controller: newPostController)),
                MyPostButton(
                  onTap: postMessage,
                )
              ],
            ),
          ),
          StreamBuilder(
              stream: database.getPostsStream(),
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final posts = snapshot.data!.docs;
                if (snapshot.data == null || posts.isEmpty) {
                  return const Center(
                      child: Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text("No posts.. Post something!"),
                  ));
                }
                return Expanded(
                  child: ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (_, index) {
                      final post = posts[index];
                      String message = post['PostMessage'];
                      String userEmail = post['UserEmail'];
                      String timestamp = post['TimeStamp'].toString();

                      return Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: ListTile(
                          title: Text(message),
                          subtitle: Text(
                            userEmail,
                            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                          ),
                        ),
                      );
                    },
                  ),
                );
              })
        ],
      ),
    );
  }
}
