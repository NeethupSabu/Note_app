//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:flutter/widgets.dart';
import 'package:notes_app/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;
  HomeScreen({super.key, required this.onThemeChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isDarkMode = false;

  Future<void> _loadThemePreferences() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = pref.getBool('isDarkMode') ?? false;
    });
  }

  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
      widget.onThemeChanged(_isDarkMode);
    });
  }

  List<Map<String, dynamic>> _allNotes = [];
  bool _isloadingNote = true;

  final TextEditingController _noteTitlecontroller = TextEditingController();
  final TextEditingController _noteDescriptioncontroller =
      TextEditingController();
  void reloadNotes() async {
    final note = await QueryHelper.getAllNotes();
    setState(() {
      _allNotes = note;
      _isloadingNote = false;
    });
  }

  Future<void> _addNote() async {
    await QueryHelper.careateNote(
        _noteTitlecontroller.text, _noteDescriptioncontroller.text);
    reloadNotes();
  }

  Future<void> _updateNote(int id) async {
    await QueryHelper.updateNote(
        id, _noteTitlecontroller.text, _noteDescriptioncontroller.text);
    reloadNotes();
  }

  void _deleteNote(int id) async {
    await QueryHelper.deleteNote(id);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Note has been deleted...!'),
    ));
    reloadNotes();
  }

  void _deleteAllNotes() async {
    final noteCount = await QueryHelper.getNoteCount();
    if (noteCount > 0) {
      await QueryHelper.deleteAllNotes();
      reloadNotes();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('All notes have been deleted...!'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('No notes to delete...!'),
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    reloadNotes();
    _loadThemePreferences();
  }

  void showBottomSheetContent(int? id) async {
    if (id != null) {
      final currentNote =
          _allNotes.firstWhere((element) => element['id'] == id);
      _noteTitlecontroller.text = currentNote['title'];
      _noteDescriptioncontroller.text = currentNote['description'];
    }
    showModalBottomSheet(
        elevation: 1,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(0))),
        isScrollControlled: true,
        context: context,
        builder: (_) => SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                        top: 15.0,
                        left: 15.0,
                        right: 15.0,
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ), //MediaQuery.of(context).viewInsets.bottom),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextField(
                            controller: _noteTitlecontroller,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Note Title',
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          TextField(
                            controller: _noteDescriptioncontroller,
                            maxLines: 5,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Description',
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Center(
                            child: OutlinedButton(
                                onPressed: () async {
                                  if (id == null) {
                                    await _addNote();
                                  }
                                  if (id != null) {
                                    await _updateNote(id);
                                  }
                                  _noteTitlecontroller.text = "";
                                  _noteDescriptioncontroller.text = "";
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  id == null ? "Add Note" : "Update Note",
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w300),
                                )),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            onPressed: () async {
              _deleteAllNotes();
            },
            icon: Icon(Icons.delete_forever_rounded),
          ),
          IconButton(
            onPressed: () {
              _appExit();
            },
            icon: Icon(Icons.exit_to_app),
          ),
          Transform.scale(
            scale: 0.5,
            child: Switch(
                value: _isDarkMode,
                onChanged: (value) {
                  _toggleTheme(value);
                }),
          )
        ],
      ),
      body: SafeArea(
          child: _isloadingNote
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.builder(
                  itemCount: _allNotes.length,
                  itemBuilder: (context, index) => Card(
                    elevation: 7,
                    margin: EdgeInsets.all(16.0),
                    child: ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Text(
                                _allNotes[index]['title'],
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    showBottomSheetContent(
                                        _allNotes[index]['id']);
                                  },
                                  icon: Icon(Icons.edit)),
                              IconButton(
                                  onPressed: () {
                                    _deleteNote(_allNotes[index]['id']);
                                  },
                                  icon: Icon(Icons.delete)),
                            ],
                          )
                        ],
                      ),
                      subtitle: Text(
                        _allNotes[index]['description'],
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showBottomSheetContent(null);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _appExit() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Exit App'),
            content: Text('Are you want to exit the app.?'),
            actions: [
              OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancel")),
              OutlinedButton(
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  child: Text('Exit')),
            ],
          );
        });
  }
}
