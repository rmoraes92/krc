import 'dart:convert';

import 'package:app/api.dart';
import 'package:app/models.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatPage extends StatefulWidget {
  final API api;
  final String channelName;
  const ChatPage({super.key, required this.api, required this.channelName});

  @override
  State<ChatPage> createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  List<Message> messages = [];
  late WebSocketChannel messagesWebSocket;
  final TextEditingController newMessageCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // messages = widget.api.getAllMessagesFrom(widget.channelName);
    messagesWebSocket = widget.api.readNewMessages(widget.channelName);
  }

  @override
  void dispose() {
    messagesWebSocket.sink.close();
    super.dispose();
  }

  onPressedSendNewMessage() async {
    final messageBody = newMessageCtl.text;
    await widget.api.sendNewMessage(
      NewMessage(widget.channelName, messageBody),
    );
    // updateMessages();
  }

  // ignore: non_constant_identifier_names
  StreamBuilder MessagesListView() {
    return StreamBuilder(
      stream: messagesWebSocket.stream,
      builder: (BuildContext ctx, AsyncSnapshot ss) {
        if (ss.data != null) {
          Message msg = Message.fromJson(
            json.decode(String.fromCharCodes(ss.data)),
          );
          messages.add(msg);
        }
        return ListView.builder(
          shrinkWrap: true,
          itemCount: messages.length,
          itemBuilder: (ctx, idx) {
            return Card(
              child: Text("@${messages[idx].author} ${messages[idx].body}"),
            );
          },
        );
      },
    );
  }

  Row Inputs() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: newMessageCtl,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter a message...',
            ),
          ),
        ),
        IconButton(
          onPressed: () async {
            await onPressedSendNewMessage();
          },
          icon: const Icon(Icons.send),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("#${widget.channelName}"),
      ),
      body: Column(
        children: [
          Expanded(child: MessagesListView()),
          Padding(padding: const EdgeInsets.all(8.0), child: Inputs()),
        ],
      ),
    );
  }
}
