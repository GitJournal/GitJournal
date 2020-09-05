import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:gitjournal/analytics.dart';
import 'package:gitjournal/features.dart';

class FeatureTimelineScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('feature_timeline.title')),
      ),
      body: ListView(
        children: [
          for (var feature in Features.all) FeatureTile(feature),
          for (var title in Features.inProgress)
            _Tile(
              title: title,
              subTitle: tr('feature_timeline.progress'),
              iconText: "DEV",
              iconColor: theme.primaryColorDark,
            ),
          for (var title in Features.planned)
            _Tile(
              title: title,
              subTitle: tr('feature_timeline.plan'),
              iconText: "PLAN",
              iconColor: theme.accentColor,
            ),
          _DevelopmentText(),
        ],
      ),
    );
  }
}

class FeatureTile extends StatelessWidget {
  final Feature feature;

  FeatureTile(this.feature);

  @override
  Widget build(BuildContext context) {
    var dateStr = feature.date.toIso8601String().substring(0, 10);
    var subtitle = dateStr;
    if (feature.subtitle.isNotEmpty) {
      subtitle += ' - ' + feature.subtitle;
    }

    Color color;
    var theme = Theme.of(context);

    if (feature.pro) {
      if (theme.brightness == Brightness.light) {
        color = theme.primaryColor;
      }
    } else {
      color = theme.accentColor;
    }

    return _Tile(
      title: feature.title,
      subTitle: subtitle,
      iconText: feature.pro ? 'PRO' : "FREE",
      iconColor: color,
    );
  }
}

class _Tile extends StatelessWidget {
  final String title;
  final String subTitle;
  final String iconText;
  final Color iconColor;

  _Tile({
    @required this.title,
    @required this.subTitle,
    @required this.iconText,
    @required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textTheme = theme.textTheme;
    var titleTextStyle = textTheme.subtitle1.copyWith();
    var subTitleTextStyle = textTheme.bodyText2.copyWith(
      color: textTheme.caption.color,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 16.0,
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 56.0,
            child: _Sign(iconText, iconColor),
          ),
          Expanded(
            child: Column(
              children: [
                Text(title, style: titleTextStyle),
                const SizedBox(height: 4.0),
                Flexible(
                  child: Text(
                    subTitle,
                    style: subTitleTextStyle,
                    overflow: TextOverflow.clip,
                    softWrap: true,
                  ),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
            ),
          )
        ],
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
      ),
    );
  }
}

class _Sign extends StatelessWidget {
  final String text;
  final Color color;

  _Sign(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textStyle = theme.textTheme.subtitle2;
    if (color != null) {
      textStyle = textStyle.copyWith(color: color);
    }

    return Text(text, style: textStyle);
  }
}

class _DevelopmentText extends StatelessWidget {
  static const githubUrl =
      "https://github.com/GitJournal/GitJournal/issues?q=is%3Aissue+is%3Aopen+sort%3Areactions-%2B1-desc";

  @override
  Widget build(BuildContext context) {
    var style = Theme.of(context).textTheme.bodyText2;

    var str = tr('feature_timeline.issues');
    var i = str.toLowerCase().indexOf('github');
    if (i == -1) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: RichText(text: TextSpan(children: [gitHubLink(str)])),
      );
    }

    var before = str.substring(0, i);
    var after = str.substring(i + 6);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(text: before, style: style),
            gitHubLink('GitHub'),
            TextSpan(text: after, style: style),
          ],
        ),
      ),
    );
  }

  TextSpan gitHubLink(String text) {
    return TextSpan(
      text: text,
      style: const TextStyle(color: Colors.blue),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          launch(githubUrl);
          logEvent(Event.FeatureTimelineGithubClicked);
        },
    );
  }
}
