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

/// Color Palleconst
const Color primaryColor = Color(0xFF18181B);
const Color secondaryColor = Color(0xFF27272A);
const Color highlightColor = Color(0xFFFAFAFA);
const Color textColor = Color(0xFFA1A1AA);

/// globals used for the localUser
late SerenityUser localUser;
ValueNotifier<bool> updateLocalUser = ValueNotifier(false);
