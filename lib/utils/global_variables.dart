import 'package:flutter/material.dart';
import 'package:instagram_flutter/screens/add_post_screen.dart';
import 'package:instagram_flutter/screens/news_feed_screen.dart';
import 'package:instagram_flutter/screens/profile_screen.dart';

const webScreenSize = 600;

List<Widget> homeScreenItems = [
  const NewsFeedScreen(),
  const Text('search'),
  const AddPostScreen(),
  const Text('notify'),
  const ProfileScreen(),
];