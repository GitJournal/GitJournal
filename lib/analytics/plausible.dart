import 'dart:convert';

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
const req = new XMLHttpRequest();
  req.open('POST', `${data.apiHost}/api/event`, true);
  req.setRequestHeader('Content-Type', 'text/plain');
  req.send(JSON.stringify(payload));
  */
