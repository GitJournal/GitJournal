import 'package:markd/markdown.dart' as md;

import 'package:gitjournal/core/note.dart';

class ChecklistItem {
  md.Element parentListElement;
  md.Element element;

  bool get checked {
    if (element.children == null || element.children.isEmpty) {
      return false;
    }

    var inputEl = element.children[0] as md.Element;
    assert(inputEl.attributes['class'] == 'todo');
    return inputEl.attributes.containsKey('checked');
  }

  set checked(bool val) {
    if (element.children == null || element.children.isEmpty) {
      return;
    }
    var inputEl = element.children[0] as md.Element;
    assert(inputEl.attributes['class'] == 'todo');

    if (val) {
      inputEl.attributes["checked"] = "checked";
    } else {
      inputEl.attributes.remove('checked');
    }
  }

  String get text {
    if (element.children == null || element.children.isEmpty) {
      return "";
    }
    if (element.children.length > 1) {
      return element.children[1].textContent.substring(1);
    }
    return "";
  }

  set text(String val) {
    if (element.children == null || element.children.isEmpty) {
      return;
    }
    if (element.children.length > 1) {
      element.children[1] = md.Text(" $val");
    }
  }

  ChecklistItem.fromMarkdownElement(this.element, this.parentListElement) {
    assert(element.children.isNotEmpty);

    // FIXME: Maybe this shouldn't be allowed
    if (parentListElement != null) {
      assert(parentListElement.children.contains(element));
    }
  }

  @override
  String toString() => 'ChecklistItem: $checked $text';
}

class Checklist {
  Note _note;
  List<ChecklistItem> items;

  List<md.Node> _nodes;

  Checklist(this._note) {
    var doc = md.Document(
      encodeHtml: false,
      blockSyntaxes: md.BlockParser.standardBlockSyntaxes,
      extensionSet: md.ExtensionSet.gitHubWeb,
    );

    _nodes = doc.parseLines(_note.body.split('\n'));
    for (var node in _nodes) {
      if (node is md.Element) {
        var elem = node;
        _printElement(elem, "");
      }
    }
    print('---------');

    var builder = ChecklistBuilder();
    items = builder.build(_nodes);
  }

  void _printElement(md.Element elem, String indent) {
    print("$indent Begin ${elem.toString()}");
    print("$indent E TAG ${elem.tag}");
    print("$indent E ATTRIBUTES ${elem.attributes}");
    print("$indent E generatedId ${elem.generatedId}");
    print("$indent E children ${elem.children}");
    if (elem.children != null) {
      for (var child in elem.children) {
        if (child is md.Element) {
          _printElement(child, indent + "  ");
        } else {
          print("$indent $child - ${child.textContent}");
        }
      }
    }
    print("$indent End ${elem.toString()}");
  }

  Note get note {
    if (_nodes.isEmpty) return _note;

    // Remove empty trailing items
    while (true) {
      if (items.isEmpty) {
        break;
      }
      var item = items.last;
      if (item.checked == false && item.text.trim().isEmpty) {
        removeAt(items.length - 1);
      } else {
        break;
      }
    }

    var renderer = MarkdownRenderer();
    _note.body = renderer.render(_nodes);

    return _note;
  }

  @override
  String toString() {
    return [
      '[',
      items.map((x) => x.toString()).join(', '),
      ']',
    ].join(' ');
  }

  ChecklistItem buildItem(bool value, String text) {
    var inputElement = md.Element.withTag('input');
    inputElement.attributes['class'] = 'todo';
    inputElement.attributes['type'] = 'checkbox';
    inputElement.attributes['disabled'] = 'disabled';
    if (value) {
      inputElement.attributes['checked'] = 'checked';
    }

    var liElement = md.Element('li', [inputElement, md.Text(' $text')]);
    liElement.attributes['class'] = 'todo';

    // FIXME: Come on, there must be a simpler way
    return ChecklistItem.fromMarkdownElement(liElement, null);
  }

