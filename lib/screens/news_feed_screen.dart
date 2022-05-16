import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:instagram_flutter/widgets/post_card.dart';

class NewsFeedScreen extends StatelessWidget {
  const NewsFeedScreen({ Key? key }) : super(key: key);

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
          actions: [
            IconButton(
              icon: const Icon(Icons.chat),
              onPressed: () {},
            ),
          ],
        ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
          .collection('posts')
          .orderBy('datePublished', descending: true)
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