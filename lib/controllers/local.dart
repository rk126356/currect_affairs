import 'dart:math';

import 'package:currect_affairs/common/colors.dart';
import 'package:currect_affairs/models/category_model.dart';
import 'package:flutter/material.dart';

List<Category> categoriesGk = [
  Category(
      color: predefinedColors[Random().nextInt(predefinedColors.length)],
      name: 'Basic General Knowledge',
      icon: Icons.lightbulb),
  Category(
      color: predefinedColors[Random().nextInt(predefinedColors.length)],
      name: 'Daily Current Affairs',
      icon: Icons.calendar_month),
  Category(
    color: predefinedColors[Random().nextInt(predefinedColors.length)],
    name: 'Indian History',
    icon: Icons.history,
  ),
  Category(
    color: predefinedColors[Random().nextInt(predefinedColors.length)],
    name: 'General Science',
    icon: Icons.science,
  ),
  Category(
    color: predefinedColors[Random().nextInt(predefinedColors.length)],
    name: 'Famous Personalities',
    icon: Icons.star,
  ),
  Category(
    color: predefinedColors[Random().nextInt(predefinedColors.length)],
    name: 'Indian Politics',
    icon: Icons.account_balance,
  ),
  Category(
    color: predefinedColors[Random().nextInt(predefinedColors.length)],
    name: 'Physics',
    icon: Icons.flare,
  ),
  Category(
    color: predefinedColors[Random().nextInt(predefinedColors.length)],
    name: 'World Geography',
    icon: Icons.public,
  ),
  Category(
    color: predefinedColors[Random().nextInt(predefinedColors.length)],
    name: 'Indian Economy',
    icon: Icons.attach_money,
  ),
  Category(
    color: predefinedColors[Random().nextInt(predefinedColors.length)],
    name: 'Chemistry',
    icon: Icons.school,
  ),
  Category(
    color: predefinedColors[Random().nextInt(predefinedColors.length)],
    name: 'Inventions',
    icon: Icons.lightbulb_outline,
  ),
  Category(
    color: predefinedColors[Random().nextInt(predefinedColors.length)],
    name: 'Indian Geography',
    icon: Icons.map,
  ),
  Category(
    color: predefinedColors[Random().nextInt(predefinedColors.length)],
    name: 'Biology',
    icon: Icons.local_florist,
  ),
  Category(
    color: predefinedColors[Random().nextInt(predefinedColors.length)],
    name: 'Honours and Awards',
    icon: Icons.emoji_events,
  ),
  Category(
    color: predefinedColors[Random().nextInt(predefinedColors.length)],
    name: 'Famous Places in India',
    icon: Icons.location_city,
  ),
  Category(
    color: predefinedColors[Random().nextInt(predefinedColors.length)],
    name: 'Technology',
    icon: Icons.devices,
  ),
  Category(
    color: predefinedColors[Random().nextInt(predefinedColors.length)],
    name: 'Books and Authors',
    icon: Icons.menu_book,
  ),
  Category(
    color: predefinedColors[Random().nextInt(predefinedColors.length)],
    name: 'Indian Culture',
    icon: Icons.palette,
  ),
  Category(
    color: predefinedColors[Random().nextInt(predefinedColors.length)],
    name: 'Sports',
    icon: Icons.sports,
  ),
  Category(
    color: predefinedColors[Random().nextInt(predefinedColors.length)],
    name: 'World Organisations',
    icon: Icons.public,
  ),
  Category(
    color: predefinedColors[Random().nextInt(predefinedColors.length)],
    name: 'Days and Years',
    icon: Icons.calendar_today,
  ),
];

List<Category> categories = [
  Category(
      color: predefinedColors[Random().nextInt(predefinedColors.length)],
      name: 'Daily Current Affairs',
      icon: Icons.calendar_month),
  Category(
      color: predefinedColors[Random().nextInt(predefinedColors.length)],
      name: 'Basic General Knowledge',
      icon: Icons.lightbulb),
  Category(
      color: predefinedColors[Random().nextInt(predefinedColors.length)],
      name: 'Agriculture',
      icon: Icons.agriculture),
  Category(
      color: predefinedColors[Random().nextInt(predefinedColors.length)],
      name: 'Art and Culture',
      icon: Icons.palette),
  Category(
      color: predefinedColors[Random().nextInt(predefinedColors.length)],
      name: 'Awards and Honours',
      icon: Icons.star),
  Category(
      color: predefinedColors[Random().nextInt(predefinedColors.length)],
      name: 'Banking',
      icon: Icons.account_balance),
  Category(
      color: predefinedColors[Random().nextInt(predefinedColors.length)],
      name: 'Bills and Acts',
      icon: Icons.gavel),
  Category(
      color: predefinedColors[Random().nextInt(predefinedColors.length)],
      name: 'Business',
      icon: Icons.business_center),
  Category(
      color: predefinedColors[Random().nextInt(predefinedColors.length)],
      name: 'Defence',
      icon: Icons.shield),
  Category(
      color: predefinedColors[Random().nextInt(predefinedColors.length)],
      name: 'Economy',
      icon: Icons.trending_up),
  Category(
      color: predefinedColors[Random().nextInt(predefinedColors.length)],
      name: 'Education',
      icon: Icons.school),
  Category(
      color: predefinedColors[Random().nextInt(predefinedColors.length)],
      name: 'Environment',
      icon: Icons.eco),
  Category(
      color: predefinedColors[Random().nextInt(predefinedColors.length)],
      name: 'Festivity',
      icon: Icons.festival),
  Category(
      color: predefinedColors[Random().nextInt(predefinedColors.length)],
      name: 'Finance',
      icon: Icons.monetization_on),
  Category(
      color: predefinedColors[Random().nextInt(predefinedColors.length)],
      name: 'Important Days',
      icon: Icons.calendar_today),
  Category(
      color: predefinedColors[Random().nextInt(predefinedColors.length)],
      name: 'International',
      icon: Icons.public),
  Category(
      color: predefinedColors[Random().nextInt(predefinedColors.length)],
      name: 'National',
      icon: Icons.flag),
  Category(
      color: predefinedColors[Random().nextInt(predefinedColors.length)],
      name: 'Obituary',
      icon: Icons.person),
  Category(
      color: predefinedColors[Random().nextInt(predefinedColors.length)],
      name: 'Persons',
      icon: Icons.person),
  Category(
      color: predefinedColors[Random().nextInt(predefinedColors.length)],
      name: 'Places',
      icon: Icons.place),
  Category(
      color: predefinedColors[Random().nextInt(predefinedColors.length)],
      name: 'Politics',
      icon: Icons.gavel),
  Category(
      color: predefinedColors[Random().nextInt(predefinedColors.length)],
      name: 'Science',
      icon: Icons.science),
  Category(
      color: predefinedColors[Random().nextInt(predefinedColors.length)],
      name: 'Sports',
      icon: Icons.sports_basketball),
  Category(
      color: predefinedColors[Random().nextInt(predefinedColors.length)],
      name: 'State',
      icon: Icons.flag),
  Category(
      color: predefinedColors[Random().nextInt(predefinedColors.length)],
      name: 'Talkies',
      icon: Icons.movie),
  Category(
      color: predefinedColors[Random().nextInt(predefinedColors.length)],
      name: 'Technology',
      icon: Icons.computer),
  Category(
      color: predefinedColors[Random().nextInt(predefinedColors.length)],
      name: 'Miscellaneous',
      icon: Icons.label),
];
