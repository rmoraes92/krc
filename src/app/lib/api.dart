import 'dart:convert';

import 'package:app/models.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

class API {
  String host;
  late String apiToken;
  API(this.host);

  Map<String, String> getHeaders() {
    return {
      "Content-Type": "application/json; charset=UTF-8",
      "X-KRC-Token": apiToken,
    };
  }

  Map<String, String> getAnonHeaders() {
    return {"Content-Type": "application/json; charset=UTF-8"};
  }

  WebSocketChannel readNewMessages(String channelName) {
    print("readNewMessages - bgn");
    var ret = WebSocketChannel.connect(
      Uri.parse("ws://$host/stream_messages/$channelName"),
    );
    print("readNewMessages connected");
    // TODO send header token for verification
    ret.sink.add(apiToken);
    print("readNewMessages token sent");
    return ret;
  }

  Future<void> sendNewMessage(NewMessage newMsg) async {
    final Uri url = Uri.parse("http://$host/messages");
    final Map<String, String> headers = getHeaders();
    final resp = await http.post(
      url,
      headers: headers,
      body: json.encode(newMsg),
    );
    if (resp.statusCode != 200) {
      throw Exception("failed creating channel ${resp.body}");
    }
  }

  Future<void> createChannel(NewChannel newChannel) async {
    final Uri url = Uri.parse("http://$host/channels");
    final Map<String, String> headers = getHeaders();
    final resp = await http.post(
      url,
      headers: headers,
      body: json.encode(newChannel),
    );
    if (resp.statusCode != 200) {
      throw Exception("failed creating channel ${resp.body}");
    }
  }

  /// This actually returns a List of Strings but json.decode does not like to
  /// decode directly to it .-.
  Future<List<dynamic>> getAllChannels() async {
    final Uri url = Uri.parse("http://$host/channels");
    final Map<String, String> headers = getHeaders();
    final resp = await http.get(url, headers: headers);
    if (resp.statusCode != 200) {
      throw Exception(
        "failed to retrieve channels: ${resp.statusCode} ${resp.body}",
      );
    }
    return json.decode(resp.body);
  }

  Future<void> signUp(Credentials creds) async {
    final Uri url = Uri.parse("http://$host/signup");
    final Map<String, String> headers = getAnonHeaders();
    final resp = await http.post(
      url,
      headers: headers,
      body: json.encode(creds),
    );
    if (resp.statusCode != 200) {
      throw Exception("failed to retrieve Boards");
    }
  }

  Future<SignInResponse> signIn(Credentials creds) async {
    final Uri url = Uri.parse("http://$host/signin");
    final Map<String, String> headers = getAnonHeaders();
    final String body = jsonEncode(creds);
    final resp = await http.post(url, headers: headers, body: body);
    if (resp.statusCode != 200) {
      throw Exception("failed to signin: ${resp.statusCode} ${resp.body}");
    }
    var ret = SignInResponse.fromJson(json.decode(resp.body));
    apiToken = ret.token;
    return ret;
  }
}
