import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/settings/widgets/settings_list_preference.dart';
import 'package:gitjournal/utils/note_filename_template.dart';

class NoteFileNameFormatPreference extends StatelessWidget {
  final NoteFileNameFormat Function() getFileNameFormatFromConfig;
  final void Function(NoteFileNameFormat format) setFileNameFormatInConfig;
  final String Function() getFileNameTemplateFromConfig;
  final void Function(String format) setFileNameFormatWithTemplateInConfig;

  const NoteFileNameFormatPreference({
    Key? key,
    required this.getFileNameFormatFromConfig,
    required this.setFileNameFormatInConfig,
    required this.getFileNameTemplateFromConfig,
    required this.setFileNameFormatWithTemplateInConfig,
  }) : super(key: key);

  NoteFileNameFormat get configFileNameFormat => getFileNameFormatFromConfig();
  set configFileNameFormat(NoteFileNameFormat format) =>
      setFileNameFormatInConfig(format);

  String get configTemplate => getFileNameTemplateFromConfig();
  set configTemplate(String format) =>
      setFileNameFormatWithTemplateInConfig(format);

  @override
  Widget build(
    BuildContext context,
  ) {
    return ListPreference(
      title: context.loc.settingsNoteNewNoteFileName,
      currentOption: configFileNameFormat.toPublicString(context),
      options: NoteFileNameFormat.options
          .map((f) => f.toPublicString(context))
          .toList(),
      onChange: (String publicStr) {
        var format = NoteFileNameFormat.fromPublicString(context, publicStr);
        if (format != NoteFileNameFormat.Template) {
          configFileNameFormat = format;
        } else {
          showTemplateDialog(context);
        }
      },
      optionLabelBuilder: ((currentOption, option) {
        if (option == NoteFileNameFormat.Template.toPublicString(context)) {
          return currentOption ==
                  NoteFileNameFormat.Template.toPublicString(context)
              ? Row(children: [
                  Text(
                    option,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      showTemplateDialog(context);
                    },
                    child: Text(context.loc.settingsEditorDefaultViewEdit),
                  )
                ])
              : Text(
                  option,
                );
        }

        return Text(
          option,
        );
      }),
    );
  }

  void showTemplateDialog(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (context) {
        return FileNameTemplatePreview(
          initialTemplateText: configTemplate,
          onSubmit: (value) {
            configTemplate = value;
          },
        );
      },
    );
  }
}

class FileNameTemplatePreview extends StatefulWidget {
  final void Function(String value) onSubmit;
  final String initialTemplateText;

  @override
  createState() => FileNameTemplatePreviewState();

  const FileNameTemplatePreview({
    required this.initialTemplateText,
    required this.onSubmit,
  });
}

class FileNameTemplatePreviewState extends State<FileNameTemplatePreview> {
  late TextEditingController _controller;
  late String _preview;
  late String _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTemplateText);
    setPreview(_controller.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(context.loc.settingsNoteFileNameFormatTemplateDialogTitle),
        actions: [
          TextButton(
            child: Text(context.loc.settingsOk),
            onPressed: _errorMessage.isEmpty
                ? () {
                    widget.onSubmit(_controller.text);

                    Navigator.of(context).pop();
                  }
                : null,
          ),
          TextButton(
            child: Text(context.loc.settingsCancel),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
        content: Column(
          children: [
            const TemplateInfoWidget(),
            TextField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              controller: _controller,
              enableSuggestions: false,
              enableIMEPersonalizedLearning: false,
              onChanged: (String value) {
                setState(() {
                  setPreview(value);
                });
              },
              style: const TextStyle(
                fontFamily: "monospace",
              ),
              decoration: InputDecoration(
                label: Text(
                  "Template text (without file extension)",
                  style: TextStyle(
                    fontFamily:
                        Theme.of(context).textTheme.bodyText1!.fontFamily,
                  ),
                ),
                errorMaxLines: 10,
                errorText: _errorMessage.isEmpty ? null : _errorMessage,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(
                top: 10,
              ),
              child: Text("Preview:"),
            ),
            Text(_preview.isEmpty ? "--" : _preview,
                style: const TextStyle(
                  fontFamily: "monospace",
                )),
          ],
        ));
  }

  void setPreview(String value) {
    try {
      final parsedTemplate = FileNameTemplate.parse(value);
      final validationResult = parsedTemplate.validate();
      if (validationResult is FileNameTemplateValidationSuccess) {
        _preview = parsedTemplate.render(
            date: DateTime.parse("2022-12-03T10:54:42"),
            title: "This Is An Example Note Title",
            uuidv4: () => "12345678-1234-1234-1234-1234567890ab");
        _errorMessage = "";
      } else {
        _preview = "";
        _errorMessage =
            (validationResult as FileNameTemplateValidationFailure).message;
      }
    } catch (e) {
      _preview = "";
      _errorMessage =
          "Invalid template. Please check that all curly braces are closed.";
    }
  }
}

class TemplateInfoWidget extends StatelessWidget {
  const TemplateInfoWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: Scrollbar(
        thumbVisibility: true,
        trackVisibility: true,
        thickness: 10, //width of scrollbar
        radius: Radius.circular(20), //corner radius of scrollbar
        scrollbarOrientation:
            ScrollbarOrientation.right, //which side to show scrollbar
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Text(
            templateFormatHelperText,
            style: TextStyle(
              fontSize: 10,
              fontFeatures: [FontFeature.tabularFigures()],
              fontFamily: "monospace",
            ),
          ),
        ),
      ),
    );
  }
}
