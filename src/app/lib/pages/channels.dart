import 'package:app/api.dart';
import 'package:app/pages/chat.dart';
import 'package:flutter/material.dart';

class ChannelListPage extends StatefulWidget {
  final API api;
  const ChannelListPage({super.key, required this.api});

  @override
  State<ChannelListPage> createState() => _ChannelListPageState();
}

class _ChannelListPageState extends State<ChannelListPage> {
  late Future<List<dynamic>> names;

  @override
  void initState() {
    super.initState();
    names = widget.api.getAllChannels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Channels')),
      body: FutureBuilder<List<dynamic>>(
        future: names,
        builder: (ctx, ss) {
          if (ss.connectionState == ConnectionState.done && ss.hasData) {
            return ListView.builder(
              itemCount: ss.data!.length,
              itemBuilder: (context, index) {
                String channelName = ss.data![index];
                return ListTile(
                  title: Text("#$channelName"),
                  onTap: () {
                    Navigator.push(
                      ctx,
                      MaterialPageRoute(
                        builder:
                            (context) => ChatPage(
                              api: widget.api,
                              channelName: channelName,
                            ),
                      ), // SecondPage is your new page widget
                    );
                  },
                );
              },
            );
          }
          // TODO create a block to how Exceptions when getting 500
          // this block return a text saying try again later and a refresh btn
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
