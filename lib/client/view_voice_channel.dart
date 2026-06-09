import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:audiopc/audiopc.dart';
import 'package:serenity/client/class_microphone_recorder.dart';
import 'package:serenity/client/class_serenityclient_user.dart';
import 'package:serenity/client/globals.dart';
import 'package:serenity/client/widget_clickable_widget.dart';
import 'package:serenity/client/widget_view_divider.dart';

/// A class to hold the various settings for the voice channel.
class VoiceChannelSettings {
  const VoiceChannelSettings(this.interleaved, this.numChannels,
      this.sampleRate, this.bufferSize);

  final bool interleaved;
  final int numChannels;
  final int sampleRate;
  final int bufferSize;
}

class VoiceChannel extends StatefulWidget {
  VoiceChannel(this.channelName, this.userList, this.voiceSettings, {super.key})
      : voiceChannelIcon = VoiceChannelIcon(channelName, userList) {
    voiceChannelIcon.activeVoiceChannel.addListener(voiceChannelConnectHandler);
  }

  static final VoiceChannelSettings defaultSettings = VoiceChannelSettings(false, 2, 48000, 1024);

  final String channelName;
  final Map<String, SerenityClientUser> userList;
  final VoiceChannelIcon voiceChannelIcon;
  final ValueNotifier<bool> connected = ValueNotifier<bool>(false);
  final ValueNotifier<bool> activeChannel = ValueNotifier<bool>(false);
  final ValueNotifier<Uint8List> outgoingVoiceData =
      ValueNotifier<Uint8List>(Uint8List(0));
  final Map<String, AudioPlayer> userAudioPlayers = {};
  final VoiceChannelSettings voiceSettings;
  final MicrophoneRecorder microphone = MicrophoneRecorder();
  final ValueNotifier<bool> microphoneInitialized = ValueNotifier<bool>(false);
  final ValueNotifier<StreamSubscription?> microphoneSubscription =
      ValueNotifier<StreamSubscription?>(null);

  /// Handles the logic for connecting to the voice Channel.
  void voiceChannelConnectHandler() {
    /// If already connected, then simply activate the channelView
    if (connected.value) {
      activeChannel.value = true;
      return;
    }

    /// If not connected, then connect to the voice channel

    /// Initialize an AudioPlayer for each user connected to the voiceChannel
    userList.forEach((userID, user) {
      AudioPlayer player = AudioPlayer();

      userAudioPlayers.addAll({userID: player});
    });

    /// Initialize the microphone
    startMicrophone();
  }

  void startMicrophone() async {
    await microphone.startStream();
    microphoneSubscription.value =
        microphone.audioStream.listen(microphoneHandler);
  }

  void stopMicrophone() {
    /// End the subscription to the microphone and then swaap the value to null.
    if (microphoneSubscription.value != null) {
      microphoneSubscription.value!.cancel();
      microphoneSubscription.value = null;
    }
  }

  void microphoneHandler(Uint8List data) {
    outgoingVoiceData.value = data;
  }

  /// Adds the user to the voiceChannel and creates and audio player for them.
  void addUser(SerenityClientUser user) {
    /// Add to the list
    userList.addAll({user.userID: user});

    /// Create the audio player
    AudioPlayer player = AudioPlayer();

    /// Add the player to the list.
    userAudioPlayers.addAll({user.userID: player});
    voiceChannelIcon.updateUserList.value = true;
  }

  /// removes the user, closes the audio player, and flags the updateUserList value
  void removeUser(SerenityClientUser user) {
    userList.remove(user.userID);

    /// If there is a user audio player for this user, then remove it
    if (connected.value) {
      AudioPlayer? player = userAudioPlayers.remove(user.userID);

      if (player != null) {
        player.dispose();
      }
    }
    voiceChannelIcon.updateUserList.value = true;
  }

  void playAudio(String userID, Uint8List data) {
    if (userAudioPlayers.containsKey(userID)) {
      userAudioPlayers[userID]!.playMemory(data);
    }
  }

  @override
  State<StatefulWidget> createState() => _VoiceChannelState();
}

class _VoiceChannelState extends State<VoiceChannel> {
  @override
  Widget build(BuildContext context) {
    return Column();
  }
}

/// Name: _VoiceChannelIcon
///
/// Date Last Updated: 06/01/26
///
/// Last Updater: Parker DelBene
///
/// Function: This handles creating the channel icon that lives in the text channel and voice channel
/// list on the server view. This will handle rendering the various user icons and names, as well as
/// allowing the user to join th096e channel.
class VoiceChannelIcon extends StatefulWidget {
  VoiceChannelIcon(this.channelName, this.userList, {super.key});

  final String channelName;
  final Map<String, SerenityClientUser> userList;

  /// Lets the top level voiceChannel know when this voiceChannel was clicked.
  final ValueNotifier<bool> activeVoiceChannel = ValueNotifier<bool>(false);

  /// Listens to update the state whena new user joins
  final ValueNotifier<bool> updateUserList = ValueNotifier<bool>(false);

  @override
  State<VoiceChannelIcon> createState() => _VoiceChannelIconState();
}

class _VoiceChannelIconState extends State<VoiceChannelIcon> {
  @override
  void initState() {
    super.initState();

    widget.updateUserList.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    /// Build the list holding the userIcons and names, then adding them to the Column.
    List<StatelessWidget> userIcons = [];

    widget.userList.forEach((userKey, user) {
      userIcons.add(CompactUserVoiceChannelIcon(user));
    });

    return Column(
      children: [
            ClickableWidget(
              () => widget.activeVoiceChannel.value =
                  !widget.activeVoiceChannel.value,
              Text(
                widget.channelName,
                style: channelTextStyle,
              ),
            ),
            ViewDivider(false),
          ] +
          userIcons,
    );
  }
}

/// The stateless widget to display a compact version of the user icon and name
class CompactUserVoiceChannelIcon extends StatelessWidget {
  const CompactUserVoiceChannelIcon(this.user, {super.key});

  final SerenityClientUser user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Image.memory(user.userIcon.iconImage.value),
          ),
        ),
        Text(
          user.userName,
          style: channelTextStyle,
        )
      ],
    );
  }
}
