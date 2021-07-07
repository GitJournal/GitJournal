import 'package:gitjournal/core/md_yaml_doc.dart';
import 'package:gitjournal/core/note.dart';

export 'package:gitjournal/core/note.dart';

abstract class NoteReadTransformer {
  Future<Note> onRead(Note note);
}

abstract class NoteWriteTransformer {
  Future<Note> onWrite(Note note);
}

// ReadTransformersLoader(folderConfig) -> ...
// WriteTransformerLoader(folderConfig) -> ...
// -> test it out again

abstract class MdYamlReadTransformer {
  Future<MdYamlDoc> readTransform(MdYamlDoc doc);
}

abstract class MdYamlWriteTransformer {
  Future<MdYamlDoc> writeTransform(MdYamlDoc doc);
}
