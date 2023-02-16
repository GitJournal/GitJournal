/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:d3_force_flutter/d3_force_flutter.dart' as f;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/core/graph2.dart';
import 'package:gitjournal/core/views/note_links_view.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/widgets/app_drawer.dart';
import 'package:provider/provider.dart';

class GraphViewScreen extends StatelessWidget {
  static const routePath = '/graph';

  const GraphViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var rootFolder = Provider.of<NotesFolderFS>(context);
    var linksView = NoteLinksProvider.of(context);

    return _GraphViewScreen(
      rootFolder: rootFolder,
      linksView: linksView,
    );
  }
}

class _GraphViewScreen extends StatefulWidget {
  final NotesFolderFS rootFolder;
  final NoteLinksView linksView;

  const _GraphViewScreen({
    required this.rootFolder,
    required this.linksView,
  });

  @override
  _GraphViewScreenState createState() => _GraphViewScreenState();
}

class _GraphViewScreenState extends State<_GraphViewScreen> {
  Graph? graph;

  @override
  void initState() {
    super.initState();

    () async {
      graph = await buildGraph(widget.rootFolder, widget.linksView);
      Log.i("Finished building the graph ...");

      Log.i('nodes: ${graph!.nodes.length}');
      Log.i('edges: ${graph!.edges.length}');
    }();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text(context.loc.drawerGraph),
      ),
      body: graph != null ? GraphView(graph!) : Container(),
    );
  }
}

class _GraphListenable extends ChangeNotifier {
  _GraphListenable();

  void notify() {
    notifyListeners();
  }
}

class GraphView extends StatefulWidget {
  final Graph graph;

  const GraphView(this.graph);

  @override
  _GraphViewState createState() => _GraphViewState();
}

class _GraphViewState extends State<GraphView>
    with SingleTickerProviderStateMixin {
  final nodeSize = 50.0;
  late TransformationController transformationController;

  late final f.ForceSimulation simulation;
  late final Ticker _ticker;
  late final Size _size;
  late final _GraphListenable _graphListenable;

  @override
  void initState() {
    super.initState();

    _size = const Size(2500, 2500);
    var graph = widget.graph;

    const _m = 1.0;

    simulation = f.ForceSimulation(
      phyllotaxisX: _size.width / 2,
      phyllotaxisY: _size.height / 2,
      phyllotaxisRadius: 20,
    )
      ..nodes = graph.nodes
      ..setForce('collide', f.Collide(radius: 10 * _m))
      // ..setForce('radial', f.Radial(radius: 400 * _m))
      ..setForce('manyBody', f.ManyBody(strength: -40 * 3.0 * _m))
      // ..setForce(
      //     'center', f.Center(size.width / 2, size.height / 2, strength: 0.5))
      ..setForce(
        'edges',
        f.Edges(edges: graph.edges, distance: 30 * 3.0 * _m),
      )
      ..setForce('x', f.XPositioning(x: _size.width / 2))
      ..setForce('y', f.YPositioning(y: _size.height / 2))
      ..alpha = 1;

    _graphListenable = _GraphListenable();

    _ticker = createTicker((_) {
      // print("tick ...");
      setState(() {
        simulation.tick();
      });
      _graphListenable.notify();
    })
      ..start();

    transformationController = TransformationController();
  }

  @override
  void dispose() {
    _ticker.dispose();

    super.dispose();
  }

  // Offset _getLocationPosition(Offset globalPos) {
  //   RenderBox graphViewRenderBox = context.findRenderObject() as RenderBox;

  //   var pos = graphViewRenderBox.globalToLocal(globalPos);
  //   var matrix = transformationController.value;

  //   return MatrixUtils.transformPoint(Matrix4.inverted(matrix), pos);
  // }

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[];

    children.add(CustomPaint(
      painter: GraphEdgePainter(widget.graph, _graphListenable),
    ));

    for (var node in widget.graph.nodes) {
      if (node.x.isNaN || node.y.isNaN) {
        continue;
      }

      var w = Positioned(
        left: node.x - (nodeSize / 2),
        top: node.y - (nodeSize / 2),
        width: nodeSize,
        child: GestureDetector(
          child: NodeWidget(node, nodeSize),
          // onPanStart: (details) {
          //   var pos = _getLocationPosition(details.globalPosition);
          //   node.x = pos.dx;
          //   node.y = pos.dy;
          //   // node.pressed = true;

          //   if (node.y <= nodeSize / 2) {
          //     node.y = nodeSize / 2;
          //   }
          //   if (node.x <= nodeSize / 2) {
          //     node.x = nodeSize / 2;
          //   }

          //   // widget.graph.notify();
          //   // print("Pan start ${node.label} $pos");
          // },
          // onPanEnd: (DragEndDetails details) {
          //   // print("Pan end ${node.label} $details");
          //   // node.pressed = false;
          //   // widget.graph.notify();
          // },
          // onPanUpdate: (details) {
          //   var pos = _getLocationPosition(details.globalPosition);
          //   node.x = pos.dx;
          //   node.y = pos.dy;

          //   if (node.y <= nodeSize / 2) {
          //     node.y = nodeSize / 2;
          //   }
          //   if (node.x <= nodeSize / 2) {
          //     node.x = nodeSize / 2;
          //   }

          //   // widget.graph.notify();
          //   // print("Pan update ${node.label} $pos");
          // },
        ),
      );
      children.add(w);
    }

    var view = Container(
      width: 2500,
      height: 2500,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Stack(
        fit: StackFit.expand,
        children: children,
      ),
    );

    return InteractiveViewer(
      panEnabled: true,
      constrained: false,
      minScale: 0.1,
      transformationController: transformationController,
      child: view,
    );
  }
}

