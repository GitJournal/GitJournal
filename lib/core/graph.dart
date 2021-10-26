/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:gitjournal/core/folder/notes_folder.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/views/note_links_view.dart';
import 'package:gitjournal/utils/link_resolver.dart';

class Node {
  Note note;

  double y = 0.0;
  double x = 0.0;
  bool pressed = false;

  double forceX = 0.0;
  double forceY = 0.0;

  String? _label;

  Node(this.note);

  String? get label {
    _label ??= note.filePath;
    return _label;
  }

  @override
  String toString() => "Node{$label, $x, $y}";
}

class Edge {
  Node a;
  Node b;

  Edge(this.a, this.b);
}

class Graph extends ChangeNotifier {
  List<Node> nodes = [];
  List<Edge> edges = [];

  final Map<String?, Set<int?>> _neighbours = {};
  Map<String?, int>? _nodeIndexes;

  late GraphNodeLayout initLayouter;
  final NoteLinksView linksView;

  final double nodeSize = 50.0;

  Graph.fromFolder(NotesFolder folder, this.linksView) {
    initLayouter = GraphNodeLayout(maxHeight: 2000, maxWidth: 2000);

    // print("Building graph .... ");
    _addFolder(folder).then((_) {
      // print("Done Building graph");
      // print("Starting layouting ...");

      //startLayout();
    });
  }

  Future<void> _addFolder(NotesFolder folder) async {
    for (var note in folder.notes) {
      await _addNote(note);
    }

    for (var subFolder in folder.subFolders) {
      await _addFolder(subFolder);
    }

    notifyListeners();
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

      var edge = Edge(node, _getNode(noteB));
      edges.add(edge);
    }
  }

  // FIXME: Make this faster?
  Node _getNode(Note note) {
    var i = nodes.indexWhere((n) => n.note.filePath == note.filePath);
    if (i == -1) {
      var node = Node(note);
      initLayouter.positionNode(node);

      nodes.add(node);
      return node;
    }

    return nodes[i];
  }

  void notify() {
    notifyListeners();
    startLayout();
  }

  List<int?> computeNeighbours(Node n) {
    if (_nodeIndexes == null) {
      _nodeIndexes = <String?, int>{};
      for (var i = 0; i < this.nodes.length; i++) {
        var node = this.nodes[i];
        _nodeIndexes![node.label] = i;
      }
    }

    var _nodes = _neighbours[n.label];
    if (_nodes != null) {
      return _nodes.union(computeOverlappingNodes(n)).toList();
    }

    var nodes = <int?>{};
    for (var edge in edges) {
      if (edge.a.label == n.label) {
        var _ = nodes.add(_nodeIndexes![edge.b.label]);
        continue;
      }

      if (edge.b.label == n.label) {
        var _ = nodes.add(_nodeIndexes![edge.a.label]);
        continue;
      }
    }

    _neighbours[n.label] = nodes;
    return nodes.union(computeOverlappingNodes(n)).toList();
  }

  // These nodes aren't actually neighbours, but we don't want nodes to
  // ever overlap, so I'm making the ones that are close by neighbours
  Set<int> computeOverlappingNodes(Node n) {
    var _nodes = <int>{};
    for (var i = 0; i < nodes.length; i++) {
      var node = nodes[i];
      if (node.label == n.label) {
        continue;
      }

      var dx = node.x - n.x;
      var dy = node.y - n.y;

      var dist = sqrt((dx * dx) + (dy * dy));
      if (dist <= 60) {
        // print('${node.label} and ${n.label} are too close - $dist');
        var _ = _nodes.add(i);
      }
    }

    return _nodes;
  }

  Timer? layoutTimer;

  void startLayout() {
    if (layoutTimer != null) {
      return;
    }

    const interval = Duration(milliseconds: 25);
    layoutTimer = Timer.periodic(interval, (Timer t) {
      bool shouldStop = _updateGraphPositions(this);
      // print("shouldStop $shouldStop");
      if (shouldStop) {
        stopLayout();
      }
    });

    /*
    Timer(5.seconds, () {
      if (layoutTimer != null) {
        layoutTimer.cancel();
        layoutTimer = null;
      }
    });*/
  }

  void stopLayout() {
    if (layoutTimer != null) {
      layoutTimer!.cancel();
      layoutTimer = null;
    }
  }
}

