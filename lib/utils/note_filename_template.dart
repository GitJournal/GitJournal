import 'package:collection/collection.dart';
import 'package:gitjournal/utils/datetime.dart';
import 'package:intl/intl.dart';

class FileNameTemplate {
  List<_TemplateSegment> segments;

  FileNameTemplate(this.segments);

  static FileNameTemplate parse(String template) {
    return FileNameTemplate(_parseTemplate(template));
  }

  FileNameTemplateValidationResult validate() {
    final segmentsIncludeTitle =
        segments.any((segment) => segment.variableName == 'title');
    final segmentsIncludeDate =
        segments.any((segment) => segment.variableName == 'date');
    final segmentsIncludeUuid =
        segments.any((segment) => segment.variableName == 'uuidv4');
    if (!segmentsIncludeTitle && !segmentsIncludeDate && !segmentsIncludeUuid) {
      return const FileNameTemplateValidationFailure(
          "Template must include {{title}} or {{date}} or {{uuidv4}}");
    }
    final segmentVariableErrors = segments.expand((segment) {
      if (!segment.isVariable()) {
        return [];
      }
      final optionNames =
          Set.from(segment.variableOptions?.keys.toList() ?? []);
      final validOptionNames =
          validTemplateVariablesAndOptions[segment.variableName] ?? {};
      final invalidOptionNames = optionNames.difference(validOptionNames);
      if (invalidOptionNames.isNotEmpty) {
        return invalidOptionNames.length == 1 &&
                invalidOptionNames.firstOrNull == ""
            ? ["Please specify options for variable ${segment.variableName}."]
            : [
                "Invalid option(s) for variable ${segment.variableName}: ${invalidOptionNames.join(', ')}"
              ];
      }

      if (segmentsIncludeTitle) {
        final titleSegment =
            segments.firstWhere((segment) => segment.variableName == 'title');
        try {
          _renderTitle(titleSegment.text, titleSegment.variableOptions);
        } catch (e) {
          return ["Invalid title format: ${titleSegment.text}"];
        }
      }

      return [];
    });
    if (segmentVariableErrors.isNotEmpty) {
      return FileNameTemplateValidationFailure(
          segmentVariableErrors.join('; '));
    }

    return const FileNameTemplateValidationSuccess();
  }

  String render({
    required DateTime date,
    required String Function() uuidv4,
    String? title,
  }) {
    final renderedSegments = segments.map((segment) {
      if (segment.variableName == null) {
        return segment.text;
      } else if (segment.variableName == 'date') {
        return _renderDate(date, segment.variableOptions);
      } else if (segment.variableName == 'title') {
        return _renderTitle(title, segment.variableOptions);
      } else if (segment.variableName == 'uuidv4') {
        return uuidv4();
      } else {
        throw Exception(
            "Unknown template variable {{${segment.variableName}}}");
      }
    });
    return renderedSegments.join();
  }
}

abstract class FileNameTemplateValidationResult {
  const FileNameTemplateValidationResult();
}

class FileNameTemplateValidationSuccess
    extends FileNameTemplateValidationResult {
  const FileNameTemplateValidationSuccess();
}

class FileNameTemplateValidationFailure
    extends FileNameTemplateValidationResult {
  const FileNameTemplateValidationFailure(this.message);

  final String message;
}

List<_TemplateSegment> _parseTemplate(String template) {
  final List<_TemplateSegment> segments = [];
  var resolvingVariable = false;

  template.splitMapJoin(
    RegExp("{{|}}"),
    onMatch: (match) {
      if (match[0] == '{{') {
        if (resolvingVariable) {
          throw Exception("Unexpected '{{' at ${match.start}");
        }
        resolvingVariable = true;
      } else {
        if (!resolvingVariable) {
          throw Exception("Unexpected '}}' at ${match.start}");
        }
        resolvingVariable = false;
      }
      return '';
    },
    onNonMatch: (text) {
      if (resolvingVariable) {
        final variableSegments = text.split(':');
        final variableName = variableSegments[0];
        final List<String> optionsSegments =
            variableSegments.length == 1 ? [] : variableSegments[1].split(',');

        final variableOptions =
            Map.fromEntries(optionsSegments.map((optionText) {
          final optionSegments = optionText.split('=');
          if (optionSegments.length > 2) {
            throw Exception("ption for $variableName `$optionText`");
          }
          return MapEntry(
            optionSegments[0],
            optionSegments.length == 1 ? 'true' : optionSegments[1],
          );
        }));
        segments.add(_TemplateSegment(text, variableName, variableOptions));
      } else {
        segments.add(_TemplateSegment(text, null, null));
      }
      return text;
    },
  );

  if (resolvingVariable) {
    throw Exception("Unexpected end of template");
  }

  return segments;
}

class _TemplateSegment {
  final String text;
  String? variableName;
  Map<String, String>? variableOptions;

  _TemplateSegment(this.text, this.variableName, this.variableOptions);

