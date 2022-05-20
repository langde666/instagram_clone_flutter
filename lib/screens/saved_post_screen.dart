import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:instagram_flutter/utils/utils.dart';
import 'package:instagram_flutter/widgets/post_card.dart';

class SavedPostScreen extends StatefulWidget {
  const SavedPostScreen({ Key? key }) : super(key: key);

  @override
  State<SavedPostScreen> createState() => _SavedPostScreenState();
}

class _SavedPostScreenState extends State<SavedPostScreen> {
  List saved = [];

  @override
  void initState() {
    super.initState();
    getSaved();
  }

  void getSaved() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get();

      saved = (snapshot.data()! as dynamic)['saved'];
    } catch (err) {
      showSnackBar(err.toString(), context);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Text('Saved Post'),
        centerTitle: false,
      ),
      body: saved.length == 0 ?
        const Center(
          child: Text('No saved'),
        ) : 
        FutureBuilder(
          future: FirebaseFirestore.instance
            .collection('posts')
            .where('postId', whereIn: saved)
            .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
              itemCount: (snapshot.data! as dynamic).docs.length,
              itemBuilder: (context, index) => PostCard(
                snap: (snapshot.data! as dynamic).docs[index].data(),
              ),
            );
          },
        ),
    );
  }
}