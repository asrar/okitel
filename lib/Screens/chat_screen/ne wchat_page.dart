import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Color itemColor = CupertinoColors.secondaryLabel;
  double itemSize = 20.0;

  @override
  Widget build(BuildContext context) {
    final double scaledIconSize =
        MediaQuery.textScaleFactorOf(context) * itemSize;

    final IconThemeData iconThemeData = IconThemeData(
      color: CupertinoDynamicColor.resolve(itemColor, context),
      size: scaledIconSize,
    );

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: Row(
            children: [
              IconButton(
                icon: Icon(CupertinoIcons.back),
                onPressed: () {},
              ),
              Text('Chat'),
            ],
          ),
          title: Column(
            children: [
              Text(
                'Martha Charaig',
                style: Theme.of(context).textTheme.subtitle2,
              ),
              Text(
                'last seen at 4:00 pm',
                style: Theme.of(context).textTheme.caption,
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text('AV'),
              ),
            )
          ],
        ),
        body: Container(),
        bottomSheet: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.attach_file,
                      color: Colors.white.withOpacity(0.5),
                    )),
                Expanded(
                  child: CupertinoSearchTextField(
                    placeholder: 'Message',
                    prefixIcon: Container(height: 0),
                    suffixIcon: Icon(CupertinoIcons.camera),
                    suffixMode: OverlayVisibilityMode.always,
                    style: TextStyle(color: Colors.white),
                    onChanged: (String value) {
                      //print('The text has changed to: $value');
                    },
                    onSubmitted: (String value) {
                      //print('Submitted text: $value');
                    },
                  ),
                ),
                IconButton(
                    onPressed: () {},
                    icon: Icon(CupertinoIcons.mic,
                        color: Colors.white.withOpacity(0.5))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
