import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/screens/profile_screen.dart';
import 'package:instagram_flutter/utils/colors.dart';

class BlockedScreen extends StatefulWidget {
  final user;
  const BlockedScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<BlockedScreen> createState() => _BlockedScreenState();
}

class _BlockedScreenState extends State<BlockedScreen> {
  void navigateToProfile(uid) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          uid: uid,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Text('Blocked'),
        centerTitle: false,
      ),
      body: widget.user['blocking'].length == 0 ?
      const Center(
        child: Text('No blocked user'),
      ) :
      FutureBuilder(
        future: FirebaseFirestore.instance
          .collection('users')
          .where('uid', whereIn: widget.user['blocking'])
          .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: (snapshot.data! as dynamic).docs.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      (snapshot.data! as dynamic).docs[index]['photoUrl'],
                    ),
                  ),
                  title: Text(
                    (snapshot.data! as dynamic).docs[index]['username'],
                  ),
                  onTap: () => navigateToProfile(
                    (snapshot.data! as dynamic).docs[index]['uid'] == FirebaseAuth.instance.currentUser!.uid ?
                      null :
                      (snapshot.data! as dynamic).docs[index]['uid']),
                );
              },
            ),
          );
        },
      ),
    );
  }
}