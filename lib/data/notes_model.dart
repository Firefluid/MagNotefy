import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:magnotes/data/helper.dart';

class NoteFile {
  String header;
  String content;
  DateTime creationDate;
  String _path;

  NoteFile(this._path) {
    if(_path != null)
      creationDate = pathToDateTime(_path);
  }
  static Future<NoteFile> createInDirectory(String path) async {
    Future<String> _findAvailableFile(String path) async {
      // Format: yyyy-mm-dd_hh-mm-ss_n
      // (n is only used when a file with the current datetime already exists)
      String result = '$path/${dateTimeToMyString(DateTime.now())}';
      print('TRY 1: $result.txt');
      if(!await File('$result.txt').exists())
        return '$result.txt';
      
      // Duplicate: add n to filename
      int number = 1;
      result += '_';
      while(await File('$result$number.txt').exists()) {
        print('TRY 2: $result$number.txt');
        number++;
      }
      print('TRY 2: $result$number.txt');
      return '$result$number.txt';
    }

    NoteFile result = new NoteFile(null);
    result._path = await _findAvailableFile(path);
    result.creationDate = pathToDateTime(result._path);
    return result;
  }

  bool isEmpty() {
    return (header == null || header.isEmpty)
      && (content == null || content.isEmpty);
  }

  String get path => _path;

  Future<void> load() async {
    String contents = await File(path).readAsString();
    int splitpos = contents.indexOf('\n');
    header = contents.substring(0, splitpos);
    content = contents.substring(splitpos+1);
  }
  void save() {
    File(path).writeAsString('$header\n$content');
  }
  void delete() async {
    if(await File(path).exists())
      File(path).delete();
  }

  Future<String> detailsString() async {
    // Last time modified
    DateTime modifiedTime;
    File file = File(path);
    bool fileExists = await file.exists();
    modifiedTime = fileExists ? await file.lastModified() : creationDate;
    print('MODIFIEDTIME: ${modifiedTime.toString()}');
    
    // Filesize
    int size = fileExists ? await file.length() : 0;
    print('SIZE: $size');

    // '\t' for some reason only renders as a single space?
    return 'Date of Creation:  ${dateTimeToString(creationDate)}\n'
      + 'Last modified:  ${dateTimeToString(modifiedTime)}\n'
      + 'Size:  ${fileSizeToString(size)}\n'
      + 'Path:  \"$path\"';  // Path is only for debug purposes
  }
}

class NoteModel extends ChangeNotifier {
  bool _isLoading = false;
  final List<NoteFile> _notes = [];
  final List<NoteFile> _filteredNotes = [];
  String _filter = '';

  NoteModel():super() {
    load();
  }

  bool get isLoading => _isLoading;
  List<NoteFile> get notes => _notes;
  List<NoteFile> get filteredNotes => _filteredNotes;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/notes';
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    _notes.clear();
    _filteredNotes.clear();

    final path = await _localPath;
    final directory = Directory(path);
    if(await directory.exists()) {
      await _loadNotes(path);
      _isLoading = false;
      notifyListeners();
    }else {
      directory.create();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadNotes(final String path) async {
    Stream<FileSystemEntity> fileList = Directory(path).list();
    await for (FileSystemEntity file in fileList) {
      if(await FileSystemEntity.isFile(file.path)) {
        NoteFile note = NoteFile(file.path);
        await note.load();
        _notes.add(note);
      }
    }
    _notes.sort((a, b) => a.creationDate.compareTo(b.creationDate));
    _copyNotesFiltered();
  }

  // Create a new note in the note directory
  Future<NoteFile> createNote() async {
    return NoteFile.createInDirectory(await _localPath);
  }

  // Update after exiting the editor
  void update() => notifyListeners();

  // Add a new Note after creating a new note
  void addNote(NoteFile note) {
    _notes.add(note);
    _addFilteredNote(note);
    notifyListeners();
  }

  // Delete a note. The editor should automatically close
  void deleteNote(NoteFile note) {
    note.delete();
    _notes.remove(note);
    _filteredNotes.remove(note);
  }

  // Filter/search the notes
  void filterNotes(String query) {
    _filter = query;
    _copyNotesFiltered();
    notifyListeners();
  }
  void _copyNotesFiltered() {
    _filteredNotes.clear();
    _filter = _filter.toLowerCase();
    if(_filter.isEmpty) {
      _filteredNotes.addAll(_notes);
    } else {
      _notes.forEach((note) {
        if(note.header.toLowerCase().contains(_filter)) {
          _filteredNotes.add(note);
        }
      });
    }
  }
  void _addFilteredNote(NoteFile note) {
    if(_filter.isEmpty
      || note.header.toLowerCase().contains(_filter.toLowerCase()))
        _filteredNotes.add(note);
  }
}
