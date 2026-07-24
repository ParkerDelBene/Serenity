import 'dart:io';

import 'package:flutter/material.dart';
import 'package:serenity/client/data/communication/serenityclient_user.dart';
import 'package:serenity/client/views/pages/serenity_server.dart';

/// Globals used for the server views
List<SerenityServer> serverList = [];
ValueNotifier<SerenityServer?> activeServer = ValueNotifier(null);

/// Ratio for server icon size
double serverIconPaddingRatio = .2;
double serverIconRatio = .025;

/// Padding ratio for server icon size
double serverTextChannelRatio = .5;

/// Globals used for the screen size
double maxScreenHeight = 0;
double maxScreenWidth = 0;
bool screenSizeInitialized = false;

/// Globals for the icon size calculateds from the max screenSize
double smallImageIconSize = 0;
double largeImageIconSize = 0;

ThemeData theme = ThemeData();

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
late SerenityClientUser localUser;
ValueNotifier<bool> updateLocalUser = ValueNotifier(false);