class GraphEdgePainter extends CustomPainter {
  final _GraphListenable graphListenable;
  final Graph graph;

  GraphEdgePainter(this.graph, this.graphListenable)
      : super(repaint: graphListenable);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw all the edges
    for (var edge in graph.edges) {
      var strokeWitdth = 2.5;

      // FIXME: Pressed
      // if (edge.source.pressed || edge.target.pressed) {
      //   strokeWitdth *= 2;
      // }

      // print('s ${Offset(edge.source.x, edge.source.y)}');
      // print('t ${Offset(edge.target.x, edge.target.y)}');

      var source = edge.source;
      if (source.x.isNaN || source.y.isNaN) {
        continue;
      }

      var target = edge.target;
      if (target.x.isNaN || target.y.isNaN) {
        continue;
      }

      canvas.drawLine(
        Offset(source.x, source.y),
        Offset(target.x, target.y),
        Paint()
          ..color = Colors.green
          ..strokeWidth = strokeWitdth,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class NodeWidget extends StatelessWidget {
  final NoteNode node;
  final double size;

  const NodeWidget(this.node, this.size);

  @override
  Widget build(BuildContext context) {
    var debug = node.note.filePath == 'docs/eleventy-and-netlify.md';
    if (debug) {
      // print("building .. ${node.note.filePath} ${node.x} ${node.y}");
    }

    var theme = Theme.of(context);
    var textStyle = theme.textTheme.titleMedium!.copyWith(fontSize: 8.0);

    var label = node.note.filePath;
    // if (label.startsWith('docs/')) {
    //   label = label.substring(5);
    // }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
            border: Border.all(
              width: 1,
              color: Colors.black,
              style: BorderStyle.solid,
            ),
          ),
        ),
        Text(label, style: textStyle),
      ],
    );
  }
}

// TODO:
// - Place it somewhere in the middle and scroll to that position
// - Render the graph in a circular layout
// - Make start positions of Nodes not block
// - Figure out the ideal bounding box of the Graph (just make it double?)
