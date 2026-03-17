import 'dart:io';

import 'package:flutter/material.dart';
import 'package:serenity/client/view_serenity_server.dart';
import 'package:serenity/server/class_serenity_user.dart';

/// Globals used for the server views
List<SerenityServer> serverList = [];
ValueNotifier<SerenityServer?> activeServer = ValueNotifier(null);
double serverIconRatio = .8;
double serverIconPaddingRatio = .2;
double serverTextChannelRatio = .5;

/// Globals used for the screen size
double maxScreenHeight = 0;
double maxScreenWidth = 0;
bool screenSizeInitialized = false;

/// Color Pallet const
Color primaryColor = Color(0xFF18181B);
Color secondaryColor = Color(0xFF27272A);
Color highlightColor = Color(0xFFFAFAFA);
Color textColor = Color(0xFFA1A1AA);

/// TextStyles
TextStyle channelTextStyle = TextStyle(
  fontSize: 15,
  color: textColor,
);

/// Stores the Application Directory
late final Directory applicationDirectory;

/// globals used for the localUser
late SerenityUser localUser;
ValueNotifier<bool> updateLocalUser = ValueNotifier(false);
