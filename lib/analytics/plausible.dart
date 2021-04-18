import 'dart:convert';

// import 'package:http/http.dart' as http;

class PlausibleEvent {
  String eventName = "";
  String href = "";
  String hostname = "";

  String referrer = "";
  int innerWidth = 0;
  bool hash = false;
  Map<String, dynamic> props = {};

  static final _acceptedPayloadTypes = [int, double, String, bool];
  Map<String, dynamic> toMap() {
    assert(() {
      for (var entry in props.entries) {
        var type = entry.value.runtimeType;
        if (!_acceptedPayloadTypes.contains(type)) {
          return false;
        }
      }
      return true;
    }(), "Plausible Event Payload contains unsupported type");

    return {
      'n': eventName,
      'u': href,
      'd': hostname,
      'r': referrer,
      'w': innerWidth,
      'h': hash ? 1 : 0,
      'p': json.encode(props),
    };
  }

  String toJson() => json.encode(toMap());
}

/*

void main() async {
  const apiHost = 'plausible.gitjournal.io';
  var event = PlausibleEvent();
  event.eventName = 'gitjournal_test';
  event.hostname = 'gitjournal.io';
  event.href = 'https://gitjournal.io/mobile_analytics';

  var post = http.post(
    Uri.https(apiHost, '/api/event'),
    // FIXME: Why is this not application/json ?
    // Taken from - https://github.com/plausible/tracker/blob/master/src/index.js
    headers: <String, String>{
      'Content-Type': 'text/plain',
    },
    body: event.toJson(),
  );
  var response = await post;
  print('Posted');
  print('Status Code: ${response.statusCode}');
  print('Headers: ${response.headers}');
  print('Body: ${response.bodyBytes.toString()}');
}

*/
