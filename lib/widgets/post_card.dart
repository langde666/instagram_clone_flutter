import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/resources/firestore_methods.dart';
import 'package:instagram_flutter/screens/comment_screen.dart';
import 'package:instagram_flutter/screens/profile_screen.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:instagram_flutter/utils/utils.dart';
import 'package:intl/intl.dart';

class PostCard extends StatefulWidget {
  final snap;
  const PostCard({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int commentLength = 0;
  bool isSaved = false;

  @override
  void initState() {
    super.initState();
    getStates();
  }

  void getStates() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('posts')
      .doc(widget.snap['postId'])
      .collection('comments')
      .get();

      DocumentSnapshot snapshot1 = await FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get();

      setState(() {
        commentLength = snapshot.docs.length;
        isSaved = (snapshot1.data()! as dynamic)['saved'].contains(widget.snap['postId']);
      });
    } catch (err) {
      showSnackBar(err.toString(), context);
    }
  }

  void navigateToComment() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CommentScreen(
          snap: widget.snap,
        ),
      ),
    );
  }

  void navigateToProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          uid: FirebaseAuth.instance.currentUser!.uid == widget.snap['uid'] ? null : widget.snap['uid'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          //header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16).copyWith(right: 0),
            child: Row(
              children: [
                //avatar
                GestureDetector(
                  onTap: navigateToProfile,
                  child: CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(widget.snap['profImage']),
                      ),
                ),
                
                //username
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: GestureDetector(
                      onTap: navigateToProfile,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.snap['username'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                //more options
                FirebaseAuth.instance.currentUser!.uid == widget.snap['uid'] ? IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shrinkWrap: true,
                          children: [
                            'Delete',
                          ].map((e) => InkWell(
                              onTap: () async {
                                FirestoreMethod().deletePost(widget.snap['postId']);
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                                child: Text(e),
                              ),
                            ),
                          ).toList(),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.more_vert),
                ) : Container(),
              ],
            ),
          ),

          //image
          SizedBox(
            width: double.infinity,
            child: Image.network(
              widget.snap['postUrl'],
              fit: BoxFit.cover,
            ),
          ),

          //like, comment, share & save
          Row(
            children: [
              //like
              IconButton(
                onPressed: () async {
                  await FirestoreMethod().likePost(
                    widget.snap['postId'],
                    FirebaseAuth.instance.currentUser!.uid,
                    widget.snap['likes'],
                  );
                },
                icon: widget.snap['likes'].contains(FirebaseAuth.instance.currentUser!.uid) ?
                  const Icon(Icons.favorite, color: redColor) :
                  const Icon(Icons.favorite_border),
              ),

              //comment
              IconButton(
                onPressed: navigateToComment,
                icon: const Icon(Icons.comment_outlined),
              ),

              //share
              // IconButton(
              //   onPressed: () {},
              //   icon: const Icon(Icons.send),
              // ),

              //save
              Expanded(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    onPressed: () async {
                      await FirestoreMethod().savePost(FirebaseAuth.instance.currentUser!.uid, widget.snap['postId']);
                      setState(() {
                        isSaved = !isSaved;
                      });
                    },
                    icon: isSaved ? const Icon(Icons.bookmark_rounded) : const Icon(Icons.bookmark_border),
                  ),
                ),
              ),
            ],
          ),

          //number of likes, comments
          //description, published date
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //number of likes
                Text('${widget.snap['likes'].length} likes'),

                //description (caption)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 8),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: primaryColor),
                      children: [
                        TextSpan(
                          text: widget.snap['username'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: ' '),
                        TextSpan(text: widget.snap['description']),
                      ],
                    )
                  ),
                ),

                InkWell(
                  onTap: navigateToComment,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'View all $commentLength comments',
                      style: const TextStyle(fontSize: 14, color: secondaryColor),
                    ),
                  ),
                ),

                Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      DateFormat.yMMMd().format(
                        widget.snap['datePublished'].toDate(),
                      ),
                      style: const TextStyle(fontSize: 14, color: secondaryColor),
                    ),
                  ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}