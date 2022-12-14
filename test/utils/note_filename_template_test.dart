import 'package:test/test.dart';

import 'package:gitjournal/utils/note_filename_template.dart';

void main() {
  String renderTestTemplate(FileNameTemplate template, String? title) {
    return template.render(
      date: DateTime.parse('2022-02-27T19:00:00'),
      root: 'root',
      uuidv4: () => 'fake_uuid',
      title: title,
    );
  }

  group('valid FileNameTemplate', () {
    test('combining date and title + multiple title options', () async {
      final template = FileNameTemplate.parse(
          '{{date:fmt=yyyy_MM_dd}}_{{title:lowercase,snake_case}}');

      expect(
        renderTestTemplate(template, "Some note title"),
        '2022_02_27_some_note_title',
      );
    });

    test('title placeholder', () async {
      final template = FileNameTemplate.parse('{{title}}');

      expect(
        renderTestTemplate(template, null),
        "untitled",
      );
    });

    test('custom title placeholder', () async {
      final template =
          FileNameTemplate.parse('{{title:default=UNTITLED_NOTE}}');

      expect(
        renderTestTemplate(template, null),
        "UNTITLED_NOTE",
      );
    });

    test('title length', () async {
      final template = FileNameTemplate.parse('{{title:max_length=5}}');

      expect(
        renderTestTemplate(template, "Some note title"),
        "Some ",
      );
    });

    test('kebab case title', () async {
      final template = FileNameTemplate.parse('{{title:kebab_case}}');

      expect(
        renderTestTemplate(template, "Some note title with_underscores"),
        "Some-note-title-with_underscores",
      );
    });

    test('snake case title', () async {
      final template = FileNameTemplate.parse('{{title:snake_case}}');

      expect(
        renderTestTemplate(template, "Some note title with-hyphens"),
        "Some_note_title_with-hyphens",
      );
    });

    test('uppercase title', () async {
      final template = FileNameTemplate.parse('{{title:uppercase}}');

      expect(
        renderTestTemplate(template, "Some note title"),
        "SOME NOTE TITLE",
      );
    });

    test('default date format', () {
      final template = FileNameTemplate.parse('{{date}}');

      expect(
        renderTestTemplate(template, "Some note title"),
        '2022-02-27-19-00-00',
      );
    });

    test('lowercase title', () async {
      final template = FileNameTemplate.parse('{{title:lowercase}}');

      expect(
        renderTestTemplate(template, "Some note title"),
        "some note title",
      );
    });

    test('custom date format', () {
      final template = FileNameTemplate.parse('{{date:fmt=yyyy_MM_dd}}');

      expect(
        renderTestTemplate(template, "Some note title"),
        '2022_02_27',
      );
    });
  });

  group('Invalid FileNameTemplate', () {
    test('invalid date fmt', () {
      final template = FileNameTemplate.parse('{{date:fmt=invalid format!!}}');

      expect(
        () => renderTestTemplate(template, "Some note title"),
        throwsA(isA<Error>()),
      );
    });

    test('invalid template variable', () {
      final template = FileNameTemplate.parse('{{invalid_template_variable}}');

      expect(
        () => renderTestTemplate(template, "Some note title"),
        throwsA(isA<Exception>()),
      );
    });

    test('invalid option name', () {
      final template = FileNameTemplate.parse('{{title:invalid_option_name}}');

      expect(
        () => renderTestTemplate(template, "Some note title"),
        throwsA(isA<Exception>()),
      );
    });

    test('invalid template variable and option name', () {
      final template = FileNameTemplate.parse(
          '{{invalid_template_variable:invalid_option_name}}');

      expect(
        () => renderTestTemplate(template, "Some note title"),
        throwsA(isA<Exception>()),
      );
    });
  });
}
