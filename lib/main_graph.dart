import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:touchable/touchable.dart';

class MyExampleWidget extends StatefulWidget {
  @override
  _MyExampleWidgetState createState() => _MyExampleWidgetState();
}

class _MyExampleWidgetState extends State<MyExampleWidget> {
  Graph graph;

  @override
  void initState() {
    super.initState();

    var a = Node("A", 30, 30);
    var b = Node("B", 200, 200);
    var c = Node("C", 200, 100);
    var d = Node("D", 300, 300);
    var e = Node("E", 300, 100);

    var edges = <Edge>[
      Edge(a, b),
      Edge(a, c),
      Edge(b, d),
      Edge(b, e),
      Edge(e, c),
    ];

    graph = Graph();
    graph.nodes = [a, b, c, d, e];
    graph.edges = edges;

    graph.assignRandomPositions(400, 650);

    const interval = Duration(milliseconds: 25);
    bool shouldStop = false;
    var timer = Timer.periodic(interval, (Timer t) {
      if (shouldStop) {
        return;
      }
      shouldStop = updateGraphPositions(graph);
    });

    Timer(const Duration(seconds: 5), () => timer.cancel());
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).nextFocus();
    return CanvasTouchDetector(
      builder: (context) {
        return CustomPaint(
          painter: MyPainter(context, graph),
        );
      },
    );
  }
}

class MyPainter extends CustomPainter {
  final BuildContext context;
  final Graph graph;

  MyPainter(this.context, this.graph) : super(repaint: graph);

  @override
  void paint(Canvas canvas, Size size) {
    var myCanvas = TouchyCanvas(context, canvas);

    // Draw all the edges
    for (var edge in graph.edges) {
      myCanvas.drawLine(
        Offset(edge.a.x, edge.a.y),
        Offset(edge.b.x, edge.b.y),
        Paint()
          ..color = Colors.grey
          ..strokeWidth = 2.5,
        onPanUpdate: (detail) {
          print('Edge ${edge.a.label} -> ${edge.b.label} Swiped');
        },
      );
    }

    // Draw all the nodes
    for (var node in graph.nodes) {
      myCanvas.drawCircle(
        Offset(node.x, node.y),
        20,
        Paint()..color = Colors.orange,
        onPanStart: (tapdetail) {
          node.pressed = true;
          print('$node Pan start - $tapdetail');

          node.x = tapdetail.localPosition.dx;
          node.y = tapdetail.localPosition.dy;

          graph.notify();
        },
        onPanDown: (tapdetail) {
          node.pressed = false;
          print('$node PanEnd - $tapdetail');
          node.x = tapdetail.localPosition.dx;
          node.y = tapdetail.localPosition.dy;

          graph.notify();
        },
        onPanUpdate: (tapdetail) {
          print('$node PanUpdate - $tapdetail');

          node.x = tapdetail.localPosition.dx;
          node.y = tapdetail.localPosition.dy;
          graph.notify();
        },
        /*
        onTapDown: (details) {
          print("$node onTapDown - $details");
        },
        onTapUp: (details) {
          print("$node onTapUp - $details");
        },*/
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class Node {
  String label = "";
  double x;
  double y;
  bool pressed = false;

  double forceX = 0.0;
  double forceY = 0.0;

  Node(this.label, this.x, this.y);

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

  Map<String, List<int>> _neighbours = {};
  Map<String, int> _nodeIndexes;

  void notify() {
    notifyListeners();
  }

  List<int> computeNeighbours(Node n) {
    if (_nodeIndexes == null) {
      _nodeIndexes = <String, int>{};
      for (var i = 0; i < this.nodes.length; i++) {
        var node = this.nodes[i];
        _nodeIndexes[node.label] = i;
      }
    }

    var _nodes = _neighbours[n.label];
    if (_nodes != null) {
      return _nodes;
    }

    var nodes = <int>{};
    for (var edge in edges) {
      if (edge.a.label == n.label) {
        nodes.add(_nodeIndexes[edge.b.label]);
        continue;
      }

      if (edge.b.label == n.label) {
        nodes.add(_nodeIndexes[edge.a.label]);
        continue;
      }
    }

    _nodes = nodes.toList();
    _neighbours[n.label] = _nodes;
    return _nodes;
  }

  void assignRandomPositions(int maxX, int maxY) {
    var random = Random(DateTime.now().millisecondsSinceEpoch);

    for (var node in nodes) {
      node.x = random.nextInt(maxX).toDouble();
      node.y = random.nextInt(maxY).toDouble();
    }

    notifyListeners();
  }
}

void main() => runApp(MyApp());

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  static const String _title = 'Graphs Experiments';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: MyWidget(),
    );
  }
}

class MyWidget extends StatelessWidget {
  MyWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: 700,
        width: 500,
        child: MyExampleWidget(),
      ),
    );
  }
}

// FIXME: Possibly use directed_graph library?

//
// Basic Force Directed Layout
//

const l = 150.0; // sping rest length
const k_r = 10000.0; // repulsive force constant
const k_s = 20; // spring constant
const delta_t = 0.005; // time step
const MAX_DISPLACEMENT_SQUARED = 16;
const min_movement = 1.0;

bool updateGraphPositions(Graph g) {
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
      var i2 = node1Neighbours[j];
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

    var dx = delta_t * node.forceX;
    var dy = delta_t * node.forceY;

    var dispSq = (dx * dx) + (dy * dy);
    if (dispSq > MAX_DISPLACEMENT_SQUARED) {
      var s = sqrt(MAX_DISPLACEMENT_SQUARED / dispSq);

      dx *= s;
      dy *= s;
    }

    print('${node.label} $dx $dy');
    node.x += dx;
    node.y += dy;

    if (dx.abs() > min_movement || dy.abs() > min_movement) {
      allBelowThreshold = false;
    }
  }
  print('------------------');

  g.notify();
  return allBelowThreshold;
}
