import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:magnotes/data/notes_model.dart';
import 'package:magnotes/data/settings_model.dart';
import 'package:magnotes/ui/home.dart';
import 'package:magnotes/data/theme_model.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  // This widget is the root of the application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Theme settings and theme colors
        ChangeNotifierProvider<ThemeModel>(
            lazy: false, create: (_) => ThemeModel()),
        // Loading and listing notes
        ChangeNotifierProvider<NoteModel>(create: (_) => NoteModel()),
        // Simple settings
        ChangeNotifierProvider<SettingsModel>(create: (_) => SettingsModel()),
      ],
      child: Consumer<ThemeModel>(
        builder: (context, themeModel, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'MagNotes',
            theme: themeModel.themeData,
            home: child,
          );
        },
        child: MyHomePage(),
      ),
    );
  }
}
