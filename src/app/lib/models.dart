class NewMessage {
  String channel;
  String body;
  NewMessage(this.channel, this.body);
  Map<String, String> toJson() {
    return {"channel": channel, "body": body};
  }
}

class Message {
  String author;
  String body;
  Message(this.author, this.body);

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(json["author"], json["body"]);
  }
}

class NewChannel {
  String name;
  NewChannel(this.name);
}

class Credentials {
  String username;
  String password;
  Credentials(this.username, this.password);
  Map<String, String> toJson() {
    return {"username": username, "password": password};
  }
}

class SignInResponse {
  String token;
  SignInResponse(this.token);
  factory SignInResponse.fromJson(Map<String, dynamic> json) {
    return SignInResponse(json['token']);
  }
}