class GraphNodeLayout {
  final double maxWidth;
  final double maxHeight;

  double x = 0.0;
  double y = 0.0;

  double startX = 60.0;
  double startY = 60.0;

  double gap = 70;
  double nodeSize = 50;

  GraphNodeLayout({required this.maxWidth, required this.maxHeight}) {
    x = startX;
    y = startY;
  }

  void positionNode(Node node) {
    node.x = x;
    node.y = y;

    x += gap;
    if (x + nodeSize >= maxWidth) {
      x = startX;
      y += gap;
    }
  }
}

//
// Basic Force Directed Layout
//
const l = 150.0; // sping rest length
const k_r = 1000.0; // repulsive force constant
const k_s = 20; // spring constant
const delta_t = 0.5; // time step
const MAX_DISPLACEMENT_SQUARED = 16;
const min_movement = 1.0;

/*
Original Values from main_graph.dart

const l = 150.0; // sping rest length
const k_r = 10000.0; // repulsive force constant
const k_s = 20; // spring constant
const delta_t = 0.005; // time step
const MAX_DISPLACEMENT_SQUARED = 16;
const min_movement = 1.0;
*/

bool _updateGraphPositions(Graph g) {
  var numNodes = g.nodes.length;

  // Initialize net forces
  for (var i = 0; i < numNodes; i++) {
    g.nodes[i].forceX = 0;
    g.nodes[i].forceY = 0;
  }

  for (var i1 = 0; i1 < numNodes - 1; i1++) {
    var node1 = g.nodes[i1];

    for (var i2 = i1 + 1; i2 < numNodes; i2++) {
      var node2 = g.nodes[i2];
      var dx = node2.x - node1.x;
      var dy = node2.y - node1.y;

      if (dx != 0 || dy != 0) {
        var distSq = (dx * dx) + (dy * dy);
        var distance = sqrt(distSq);

        var force = k_r / distSq;
        var fx = force * dx / distance;
        var fy = force * dy / distance;

        node1.forceX -= fx;
        node1.forceY -= fy;

        node2.forceX += fx;
        node2.forceY += fy;
      }
    }
  }

  // Spring forces between adjacent pairs
  for (var i1 = 0; i1 < numNodes; i1++) {
    var node1 = g.nodes[i1];
    var node1Neighbours = g.computeNeighbours(node1);

    for (var j = 0; j < node1Neighbours.length; j++) {
      var i2 = node1Neighbours[j]!;
      var node2 = g.nodes[i2];

      if (i1 < i2) {
        var dx = node2.x - node1.x;
        var dy = node2.y - node1.y;

        if (dx != 0 || dy != 0) {
          var distSq = (dx * dx) + (dy * dy);
          var distance = sqrt(distSq);

          var force = k_s * (distance - l);
          var fx = force * dx / distance;
          var fy = force * dy / distance;

          node1.forceX += fx;
          node1.forceY += fy;

          node2.forceX -= fx;
          node2.forceY -= fy;
        }
      }
    }
  }

  // Update positions
  var allBelowThreshold = true;
  for (var i = 0; i < numNodes; i++) {
    var node = g.nodes[i];

    // Skip Node which is current being controlled
    if (node.pressed) {
      continue;
    }

    var dx = delta_t * node.forceX;
    var dy = delta_t * node.forceY;

    var dispSq = (dx * dx) + (dy * dy);
    if (dispSq > MAX_DISPLACEMENT_SQUARED) {
      var s = sqrt(MAX_DISPLACEMENT_SQUARED / dispSq);

      dx *= s;
      dy *= s;
    }

    // print('${node.label} $dx $dy');
    if (node.x - dx <= g.nodeSize / 2) {
      node.x = (g.nodeSize / 2) + 1;
      continue;
    }
    if (node.y - dy <= g.nodeSize / 2) {
      node.y = (g.nodeSize / 2) + 1;
      continue;
    }

    node.x += dx;
    node.y += dy;

    if (dx.abs() > min_movement || dy.abs() > min_movement) {
      allBelowThreshold = false;
    }
  }
  // print('------------------');

  g.notify();
  return allBelowThreshold;
}
