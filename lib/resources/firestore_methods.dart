import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_flutter/models/post.dart';
import 'package:instagram_flutter/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethod {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //upload Post
  Future<String> uploadPost(
    String description,
    Uint8List file,
    String uid,
    String username,
    String profImage,
  ) async {
    String res = "Some error occurred";
    try {
      String photoUrl = await StorageMethods().uploadImageStorage('posts', file, true);

      String postId = const Uuid().v1();
      Post post = Post(
        description: description,
        uid: uid,
        username: username,
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        profImage: profImage,
        likes: [],
      );

      _firestore.collection('posts').doc(postId).set(post.toJson());

      res = "Success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  //like post
  Future<void> likePost(
    String postId,
    String uid,
    List likes,
  ) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      }
      else {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (err) {
      print(err.toString());
    }
  }

  //comment post
  Future<void> postComment(
    String postId,
    String text,
    String uid,
    String name,
    String profilePic,
  ) async {
    try {
      if (text.isNotEmpty) {
        String commentId = const Uuid().v1();
        await _firestore.collection('posts').doc(postId).collection('comments').doc(commentId).set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
        });
      }
      else {
        print('Comment is empty');
      }
    } catch (err) {
      print(err.toString());
    }
  }

  //delete post
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (err) {
      print(err.toString());
    }
  }

  //save post
  Future<void> savePost(
    String uid,
    String postId,

  ) async {
    try {
      DocumentSnapshot snap = await _firestore.collection('users').doc(uid).get();
      List saved = (snap.data()! as dynamic)['saved'];
      
      if (saved.contains(postId)) {
        await _firestore.collection('users').doc(uid).update({
          'saved': FieldValue.arrayRemove([postId]),
        });
      }
      else {
        await _firestore.collection('users').doc(uid).update({
          'saved': FieldValue.arrayUnion([postId]),
        });
      }
    } catch (err) {
      print(err.toString());
    }
  }

  //follow user
  Future<void> followUser(
    String uid,
    String followId,

  ) async {
    try {
      DocumentSnapshot snap = await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];
      
      if (following.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid]),
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId]),
        });
      }
      else {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid]),
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId]),
        });
      }
    } catch (err) {
      print(err.toString());
    }
  }

  //block user
  Future<void> blockUser(
    String uid,
    String blockId,
  ) async {
    try {
      DocumentSnapshot snap = await _firestore.collection('users').doc(uid).get();
      List blocking = (snap.data()! as dynamic)['blocking'];

      if (blocking.contains(blockId)) {
        await _firestore.collection('users').doc(blockId).update({
          'blockers': FieldValue.arrayRemove([uid]),
        });

        await _firestore.collection('users').doc(uid).update({
          'blocking': FieldValue.arrayRemove([blockId]),
        });
      }
      else {
        await _firestore.collection('users').doc(blockId).update({
          'blockers': FieldValue.arrayUnion([uid]),
        });

        await _firestore.collection('users').doc(uid).update({
          'blocking': FieldValue.arrayUnion([blockId]),
        });
      }
    } catch (err) {
      print(err.toString());
    }
  }
}