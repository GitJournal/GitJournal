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
    print("Paint");
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
        30,
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

  void notify() {
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
      appBar: AppBar(
        title: const Text('Sample Code'),
      ),
      body: Container(
        height: 500,
        width: 500,
        child: MyExampleWidget(),
      ),
    );
  }
}

// FIXME: Possibly use directed_graph library?
