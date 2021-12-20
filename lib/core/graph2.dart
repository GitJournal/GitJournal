import 'package:d3_force_flutter/d3_force_flutter.dart' as d3f;

import 'package:gitjournal/core/folder/notes_folder.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/core/views/note_links_view.dart';
import 'package:gitjournal/utils/link_resolver.dart';
import 'note.dart';

class NoteNode extends d3f.Node {
  final Note note;

  NoteNode(this.note);
}

class Graph {
  final List<NoteNode> nodes;
  final List<d3f.Edge<NoteNode>> edges;

  Graph(this.nodes, this.edges);
}

Future<Graph> buildGraph(
  NotesFolderFS rootFolder,
  NoteLinksView linksView,
) async {
  var nodes = <String, NoteNode>{};
  var edges = <d3f.Edge<NoteNode>>[];

  NoteNode _getNode(Note note) {
    var node = nodes[note.filePath];
    if (node == null) {
      node = NoteNode(note);
      nodes[note.filePath] = node;
      return node;
    }

    return node;
  }

  Future<void> _addNote(Note note) async {
    var node = _getNode(note);

    var links = await linksView.fetchLinks(note);
    var linkResolver = LinkResolver(note);
    for (var l in links) {
      var noteB = linkResolver.resolveLink(l);
      if (noteB == null) {
        // print("not found $l");
        continue;
      }

      var edge = d3f.Edge(source: node, target: _getNode(noteB));
      edges.add(edge);
    }
  }

  Future<void> _addFolder(NotesFolder folder) async {
    for (var note in folder.notes) {
      await _addNote(note);
    }

    for (var subFolder in folder.subFolders) {
      await _addFolder(subFolder);
    }
  }

  await _addFolder(rootFolder);

  return Graph(nodes.values.toList(), edges);
}
