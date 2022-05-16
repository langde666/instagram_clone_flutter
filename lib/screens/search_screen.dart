import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_flutter/screens/profile_screen.dart';
import 'package:instagram_flutter/screens/post_screen.dart';
import 'package:instagram_flutter/utils/colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({ Key? key }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

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
        title: TextFormField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Search for a user',
            border: InputBorder.none,
          ),
          onFieldSubmitted: (String _) {
            if (_ == '') {
              setState(() {
                isShowUsers = false;
              });
            }
            else {
              setState(() {
                isShowUsers = true;
              });
            }
          },
          onChanged: (String _) {
            if (_ == '') {
              setState(() {
                isShowUsers = false;
              });
            }
          },
        ),
      ),
      body: isShowUsers ?
        FutureBuilder(
          future: FirebaseFirestore.instance
            .collection('users')
            .where('username', isGreaterThanOrEqualTo: searchController.text)
            .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return ListView.builder(
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
            );
          },
        ) :
        FutureBuilder(
          future: FirebaseFirestore.instance
            .collection('posts')
            .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return GridView.custom(
              gridDelegate: SliverQuiltedGridDelegate(
                crossAxisCount: 3,
                mainAxisSpacing: 3,
                crossAxisSpacing: 3,
                repeatPattern: QuiltedGridRepeatPattern.inverted,
                pattern: [
                  const QuiltedGridTile(2, 2),
                  const QuiltedGridTile(1, 1),
                  const QuiltedGridTile(1, 1),
                ],
              ),
              childrenDelegate: SliverChildBuilderDelegate(
                (context, index) => GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PostScreen(
                          uid: (snapshot.data! as dynamic).docs[index]['uid'],
                        ),
                      ),
                    );
                  },
                  child: Image.network(
                    (snapshot.data! as dynamic).docs[index]['postUrl'],
                    fit: BoxFit.cover,
                  ),
                ),
                childCount: (snapshot.data! as dynamic).docs.length,
              ),
            );
          },
        ),
    );
  }
}