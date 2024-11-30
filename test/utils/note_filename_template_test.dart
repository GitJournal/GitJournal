import 'package:gitjournal/utils/note_filename_template.dart';
import 'package:test/test.dart';

void main() {
  group('valid FileNameTemplate', () {
    String renderTestTemplate(FileNameTemplate template, String? title) {
      if (template is FileNameTemplateValidationFailure) {
        throw Exception(
            (template as FileNameTemplateValidationFailure).message);
      }
      expect(template.validate(), isA<FileNameTemplateValidationSuccess>());

      return template.render(
        date: DateTime.parse('2022-02-27T19:00:00'),
        uuidv4: () => 'fake_uuid',
        title: title,
      );
    }

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
        "Untitled",
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

    test('preset date format', () {
      final template = FileNameTemplate.parse('{{date:simple}}');

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
    test("malformed template", () {
      expect(
        () {
          FileNameTemplate.parse('{{date:fmt=yyyy_MM_dd');
        },
        throwsException,
      );
    });

    test('no unique identifier in template', () {
      final template = FileNameTemplate.parse('static_file_name');

      expect(
        template.validate(),
        isA<FileNameTemplateValidationFailure>(),
      );
    });

    test('invalid date fmt', () {
      final template = FileNameTemplate.parse('{{date:fmt=invalid format!!}}');

      expect(
        template.validate(),
        isA<FileNameTemplateValidationFailure>(),
      );
    });

    test('multiple date format options', () {
      final template = FileNameTemplate.parse('{{date:simple,zettel}}');

      expect(template.validate(), isA<FileNameTemplateValidationFailure>());
    });

    test('invalid template variable', () {
      final template = FileNameTemplate.parse('{{invalid_template_variable}}');

      expect(
        template.validate(),
        isA<FileNameTemplateValidationFailure>(),
      );
    });

    test('invalid option name', () {
      final template = FileNameTemplate.parse('{{title:invalid_option_name}}');

      expect(
        template.validate(),
        isA<FileNameTemplateValidationFailure>(),
      );
    });

    test('invalid title max_length value', () {
      final template = FileNameTemplate.parse('{{title:max_length=qqq}}');

      expect(
        template.validate(),
        isA<FileNameTemplateValidationFailure>(),
      );
    });

    test('invalid template variable and option name', () {
      final template = FileNameTemplate.parse(
          '{{invalid_template_variable:invalid_option_name}}');

      expect(
        template.validate(),
        isA<FileNameTemplateValidationFailure>(),
      );
    });
  });
}
