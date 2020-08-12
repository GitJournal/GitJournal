import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:gitjournal/features.dart';

class FeatureTimelineScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('feature_timeline.title')),
      ),
      body: ListView(
        children: [
          for (var feature in Features.all) FeatureTile(feature),
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
            child: feature.pro ? _Sign('PRO') : _Sign("FREE"),
          ),
          Expanded(
            child: Column(
              children: [
                Text(feature.title, style: titleTextStyle),
                const SizedBox(height: 4.0),
                Flexible(
                  child: Text(
                    subtitle,
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
  _Sign(this.text);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textStyle = theme.textTheme.subtitle2;
    if (text == 'PRO') {
      if (theme.brightness == Brightness.light) {
        textStyle = textStyle.copyWith(color: theme.primaryColor);
      } else {
        textStyle = textStyle.copyWith(color: theme.accentColor);
      }
    }

    return Text(text, style: textStyle);
  }
}
