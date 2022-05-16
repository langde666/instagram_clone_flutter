import 'package:flutter/material.dart';
import 'package:instagram_flutter/screens/add_post_screen.dart';
import 'package:instagram_flutter/screens/news_feed_screen.dart';
import 'package:instagram_flutter/screens/profile_screen.dart';
import 'package:instagram_flutter/screens/search_screen.dart';

const webScreenSize = 1200;

List<Widget> homeScreenItems = [
  const NewsFeedScreen(),
  const SearchScreen(),
  const AddPostScreen(),
  const Text('Saved'),
  const ProfileScreen(),
];