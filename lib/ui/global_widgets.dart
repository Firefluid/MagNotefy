import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:magnotefy/data/theme_model.dart';

// A custom AppBar with rounded corners
class RoundedAppBar extends StatelessWidget {
  final Widget child;

  const RoundedAppBar({Key key, this.child}):super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Provider.of<ThemeModel>(context).paperColors.fill,
      elevation: 4,
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
      child: SafeArea(
        child: SizedBox(
          height: 56,
          child: child
        ),
      ),
    );
  }
}

/*
A simple widget to allow widgets to be displayed under the rounded corners
the AppBar
*/
class PaperStack extends StatelessWidget {
  final Widget above; // AppBar content
  final Widget child; // Body content

  const PaperStack({Key key, this.above, this.child}):super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        child,
        RoundedAppBar(
          child: above,
        ),
      ],
    );
  }
}