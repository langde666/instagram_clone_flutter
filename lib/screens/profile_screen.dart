import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/resources/auth_methods.dart';
import 'package:instagram_flutter/resources/firestore_methods.dart';
import 'package:instagram_flutter/screens/blocked_screen.dart';
import 'package:instagram_flutter/screens/follower_screen.dart';
import 'package:instagram_flutter/screens/login_screen.dart';
import 'package:instagram_flutter/screens/post_screen.dart';
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
  int blocking = 0;
  bool isFollowing = false;
  bool isBlocking = false;
  bool isBlocked = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid ?? FirebaseAuth.instance.currentUser!.uid)
        .get();
      
      var postSnap = await FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: widget.uid ?? FirebaseAuth.instance.currentUser!.uid)
        .get();
      
      userData = userSnap.data()!;
      followers = userSnap.data()!['followers'].length;
      following = userSnap.data()!['following'].length;
      blocking = userSnap.data()!['blocking'].length;
      isFollowing = userSnap.data()!['followers'].contains(FirebaseAuth.instance.currentUser!.uid);
      isBlocking = userSnap.data()!['blockers'].contains(FirebaseAuth.instance.currentUser!.uid);
      isBlocked = userSnap.data()!['blocking'].contains(FirebaseAuth.instance.currentUser!.uid);
      postLength = postSnap.docs.length;

      setState(() {
        isLoading = false;
      });
    } catch (err) {
      showSnackBar(err.toString(), context);
      setState(() {
        isLoading = false;
      });
    }
  }

  void navigateToPost() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PostScreen(
          uid: widget.uid ?? FirebaseAuth.instance.currentUser!.uid,
        ),
      ),
    );
  }

  void navigateToFollowScreen(name, field) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FollowScreen(
          user: userData,
          name: name,
          field: field,
        ),
      ),
    );
  }

  void navigateToBlockedScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlockedScreen(
          user: userData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading == true ?
      const Center(
      child: CircularProgressIndicator(),
      ) :
      Scaffold(
        appBar: AppBar(
          backgroundColor: backgroundColor,
          centerTitle: false,
          //username
          title: Text(isBlocked ? 'Instagram user' : userData['username']),
          //edit profile
          // actions: [
          //   IconButton(
          //     icon: const Icon(Icons.settings_outlined),
          //     onPressed: () {},
          //   ),
          // ],
        ),
        body: isBlocked ?
        const Center(
          child: Text("You're blocked"),
        ) :
        ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      //avatar
                      CircleAvatar(
                        backgroundColor: secondaryColor,
                        backgroundImage: NetworkImage(userData['photoUrl']),
                        radius: 40,
                      ),

                      //posts, followers, following
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                //posts
                                GestureDetector(
                                  onTap: navigateToPost,
                                  child: Column(
                                    children: [
                                      Text(
                                        postLength.toString(),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        child: const Text(
                                          'posts',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                //followers
                                GestureDetector(
                                  onTap: () => navigateToFollowScreen('Followers', 'followers'),
                                  child: Column(
                                    children: [
                                      Text(
                                        followers.toString(),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        child: const Text(
                                          'followers',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                //following
                                GestureDetector(
                                  onTap: () => navigateToFollowScreen('Following', 'following'),
                                  child: Column(
                                    children: [
                                      Text(
                                        following.toString(),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        child: const Text(
                                          'following',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            //button
                            widget.uid == null ?
                              //sign out
                              Column(
                                children: [
                                  CustomButton(
                                    text: 'Sign out',
                                    textColor: primaryColor,
                                    backgroundColor: backgroundColor,
                                    borderColor: secondaryColor,
                                    function: () async {
                                      await AuthMethods().signOut();
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                                      );
                                    },
                                  ),

                                  InkWell(
                                    onTap: navigateToBlockedScreen,
                                    child: Text(
                                      'Blocked $blocking users',
                                      style: const TextStyle(fontSize: 14, color: secondaryColor),
                                    ),
                                  ),
                                ],
                              ) :
                              //follow, unfollow
                              Column(
                                children: [
                                  isFollowing ?
                                    CustomButton(
                                      text: 'Unfollow',
                                      textColor: backgroundColor,
                                      backgroundColor: primaryColor,
                                      borderColor: secondaryColor,
                                      function: () async {
                                        await FirestoreMethod().followUser(
                                          FirebaseAuth.instance.currentUser!.uid,
                                          userData['uid'],
                                        );
                                        setState(() {
                                          isFollowing = !isFollowing;
                                          followers--;
                                        });
                                      },
                                    ) : 
                                    CustomButton(
                                      text: 'Follow',
                                      textColor: primaryColor,
                                      backgroundColor: blueColor,
                                      borderColor: blueColor,
                                      function: () async {
                                        await FirestoreMethod().followUser(
                                          FirebaseAuth.instance.currentUser!.uid,
                                          userData['uid'],
                                        );
                                        setState(() {
                                          isFollowing = !isFollowing;
                                          followers++;
                                        });
                                      },
                                    ),
                                  
                                  InkWell(
                                    onTap: () async {
                                      await FirestoreMethod().blockUser(
                                        FirebaseAuth.instance.currentUser!.uid,
                                        userData['uid'],
                                      );
                                      setState(() {
                                        isBlocking = !isBlocking;
                                      });
                                    },
                                    child: Text(
                                      isBlocking ? 'Unblock' : 'Block',
                                      style: const TextStyle(fontSize: 14, color: redColor),
                                    ),
                                  )
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Container(
                    alignment: Alignment.centerLeft,
                    width: double.infinity,
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

            const Divider(
              height: 1,
              thickness: 1,
              color: secondaryColor,
            ),

            FutureBuilder(
              future: FirebaseFirestore.instance
                .collection('posts')
                .where('uid', isEqualTo: widget.uid ?? FirebaseAuth.instance.currentUser!.uid)
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
                      onTap: navigateToPost,
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
          ],
        ),
      );
  }
}