import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/models/user.dart';
import 'package:instagram_flutter/providers/user_provider.dart';
import 'package:instagram_flutter/resources/firestore_methods.dart';
import 'package:instagram_flutter/screens/profile_screen.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:instagram_flutter/widgets/comment_card.dart';

class CommentScreen extends StatefulWidget {
  final snap;
  const CommentScreen({
    Key? key,
    required this.snap
  }) : super(key: key);

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _commentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).getUser;

    void navigateToProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          uid: FirebaseAuth.instance.currentUser!.uid == widget.snap['uid'] ? null : widget.snap['uid'],
        ),
      ),
    );
  }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Text('Comments'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          //description (caption)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: navigateToProfile,
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(widget.snap['profImage']),
                    radius: 18,
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: navigateToProfile,
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: widget.snap['username'],
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const TextSpan(
                                  text: ' ',
                                ),
                                TextSpan(
                                  text: widget.snap['description'],
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            DateFormat.yMMMd().format(
                              widget.snap['datePublished'].toDate(),
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(
            height: 1,
            thickness: 1,
            color: secondaryColor,
          ),

          Flexible(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                .collection('posts')
                .doc(widget.snap['postId'])
                .collection('comments')
                .orderBy('datePublished', descending: true)
                .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
          
                return ListView.builder(
                  itemCount: (snapshot.data! as dynamic).docs.length,
                  itemBuilder: (context, index) => CommentCard(
                    snap: (snapshot.data! as dynamic).docs[index].data(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      //comment input
      bottomNavigationBar: Container(
        height: 56.0,
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(user.photoUrl),
              radius: 18,
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Comment as ${user.username}',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            InkWell(
              onTap: () async {
                await FirestoreMethod().postComment(
                  widget.snap['postId'],
                  _commentController.text,
                  user.uid,
                  user.username,
                  user.photoUrl,
                );

                setState(() {
                  _commentController.text = "";
                });
              },
              child: Container(
                padding: const EdgeInsets.all(8.0),
                child: const Text(
                  'Post',
                  style: TextStyle(
                    color: blueColor,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}