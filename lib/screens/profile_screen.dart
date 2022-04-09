import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/resources/auth_methods.dart';
import 'package:instagram_flutter/screens/login_screen.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:instagram_flutter/utils/utils.dart';
import 'package:instagram_flutter/widgets/custome_button.dart';

class ProfileScreen extends StatefulWidget {
  final String? uid;
  const ProfileScreen({ Key? key, this.uid }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  int postLength = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    String _uid;
    if (widget.uid == null) {
      _uid = FirebaseAuth.instance.currentUser!.uid;
    }
    else {
      _uid = widget.uid.toString();
    }
    
    try {
      var userSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .get();
      
      var postSnap = await FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
      
      userData = userSnap.data()!;
      followers = userSnap.data()!['followers'].length;
      following = userSnap.data()!['following'].length;
      isFollowing = userSnap.data()!['followers'].contains(FirebaseAuth.instance.currentUser!.uid);
      postLength = postSnap.docs.length;

      setState(() {
        
      });
    } catch (err) {
      showSnackBar(err.toString(), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Text(userData['username']),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage(userData['photoUrl']),
                      radius: 40,
                    ),

                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              buildStateColumn(postLength, 'posts'),
                              buildStateColumn(followers, 'followers'),
                              buildStateColumn(following, 'following'),
                            ],
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              widget.uid == null ?
                                CustomButton(
                                  text: 'Sign out',
                                  textColor: primaryColor,
                                  backgroundColor: mobileBackgroundColor,
                                  borderColor: Colors.grey,
                                  function: () async {
                                    await AuthMethods().signOut();
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                                    );
                                  },
                                ) : 
                                isFollowing ?
                                  CustomButton(
                                    text: 'Unfollow',
                                    textColor: Colors.black,
                                    backgroundColor: Colors.white,
                                    borderColor: Colors.grey,
                                    function: () {},
                                  ) : 
                                  CustomButton(
                                    text: 'Follow',
                                    textColor: Colors.white,
                                    backgroundColor: Colors.blue,
                                    borderColor: Colors.blue,
                                    function: () {},
                                  ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(top: 1),
                  child: Text(
                    userData['bio'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(),
          FutureBuilder(
            future: FirebaseFirestore.instance
              .collection('posts')
              .where('uid', isEqualTo: widget.uid != null ? widget.uid : FirebaseAuth.instance.currentUser!.uid)
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
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 1.5,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  DocumentSnapshot snap = (snapshot.data! as dynamic).docs[index];
                  return SizedBox(
                    child: Image(
                      image: NetworkImage(snap['postUrl']),
                      fit: BoxFit.cover,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Column buildStateColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}