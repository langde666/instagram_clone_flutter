import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:instagram_flutter/utils/utils.dart';
import 'package:instagram_flutter/widgets/post_card.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({ Key? key }) : super(key: key);

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  var filter = [];

  @override
  void initState() {
    super.initState();
    getFilter();
  }

  getFilter() async {
    try {
      var _uid = FirebaseAuth.instance.currentUser!.uid;
      var userSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .get();
      setState(() {
        filter = [_uid, ...userSnap.data()!['following'].where((uid) => !userSnap.data()!['blocking'].contains(uid) && !userSnap.data()!['blockers'].contains(uid))];
      });
    } catch (err) {
      showSnackBar(err.toString(), context);
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: backgroundColor,
          centerTitle: false,
          //logo
          title: SvgPicture.asset(
            'assets/ic_instagram.svg',
            color: primaryColor,
            height: 32,
          ),
          //messenger
          // actions: [
          //   IconButton(
          //     icon: const Icon(Icons.chat),
          //     onPressed: () {},
          //   ),
          // ],
        ),
      body: filter.length == 0 ?
      const Center(
        child: Text('No post'),
      ) :
      StreamBuilder(
        stream: FirebaseFirestore.instance
          .collection('posts')
          .where('uid', whereIn: filter)
          // .orderBy('datePublished', descending: true)
          .snapshots(),
        builder: (
          context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) => PostCard(
              snap: snapshot.data!.docs[index].data(),
            ),
          );
        },
      ),
    );
  }
}