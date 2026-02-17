import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';

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
        child: Text(channelName),
      ),
    );
  }

  void addChat(String chat) {
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

    widget.channelFile.createSync();

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
        decoration: BoxDecoration(color: Colors.grey),
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
                  color: Colors.blueGrey,
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
                            color: Colors.white,
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

  /// PUlls the text from
  void sendChat(String message) {
    message = message.trim();
    widget._chatList.add(message);
    widget.outgoingChat.add(message);
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
      Read 30 chats to popualte the text, or the length of the cache, 
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
