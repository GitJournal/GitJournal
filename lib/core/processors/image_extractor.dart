import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class NoteImage extends Equatable {
  final String url;
  final String alt;

  NoteImage({@required this.url, @required this.alt});

  @override
  List<Object> get props => [url, alt];

  @override
  bool get stringify => true;
}

class ImageExtractor {
  static final _regexp = RegExp(r"!\[(.*)\]\((.*)\)");

  Set<NoteImage> extract(String body) {
    var images = <NoteImage>{};
    var matches = _regexp.allMatches(body);
    for (var match in matches) {
      var alt = match.group(1);
      var url = match.group(2);

      images.add(NoteImage(alt: alt, url: url));
    }

    return images;
  }
}
