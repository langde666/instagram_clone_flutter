import 'package:flutter/material.dart';
import 'package:instagram_flutter/screens/add_post_screen.dart';
import 'package:instagram_flutter/screens/news_feed_screen.dart';

const webScreenSize = 600;
const homeScreenItems = [
  NewsFeedScreen(),
  Text('search'),
  AddPostScreen(),
  Text('notify'),
  Text('profile'),
];