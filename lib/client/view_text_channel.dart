import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:serenity/client/globals.dart';
import 'package:serenity/server/class_serenity_packet.dart';
import 'package:serenity/server/class_serenity_user.dart';

class TextChannel extends StatefulWidget {
  TextChannel(this.channelName, this.localSave, this.chatsDirectory,
      {super.key}) {
    if (localSave && chatsDirectory != null) {
      channelFile = File("${chatsDirectory!.path}/$channelName");
    }
  }

  final String channelName;
  final bool localSave;
  final Directory? chatsDirectory;
  late final File channelFile;
  final List<String> _chatList = [];
  final Queue<String> outgoingChat = Queue();
  final ValueNotifier<bool> _incomingChatAdd = ValueNotifier(false);
  final ValueNotifier<bool> outgoingChatAdd = ValueNotifier(false);
  final ValueNotifier<bool> activeChat = ValueNotifier(false);
  final TextEditingController chatTextField = TextEditingController();
  final FocusNode chatFocusNode = FocusNode();

  @override
  State<StatefulWidget> createState() => _TextChannelState();

  Widget toIcon() {
    return TextButton(
      onPressed: () {
        activeChat.value = true;
      },
      child: Center(
        child: Text(
          channelName,
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }

  void addChat(SerenityUser user, String chat) {
    _chatList.add(chat);
    _incomingChatAdd.value = true;
  }
}

class _TextChannelState extends State<TextChannel> {
  List<String> chatFileCache = [];
  int chatFileCacheIndex = 0;
  int numNewChats = 0;

  @override
  void initState() {
    super.initState();

    widget.channelFile.createSync(recursive: true);

    widget._incomingChatAdd.addListener(chatAddListener);

    /*
      Read the chat file and update the chatlog, noting the index where it stopped
      loading.
    */
    readChatFile(chatFileCacheIndex).then(
      (result) => readChatFileCompletionHandler(result),
    );

    /*
    */
    Timer.periodic(Duration(seconds: 30), (timer) => saveNewChats(timer));
  }

  @override
  Widget build(BuildContext context) {
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
                    //Since the chats at the abck are the most recent
                    return Text(widget
                        ._chatList[widget._chatList.length - (index + 1)]);
                  },
                ),
              ),
            ),
            Container(
              width: maxWidth * .98,
              height: maxHeight * .05,
              decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.circular(10)),
              child: Row(
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
                      ),
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
    if (widget._incomingChatAdd.value) {
      numNewChats++;
      if (mounted) {
        setState(() {});
      }
      widget._incomingChatAdd.value = false;
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

    // Increment num of new chats for File Saving purposes
    numNewChats++;

    if (mounted) {
      setState(() {});
    }
  }

  /* 
    Reads the chatfile in sections and updates the chatlog for the channel.
  */
  Future<int> readChatFile(int index) async {
    int chatFileSize;
    /*
      If the chatfile has no data, then just return
    */
    try {
      chatFileSize = widget.channelFile.lengthSync();
    } catch (e) {
      return index;
    }

    if (chatFileSize == 0) {
      return index;
    }

    /*
      If the chatFileCache is empty, then read the file.
      If not, then continue on as if the chatfile has been read.
    */
    if (chatFileCache.isEmpty) {
      try {
        chatFileCache = await widget.channelFile.readAsLines();
      } catch (e) {
        return -1;
      }
    }

    /*
      Read 30 chats to populate the text, or the length of the cache, 
      whichever is smaller.
    */
    int i;
    int maximumReadSize = min(index + 30, chatFileCache.length);
    for (i = index; i < maximumReadSize; i++) {
      widget._chatList.add(chatFileCache[i]);
    }

    return index + i;
  }

  /*
    Handler for the completion of reading the chatFile, if there is an error it 
    does something, else it marks down the index where it stopped and calls 
    setState if the TextChannel is mounted.
  */
  void readChatFileCompletionHandler(int result) {
    /*
        Unimplemented

        Do something if there is an error idk
      */
    if (result == -1) {
      return;
    }

    chatFileCacheIndex = result;

    if (mounted) {
      setState(() {});
    }
  }

  /*
    This function is called by the timer in the initstate and will save the new
    chats periodically to the chatFile
  */

  void saveNewChats(Timer timer) async {
    // Check if there are no new chats
    if (numNewChats == 0) {
      return;
    }

    // Check if the client is not saving the chats locally
    if (!widget.localSave) {
      numNewChats = 0;
      return;
    }

    IOSink fileSink = widget.channelFile.openWrite(mode: FileMode.append);
    for (int i = numNewChats; i > 0; i--) {
      fileSink.writeln(widget._chatList[widget._chatList.length - i]);
    }

    numNewChats = 0;

    fileSink.close();
  }
}
