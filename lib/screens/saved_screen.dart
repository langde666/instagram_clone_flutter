import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/screens/saved_post_screen.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:instagram_flutter/utils/utils.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({ Key? key }) : super(key: key);

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
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

  void navigateToSavedPost() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SavedPostScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Text('Saved'),
        centerTitle: true,
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
            return GridView.builder(
                  shrinkWrap: true,
                  itemCount: (snapshot.data! as dynamic).docs.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 3,
                    crossAxisSpacing: 3,
                  ),
                  itemBuilder: (context, index) {
                    DocumentSnapshot snap = (snapshot.data! as dynamic).docs[index];
                    return GestureDetector(
                      onTap: navigateToSavedPost,
                      child: SizedBox(
                        child: Image(
                          image: NetworkImage(snap['postUrl']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                );
          },
        ),
    );
  }
}