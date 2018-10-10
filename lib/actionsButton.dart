import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

const bool _kCloseOnTap = true;

/// A basic slide action with an icon, a caption and a background color.
class IconSlideAction2 extends ClosableSlideAction {
  /// Creates a slide action with an icon, a [caption] if set and a
  /// background color.
  ///
  /// The [closeOnTap] argument must not be null.
  const IconSlideAction2({
    Key key,
    @required this.icon,
    this.caption,
    Color color,
    this.foregroundColor,
    VoidCallback onTap,
    bool closeOnTap = _kCloseOnTap,
  })  : color = color ?? Colors.white,
        super(
          key: key,
          onTap: onTap,
          closeOnTap: closeOnTap,
        );

  final IconData icon;

  final String caption;

  /// The background color.
  ///
  /// Defaults to true.
  final Color color;

  final Color foregroundColor;

  @override
  Widget buildAction(BuildContext context) {
    final Color estimatedColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.light
            ? Colors.black
            : Colors.white;
    return Container(
      color: color,
      child: new Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Icon(
              icon,
              color: foregroundColor ?? estimatedColor,
            )
          ],
        ),
      ),
    );
  }
}
