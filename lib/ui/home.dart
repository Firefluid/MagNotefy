import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:magnotes/data/notes_model.dart';
import 'package:magnotes/data/settings_model.dart';
import 'package:magnotes/data/theme_model.dart';
import 'package:magnotes/ui/global_widgets.dart';
import 'package:magnotes/ui/editor.dart';
import 'package:magnotes/ui/settings.dart';

class SearchAppBar extends StatelessWidget {
  void filter(BuildContext context, String value) {
    Provider.of<NoteModel>(context, listen: false).filterNotes(value);
  }

  @override
  Widget build(BuildContext context) {
    TextField textInput = TextField(
      keyboardType: TextInputType.text,
      style: TextStyle(
        color: Provider.of<ThemeModel>(context).paperColors.text,
        fontSize: 14
      ),
      textInputAction: TextInputAction.search,
      autocorrect: false,
      decoration: const InputDecoration(
        border: InputBorder.none,
        hintText: "Search..",
      ),
      onChanged: (value) {
        if (Provider.of<SettingsModel>(context, listen: false)
            .getSetting(Settings.AUTOSEARCH))
              filter(context, value);
      },
      onSubmitted: (value) => filter(context, value),
    );

    void showAbout(BuildContext context) {
      showAboutDialog(
        context: context,
        applicationVersion: '1.0.0',
        applicationIcon: Image.asset(
          'assets/images/magnotes_indexed.png',
          width: 48,
          height: 48,
        ),
        applicationLegalese:
            'Copyright © 2020 Dimitri Erlikh.',
        children: [
          Text(
            'A minimalistic note-taking app '
            'where the search-field is your primary form of navigation.',
          ),
        ],
      );
    }

    return RoundedAppBar(
      child: Row(
        children: <Widget>[
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            onSelected: (result) {
              if (result == 0)
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => SettingsScreen()));
              else
                showAbout(context);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              const PopupMenuItem(
                value: 0,
                child: Text('Settings'),
              ),
              const PopupMenuItem(
                value: 1,
                child: Text('About'),
              ),
            ],
          ),

          Expanded(child: textInput),
          
          IconButton(
            icon: Icon(Icons.search),
            tooltip: "Search",
            onPressed: () => filter(context, textInput.controller.text),
          ),
        ],
      ),
    );
  }
}

class NoteCard extends StatelessWidget {
  final NoteFile note;

  const NoteCard({Key key, this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextStyle headerStyle = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 16,
      color: Provider.of<ThemeModel>(context).paperColors.text,
    );
    final TextStyle bodyStyle = TextStyle(
      fontSize: 14,
      color: Provider.of<ThemeModel>(context).paperColors.textSecondary,
    );
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: Provider.of<ThemeModel>(context).paperColors.fill,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) =>
                  EditorScreen(isNewNote: false, note: note),
              ),
            );
          },
          borderRadius: BorderRadius.all(Radius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Note header
                Text(
                  note.header,
                  style: headerStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
                Container(height: 14),
                // Note content
                Text(
                  note.content,
                  style: bodyStyle,
                  maxLines: 15,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        // remove focus from search field
        onTap: () => FocusScope.of(context).unfocus(),
        child: PaperStack(
            // AppBar
            above: SearchAppBar(),
            // List of notes
            child: SafeArea(
              child: Column(
                children: [
                  SizedBox(height: 60.0 - 16.0), // Offset under the AppBar
                  Expanded(
                    child: NoteList(),
                  ),
                ],
              ),
            ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => EditorScreen(isNewNote: true),
          ),
        ),
        tooltip: "New note",
      ),
    );
  }
}

class NoteList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<NoteModel>(
      builder: (context, noteModel, child) {
        if (noteModel.isLoading)
          // Progress indicator
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                Text(
                  'Loading notes...',
                  style: TextStyle(
                    color: Provider.of<ThemeModel>(context).paperColors.text
                  ),
                ),
              ],
            ),
          );
        else {
          if (noteModel.filteredNotes.isEmpty)
            return Center(
              child: Text(
                noteModel.notes.isEmpty
                  ? 'Create a new note by pressing \"+\"' // There are no notes
                  : 'No matching notes found.', // No matching notes were found
                style: TextStyle(
                  color: Provider.of<ThemeModel>(context).paperColors.text,
                ),
              ),
            );
          else
            return Consumer<SettingsModel>(
              builder: (context, settingsModel, _) {
                bool reversed =
                  settingsModel.getSetting(Settings.ORDERINGBOTTOM);
                return ListView.builder(
                  /* itemCount:
                  1. scroll offset to hide under the appar
                  2. notes
                  3. final space between last note and screen bottom
                  */
                  itemCount: noteModel.filteredNotes.length + 2,
                  itemBuilder: (context, index) {
                    if (index == 0) return Container(height: 16);
                    if (index > noteModel.filteredNotes.length)
                      return Container(height: 8);
                    return NoteCard(
                      note: noteModel.filteredNotes[
                        reversed
                          ? index - 1
                          : noteModel.filteredNotes.length - index
                      ]
                    );
                  },
                );
              },
            );
        }
      },
    );
  }
}
