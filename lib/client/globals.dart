import 'package:flutter/material.dart';
import 'package:serenity/client/view_serenity_server.dart';

List<SerenityServer> serverList = [];
ValueNotifier<SerenityServer?> activeServer = ValueNotifier(null);
double serverIconRatio = .8;
double serverIconPaddingRatio = .2;
double serverTextChannelRatio = .5;

double maxScreenHeight = 0;
double maxScreenWidth = 0;
bool screenSizeInitialized = false;
