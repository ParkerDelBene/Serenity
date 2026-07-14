import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:serenity/client/data/serenityclient_user.dart';
import 'package:serenity/client/globals.dart';
import 'package:serenity/client/views/widgets/text_channel_message.dart';
import 'package:serenity/server/class_serenity_packet.dart';

class TextChannel extends StatefulWidget {
  TextChannel(
      this.channelName, this.localSave, this.chatsDirectory, this.userList,
      {super.key}) {
    if (localSave && chatsDirectory != null) {
      channelFile = File("${chatsDirectory!.path}/$channelName")..createSync();

      /// Set the timer for flipping the saveChat ValueNotifier
      saveChatTimer =
          Timer.periodic(Duration(seconds: 30), (timer) => _saveNewChats());

      _readChatFile();
    }
  }

  final String channelName;
  final bool localSave;
  final Directory? chatsDirectory;
  late final File channelFile;
  final List<TextChannelMessage> _chatList = [];
  final List<TextChannelMessage> _newChats = [];
  final Queue<String> outgoingChat = Queue();
  final ValueNotifier<bool> _incomingChatAdd = ValueNotifier(false);
  final ValueNotifier<bool> outgoingChatAdd = ValueNotifier(false);
  final ValueNotifier<bool> activeChat = ValueNotifier(false);
  final ValueNotifier<bool> saveChat = ValueNotifier(false);
  final TextEditingController chatTextField = TextEditingController();
  final FocusNode chatFocusNode = FocusNode();
  final Map<String, SerenityClientUser> userList;
  late final Timer saveChatTimer;

  @override
  State<StatefulWidget> createState() => _TextChannelState();

  Widget toIcon() {
    return TextButton(
      onPressed: () {
        activeChat.value = !activeChat.value;
      },
      child: Center(
        child: Text(
          channelName,
          style: channelTextStyle,
        ),
      ),
    );
  }

  void addChat(SerenityClientUser user, String chat) {
    TextChannelMessage message = TextChannelMessage(user, chat);
    _chatList.add(message);
    _newChats.add(message);
    _incomingChatAdd.value = !_incomingChatAdd.value;
  }

  /// Name: _readChatFile
  ///
  /// Date Last Updated: 03/12/26
  ///
  /// Last Updater: Parker DelBene
  ///
  /// Function: This function reads the local chat file and populates the
  /// chatList
  Future<void> _readChatFile() async {
    int chatFileSize;
    List<String> chatFileLines = [];
    /*
      If the chatfile has no data, then just return
    */
    try {
      chatFileSize = await channelFile.length();

      /// Read the channelFile
      chatFileLines = await channelFile.readAsLines();
    } on FileSystemException {
      return;
    }

    if (chatFileSize == 0) {
      return;
    }

    /// Populate the chat
    for (String chat in chatFileLines) {
      _chatList.add(TextChannelMessage.fromJson(jsonDecode(chat), userList));
    }

    /// Clear the newChats
    _newChats.clear();

    _incomingChatAdd.value = !_incomingChatAdd.value;

    return;
  }

  /*
    This function is called by the timer in the initstate and will save the new
    chats periodically to the chatFile
  */

  void _saveNewChats() async {
    // Check if there are no new chats
    if (_newChats.isEmpty) {
      return;
    }

    IOSink fileSink = channelFile.openWrite(mode: FileMode.append);
    for (TextChannelMessage chat in _newChats) {
      fileSink.writeln(jsonEncode(chat));
    }

    _newChats.clear();

    fileSink.close();
  }
}

class _TextChannelState extends State<TextChannel>
    with AutomaticKeepAliveClientMixin {
  List<String> chatFileCache = [];
  int chatFileCacheIndex = 0;
  int numNewChats = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    widget._incomingChatAdd.addListener(chatAddListener);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      double maxWidth = constraints.maxWidth;
      double maxHeight = constraints.maxHeight;

      return Container(
        width: maxWidth,
        height: maxHeight,
        decoration: BoxDecoration(color: primaryColor),
        child: Column(
          children: [
            /// The Area for the Messages
            Expanded(
              child: SizedBox(
                width: maxWidth * .98,
                child: ListView.separated(
                  scrollDirection: Axis.vertical,
                  separatorBuilder: (context, index) => const Divider(
                    color: Colors.transparent,
                  ),
                  reverse: true,
                  itemCount: widget._chatList.length,
                  itemBuilder: (context, index) {
                    //return the list from the back of the list to forward,
                    //Since the chats at the back are the most recent
                    return widget
                        ._chatList[widget._chatList.length - (index + 1)];
                  },
                ),
              ),
            ),

            /// The container for the Textfield
            Container(
              width: maxWidth * .98,
              height: maxHeight * .05,
              decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.circular(10)),
              child:

                  /// The Row allows us to add icons to the beginning and end of the
                  /// textfield area
                  Row(
                children: [
                  SizedBox(
                    width: maxHeight * .04,
                    height: maxHeight * .04,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        "+",
                        style: TextStyle(
                            color: textColor,
                            fontSize: 25,
                            fontWeight: FontWeight.w100),
                      ),
                    ),
                  ),
                  /*
                      Here is the TextField for sending out chats
                    */
                  Expanded(
                    child: TextField(
                      controller: widget.chatTextField,
                      decoration: InputDecoration.collapsed(
                          hintText: "Message #${widget.channelName}",
                          border: InputBorder.none,
                          hintStyle: channelTextStyle),
                      focusNode: widget.chatFocusNode,
                      cursorColor: Colors.white,
                      cursorWidth: 1,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w200),
                      textAlign: TextAlign.left,
                      onSubmitted: sendChat,
                    ),
                  )
                ],
              ),
            ),

            /// Padding at the bottom
            SizedBox(
              height: 10,
            )
          ],
        ),
      );
    });
  }

  /*
    Updates the state whenever a chat is added, only if mounted
  */
  void chatAddListener() {
    //Increment Num of new Chats for File Saving purposes.
    if (mounted) {
      setState(() {});
    }
  }

  /// Name: sendChat
  ///
  /// Date Last Updated: 02/23/26
  ///
  /// Last Updater: Parker DelBene
  ///
  /// Function: This function gets passed a String message, it creates a
  /// SerenityPacket with type=text and data=message, it encodes the messages
  /// and adds it to the outdoing chat queue. Then it clears the textfield,
  /// and requests focus
  void sendChat(String message) {
    /// Create a SerenityPacket and attach the message
    SerenityPacket packet = SerenityPacket(
        SerenityPacketTypeEnum.text, "${widget.channelName};$message");

    /// Send the packet
    widget.outgoingChat.add(jsonEncode(packet));

    /// Clear out the text channel and request focus.
    /// Set the outgoingchat value to fire the listeners
    widget.chatTextField.clear();
    widget.outgoingChatAdd.value = true;
    widget.chatFocusNode.requestFocus();
  }
}
