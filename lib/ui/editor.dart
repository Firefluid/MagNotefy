import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:magnotes/data/settings_model.dart';
import 'package:magnotes/data/theme_model.dart';
import 'package:magnotes/data/notes_model.dart';
import 'package:magnotes/ui/global_widgets.dart';

class EditorScreen extends StatefulWidget {
  final bool isNewNote;
  final NoteFile note;

  EditorScreen({Key key, this.isNewNote, this.note}) : super(key: key);

  @override
  _EditorScreenState createState() => _EditorScreenState(note: note);
}

class _EditorScreenState extends State<EditorScreen> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final FocusNode contentFocusNode = FocusNode();
  NoteFile note;

  _EditorScreenState({this.note});

  @override
  void initState() { 
    super.initState();
    if (note != null) {
      titleController.text = note.header;
      contentController.text = note.content;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    contentFocusNode.dispose();
    super.dispose();
  }

  void saveNote(BuildContext context) {
    note.header = titleController.text;
    note.content = contentController.text;
    note.save();
  }

  void deleteNote(BuildContext context) {
    Provider.of<NoteModel>(context, listen: false).deleteNote(note);
    Provider.of<NoteModel>(context, listen: false).update();
    Navigator.of(context).pop(); // Close the editor
  }

  void showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Note?'),
          content: Text(
            'Do you really want to delete the Note \"${note.header ?? 'Unnamed'}\"?',
            maxLines: 3,
          ),
          actions: [
            FlatButton(
              textColor: Provider.of<ThemeModel>(context).paperColors.accent,
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FlatButton(
              textColor: Provider.of<ThemeModel>(context).paperColors.accent,
              child: Text('Delete'),
              onPressed: () {
                deleteNote(context);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showInfoDialog(context) {
    if (note != null)
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Details'),
            content: FutureBuilder<String>(
              future: note.detailsString(),
              builder: (context, snapshot) {
                if (snapshot.hasData)
                  return Text(snapshot.data);
                return SizedBox(
                  height: 36,
                  child: Center(child: CircularProgressIndicator()),
                );
              },
            ),
            actions: [
              FlatButton(
                textColor: Provider.of<ThemeModel>(context).paperColors.accent,
                child: Text('Close'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
  }

  // Decide whether to save or discard the (new) note when leaving
  Future<bool> _decideToSaveNote() async {
    if (widget.isNewNote && note != null) {
      if (note.isEmpty()) // Note was just created and left empty
        Provider.of<NoteModel>(context, listen: false).deleteNote(note);
      else  // The new note actually contains some content
        Provider.of<NoteModel>(context, listen: false).addNote(note);
    } else {
      Provider.of<NoteModel>(context, listen: false).update();
    }

    // For the WillPopScope widget
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (note == null) { // Create a new note
      print('CREATING NEW NOTE...');
      Provider.of<NoteModel>(context, listen: false).createNote().then((note) {
        print('NEW NOTE CREATED!');
        setState(() {
          this.note = note;
        });
      });
    }
    return WillPopScope(
      onWillPop: _decideToSaveNote,
      child: Scaffold(
        backgroundColor: Provider.of<ThemeModel>(context).paperColors.fill,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: PaperStack(
            // AppBar
            above: Row(
              children: <Widget>[
                BackButton(
                  onPressed: () {
                    _decideToSaveNote().then((_) {
                      Navigator.of(context).pop();
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    widget.isNewNote
                      ? 'New Note'
                      : 'Note',
                    style: TextStyle(
                      color: Provider.of<ThemeModel>(context).paperColors.text,
                      fontSize: 20,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.info_outline),
                      onPressed: () => showInfoDialog(context),
                      tooltip: "Details",
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline),
                      onPressed: () {
                        if (Provider.of<SettingsModel>(context, listen: false)
                            .getSetting(Settings.CONFIRMDELETE))
                          showDeleteDialog(context);
                        else
                          deleteNote(context);
                      },
                      tooltip: "Delete",
                    ),
                  ],
                ),
              ],
            ),
            // Body
            child: SafeArea(
              child: Column(
                children: [
                  // Offset underneath the AppBar
                  Container(height: 56.0 - 16.0),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (note == null)
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        return GestureDetector(
                          onTap: () {
                            /* Dirty hack to get focus on the content text field
                            if the user presses below the text field */
                            if (contentFocusNode.hasFocus) {
                              FocusScope.of(context).unfocus();
                            } else {
                              /* Workaround to get the keyboard up
                              if it already has focus */
                              FocusScope.of(context) .unfocus();
                              contentFocusNode.requestFocus();
                            }
                          },
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                              child: Column(
                                children: <Widget>[
                                  TextField(
                                    style: TextStyle(
                                      color: Provider.of<ThemeModel>(context)
                                        .paperColors
                                        .text,
                                      fontSize: 22,
                                    ),
                                    textInputAction: TextInputAction.next,
                                    autofocus: widget.isNewNote,
                                    controller: titleController,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Title",
                                    ),
                                    onSubmitted: (_) {
                                      // Continue to the next text field
                                      contentFocusNode.requestFocus();
                                    },
                                    onChanged: (_) => saveNote(context),
                                  ),
                                  Divider(
                                    thickness: 1,
                                    height: 1,
                                    endIndent: 16,
                                    color: Provider.of<ThemeModel>(context)
                                      .paperColors
                                      .background,
                                  ),
                                  TextField(
                                    focusNode: contentFocusNode,
                                    minLines: 2,
                                    maxLines: null,
                                    style: TextStyle(
                                      color: Provider.of<ThemeModel>(context)
                                        .paperColors
                                        .text,
                                      fontSize: 16,
                                    ),
                                    textInputAction: TextInputAction.none,
                                    controller: contentController,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Note",
                                    ),
                                    onSubmitted: (String value) {
                                      // Done editing the note
                                      FocusScope.of(context).unfocus();
                                    },
                                    onChanged: (_) => saveNote(context),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