  void removeItem(ChecklistItem item) {
    assert(items.contains(item));
    items.remove(item);

    bool foundChild = false;
    var parentList = item.parentListElement;
    for (var i = 0; i < parentList.children.length; i++) {
      var child = parentList.children[i];
      if (child == item.element) {
        foundChild = true;
        parentList.children.removeAt(i);
        break;
      }
    }
    assert(foundChild);
  }

  ChecklistItem removeAt(int index) {
    assert(index >= 0 && index <= items.length);

    var item = items[index];
    removeItem(item);

    return item;
  }

  void addItem(ChecklistItem item) {
    if (items.isEmpty) {
      var listElement = md.Element.withTag('ul');
      _nodes.add(listElement);
      item.parentListElement = listElement;
    } else {
      var prevItem = items.last;
      item.parentListElement = prevItem.parentListElement;
    }

    items.add(item);
    item.parentListElement.children.add(item.element);
  }

  void insertItem(int index, ChecklistItem item) {
    if (index == 0 && items.isEmpty) {
      addItem(item);
      return;
    }

    assert(index <= items.length, "Trying to insert beyond the end");
    if (index == items.length) {
      addItem(item);
      return;
    }

    var prevItem = index - 1 > 0 ? items[index - 1] : items[index];
    item.parentListElement = prevItem.parentListElement;
    var parentList = item.parentListElement;

    // Insert in correct place
    bool foundChild = false;
    for (var i = 0; i < parentList.children.length; i++) {
      var child = parentList.children[i];
      if (child == prevItem.element) {
        foundChild = true;
        parentList.children.insert(i, item.element);
        break;
      }
    }
    assert(foundChild);

    items.insert(index, item);
  }
}

class ChecklistBuilder implements md.NodeVisitor {
  List<ChecklistItem> list;
  md.Element listElement;
  md.Element parent;

  @override
  bool visitElementBefore(md.Element element) {
    if (element.tag == 'ul' || element.tag == 'ol') {
      listElement = element;
    }
    return true;
  }

  @override
  void visitText(md.Text text) {
    //print("builder text: ${text.text}#");
  }

  @override
  void visitElementAfter(md.Element el) {
    final String tag = el.tag;

    if (tag == 'ul' || tag == 'ol') {
      listElement = null;
      return;
    }

    if (tag == 'li') {
      if (el.attributes['class'] == 'todo') {
        list.add(ChecklistItem.fromMarkdownElement(el, listElement));
        return;
      }
    }
    //print("builder tag: $tag");
  }

  List<ChecklistItem> build(List<md.Node> nodes) {
    list = <ChecklistItem>[];
    for (md.Node node in nodes) {
      node.accept(this);
    }

    return list;
  }
}

class MarkdownRenderer implements md.NodeVisitor {
  StringBuffer buffer;

  @override
  bool visitElementBefore(md.Element element) {
    switch (element.tag) {
      case 'h1':
        buffer.write('# ');
        break;

      case 'h2':
        buffer.write('## ');
        break;

      case 'h3':
        buffer.write('### ');
        break;

      case 'h4':
        buffer.write('#### ');
        break;

      case 'h5':
        buffer.write('##### ');
        break;

      case 'h6':
        buffer.write('###### ');
        break;

      case 'li':
        buffer.write('- ');
        break;

      case 'p':
      case 'ul':
        buffer.write('\n');
        break;
    }
    return true;
  }

  @override
  void visitText(md.Text text) {
    //print("visitText ${text.text}#");
    buffer.write(text.text);
  }

  @override
  void visitElementAfter(md.Element element) {
    final String tag = element.tag;

    if (tag == 'input') {
      var attr = element.attributes;
      print(attr);
      if (attr['class'] == 'todo' && attr['type'] == 'checkbox') {
        bool val = attr.containsKey('checked');
        if (val) {
          buffer.write('[x]');
        } else {
          buffer.write('[ ]');
        }
      }
      return;
    }

    switch (tag) {
      case 'h1':
      case 'h2':
      case 'h3':
      case 'h4':
      case 'h5':
      case 'h6':
      case 'p':
      case 'li':
        buffer.write('\n');
        break;
    }
  }

  String render(List<md.Node> nodes) {
    buffer = StringBuffer();

    for (final node in nodes) {
      node.accept(this);
    }
    return buffer.toString();
  }
}
