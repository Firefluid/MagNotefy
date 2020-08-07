import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:magnotefy/data/notes_model.dart';
import 'package:magnotefy/data/settings_model.dart';
import 'package:magnotefy/ui/home.dart';
import 'package:magnotefy/data/theme_model.dart';

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
            title: 'MagNotefy',
            theme: themeModel.themeData,
            home: child,
          );
        },
        child: MyHomePage(),
      ),
    );
  }
}