  isVariable() => variableName != null;
}

String _renderDate(DateTime date, Map<String, String>? variableOptions) {
  var result = formatDate(date, variableOptions);

  if (variableOptions != null && variableOptions['lowercase'] == 'true') {
    result = result.toLowerCase();
  } else if (variableOptions != null &&
      variableOptions['uppercase'] == 'true') {
    result = result.toUpperCase();
  }

  return result;
}

String _renderTitle(String? titleInput, Map<String, String>? variableOptions) {
  final defaultTitleOption = variableOptions?['default'];
  final defaultTitle = defaultTitleOption == null || defaultTitleOption.isEmpty
      ? 'Untitled'
      : defaultTitleOption;
  var title = (titleInput ?? defaultTitle)
      // Sanitize the title - these characters are not allowed in Windows
      .replaceAll(RegExp(r'[/<\>":|?*]'), '_');
  ;

  if (variableOptions == null) {
    return title;
  }

  if (variableOptions['lowercase'] == 'true') {
    title = title.toLowerCase();
  } else if (variableOptions['uppercase'] == 'true') {
    title = title.toUpperCase();
  }

  if (variableOptions['snake_case'] == 'true') {
    title = title.replaceAll(RegExp(r'\s+'), '_');
  } else if (variableOptions['kebab_case'] == 'true') {
    title = title.replaceAll(RegExp(r'\s+'), '-');
  }

  if (variableOptions['max_length'] != null) {
    try {
      final maxLength = int.parse(variableOptions['max_length']!);
      if (title.length > maxLength) {
        title = title.substring(0, maxLength);
      }
    } catch (e) {
      throw Exception("Invalid max_length: ${variableOptions['max_length']}");
    }
  }

  return title;
}

final Map<String, Set<String>> validTemplateVariablesAndOptions = {
  'date': {'lowercase', 'uppercase', 'date_only', 'hyphens', 'zettel', 'fmt'},
  'title': {
    'lowercase',
    'uppercase',
    'snake_case',
    'kebab_case',
    'max_length',
    'default'
  },
  'uuidv4': {},
};

final dateFormatOptions = {'date_only', 'hyphens', 'zettel', 'fmt'};

String formatDate(DateTime date, Map<String, String>? options) {
  if (options == null) {
    return toSimpleDateTime(date);
  }
  final presentFormatOptions =
      options.keys.toSet().intersection(dateFormatOptions);
  if (presentFormatOptions.length > 1) {
    throw Exception(
        "Only one of ${dateFormatOptions.join(', ')} can be specified");
  }

  final formatOption = presentFormatOptions.toList().firstOrNull ?? 'hyphens';
  switch (formatOption) {
    case 'hyphens':
      return toSimpleDateTime(date);
    case 'zettel':
      return toZettleDateTime(date);
    case 'date_only':
      return DateFormat('yyyy-MM-dd').format(date);
    case 'fmt':
      final fmtOptionIsBlank = (options['fmt'] == null ||
          options['fmt'] == 'true' ||
          options['fmt'] == '');
      return fmtOptionIsBlank
          ? toSimpleDateTime(date)
          : DateFormat(options['fmt']).format(date);
    default:
      throw Exception("Invalid date format option: $formatOption");
  }
}

const templateFormatHelperText = """
Templates can include the following variables,
replaced with the appropriate values when the
note is created.

Template variables are written between
double curly braces, with any options
specified after a colon.

For example:
  TEMPLATE:
     {{date}}_{{title:snake_case}}
  RESULT:
     2022-01-05_Title_of_the_note

AVAILABLE TEMPLATE VARIABLES:

{{date}} - The date and time at note creation.
  OPTIONS:              
    hyphens - YYYY-MM-DD-HH-mm-SS
              (the default format)
    date_only - YYYY-MM-DD
              (same as default format, but
               without the time)
    zettel - YYYYMMDDHHmmSS
              (Zettelkasten format)
    fmt - Use a custom format. The format is
          specified according to the ICU/JDK
          date/time pattern specification.
          For example:
              {{date:fmt=YY-MMMM-DD}}
            produces a result like:
              22-January-05
    lowercase - Make all characters lowercase
                after applying formatting.
    uppercase - Make all characters uppercase
                after applying formatting.
{{title}} - The title of the note.
    OPTIONS:
      lowercase - Make all characters lowercase.
      uppercase - Make all characters uppercase.
      snake_case - Convert to snake_case.
      kebab_case - Convert to kebab-case.
      max_length - Truncate the title to a
                   maximum length.
                   For example:
                     {{title:max_length=10}}
      default - Set the default title if the
                title is empty.
                Defaults to "Untitled".
                For example:
                  {{title:default=Untitled-note}}
  {{uuidv4}} - A random UUIDv4 string.


Multiple options may be specified for a variable, separated commas.
For example:
  {{title:lowercase,snake_case}}
            """;
