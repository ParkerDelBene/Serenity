import 'package:flutter/material.dart';
import 'package:serenity/client/data/communication/serenityclient_user.dart';
import 'package:serenity/client/globals.dart';
import 'package:serenity/client/views/widgets/view_divider.dart';

class ServerUserList extends StatefulWidget {
  const ServerUserList(this.userList, {super.key});

  final Map<String, SerenityClientUser> userList;

  @override
  State<StatefulWidget> createState() => _ServerUserListState();
}

class _ServerUserListState extends State<ServerUserList> {
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
              Text(
                "Members - ${widget.userList.length}",
                style: channelTextStyle,
              ),
              ViewDivider(false),
              SizedBox(
                height: 5,
              ),
              Expanded(
                child: SizedBox(
                  width: maxScreenWidth * .20,
                  child: ListView.separated(
                    scrollDirection: Axis.vertical,
                    separatorBuilder: (context, index) => const Divider(
                      color: Colors.transparent,
                    ),
                    reverse: false,
                    itemCount: widget.userList.length,
                    itemBuilder: (context, index) {
                      /// Get the user at the specific index
                      SerenityClientUser user =
                          widget.userList.values.elementAt(index);

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          user.userIcon,
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            user.userName,
                            style: TextStyle(color: textColor),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
