import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

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
