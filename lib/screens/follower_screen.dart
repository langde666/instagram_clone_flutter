import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/screens/profile_screen.dart';
import 'package:instagram_flutter/utils/colors.dart';

class FollowScreen extends StatefulWidget {
  final user;
  final field;
  final name;
  const FollowScreen({
    Key? key,
    required this.user,
    required this.field,
    required this.name,
  }) : super(key: key);

  @override
  State<FollowScreen> createState() => _FollowScreenState();
}

class _FollowScreenState extends State<FollowScreen> {

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
        title: Text(widget.name),
        centerTitle: false,
      ),
      body: widget.user[widget.field].length == 0 ?
      Center(
        child: Text('No ' + widget.name),
      ) :
      FutureBuilder(
        future: FirebaseFirestore.instance
          .collection('users')
          .where('uid', whereIn: widget.user[widget.field])
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