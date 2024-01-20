import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

final message = Provider((ref) => "Save");
final notesProvider = ChangeNotifierProvider((ref) {
  return notebookList();
});

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notebook ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const notebookApp(title: 'Notebook'),
      debugShowCheckedModeBanner: false,
    );
  }
}

enum importance { low, mid, high }

class notebook {
  String title;
  String explanation;
  bool isShowed;
  bool isNoteEdited;
  bool isReminderActive;
  importance importanceOfNote;
  DateTime time;
  DateTime? reminder;

  notebook({
    required this.title,
    required this.importanceOfNote,
    required this.explanation,
    required this.time,
    required this.isReminderActive,
    required this.reminder,
    this.isNoteEdited = false,
    this.isShowed = false,
  });
}

class notebookList extends ChangeNotifier {
  final List<notebook> notebooks = [];

  void addNotes(notebook note) {
    notebooks.add(note);
    notifyListeners();
  }

  void editNote(notebook note) {
    notebooks.add(note);
    notifyListeners();
  }

  void closeAllNotes(final List<notebook> notebooks) {
    for (var note in notebooks) {
      note.isShowed = false;
    }
  }
}

class notebookApp extends ConsumerStatefulWidget {
  const notebookApp({super.key, required this.title});

  final String title;

  @override
  ConsumerState<notebookApp> createState() => _notebookAppState();
}

class _notebookAppState extends ConsumerState<notebookApp> {
  Future<void> _dialogBuilder(BuildContext context, notebookAll, deletedItem) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Uyarı'),
          content: const Text("Bu Not Silinecek Emin Misiniz ?"),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Sil'),
              onPressed: () {
                notebookAll.removeWhere(
                    (notebook currentItem) => deletedItem == currentItem);
                Navigator.of(context).pop();
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final notebooks = ref.watch(notesProvider).notebooks;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
          actions: [
            Padding(
                padding: const EdgeInsets.only(right: 24.0),
                child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => noteAddPage(notebooks)));
                    },
                    child: const Icon(Icons.add)))
          ],
        ),
        body: SingleChildScrollView(
            child: ExpansionPanelList(
          expansionCallback: (int index, bool isExpanded) {
            setState(() {
              notebooks[index].isShowed = !isExpanded;
            });
          },
          children: notebooks.map<ExpansionPanel>((notebook item) {
            return ExpansionPanel(
              headerBuilder: (BuildContext context, bool isExpanded) {
                return Container(
                  color: item.importanceOfNote == importance.high
                      ? Colors.red
                      : item.importanceOfNote == importance.mid
                          ? Colors.orange
                          : Colors.green,
                  child: ListTile(
                    title: Text(item.title),
                  ),
                );
              },
              body: Container(
                color: item.importanceOfNote == importance.high
                    ? Colors.red
                    : item.importanceOfNote == importance.mid
                        ? Colors.orange
                        : Colors.green,
                child: ListTile(
                    title: Text(item.explanation),
                    subtitle: Text(item.isNoteEdited
                        ? "Edited at ${item.time.year}/${item.time.month}/${item.time.day}-${item.time.hour}.${item.time.minute} ${item.isReminderActive ? "\n Reminder at: ${item.reminder!.year}/${item.reminder!.month}/${item.reminder!.day}" : ""}"
                        : 'Created at ${item.time.year}/${item.time.month}/${item.time.day}-${item.time.hour}.${item.time.minute}${item.isReminderActive ? "\nReminder at: ${item.reminder!.year}/${item.reminder!.month}/${item.reminder!.day}" : ""}'),
                    trailing: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: SizedBox(
                          width: 50,
                          height: 50,
                          child: InkWell(
                            onTap: () {
                              _dialogBuilder(context, notebooks, item);
                            },
                            child: const Icon(Icons.delete),
                          )),
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => noteDetailPage(item),
                      ));
                    }),
              ),
              isExpanded: item.isShowed,
            );
          }).toList(),
        )));
  }
}

class noteDetailPage extends ConsumerStatefulWidget {
  const noteDetailPage(this.note, {Key? key}) : super(key: key);

  final notebook note;

  @override
  ConsumerState<noteDetailPage> createState() => _noteDetailPageState();
}

class _noteDetailPageState extends ConsumerState<noteDetailPage> {
  final TextEditingController noteExplanationDetailPageController =
      TextEditingController();
  final TextEditingController noteTitleDetailPageController =
      TextEditingController();
  String selectedDetailOption = "High";

  String selectedDay = "";
  String selectedMonth = "";
  String selectedYear = "";

  List<String> importanceDetailOptions = ["High", "Middle", "Low"];

  final _noteDetailFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text("Edit ${widget.note.title} Note"),
        ),
        body: Container(
          child: Form(
            key: _noteDetailFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter something...';
                    }
                    return null;
                  },
                  controller: noteTitleDetailPageController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: widget.note.title,
                  ),
                ),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter something...';
                    }
                    return null;
                  },
                  controller: noteExplanationDetailPageController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: widget.note.explanation,
                  ),
                ),
                Container(
                  child: () {
                    if (widget.note.reminder != null) {
                      return Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: DropdownMenu<String>(
                              initialSelection: "${widget.note.reminder!.day}",
                              onSelected: (String? value) {
                                setState(() {
                                  if (value != null) selectedDay = value;
                                });
                              },
                              dropdownMenuEntries: List.generate(
                                      30, (index) => (index + 1).toString())
                                  .map<DropdownMenuEntry<String>>(
                                      (String value) {
                                return DropdownMenuEntry<String>(
                                    value: value, label: value);
                              }).toList(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 1, top: 16.0),
                            child: DropdownMenu<String>(
                              initialSelection:
                                  "${widget.note.reminder!.month}",
                              onSelected: (String? value) {
                                // This is called when the user selects an item.
                                setState(() {
                                  if (value != null) selectedMonth = value;
                                });
                              },
                              dropdownMenuEntries: List.generate(
                                      12, (index) => (index + 1).toString())
                                  .map<DropdownMenuEntry<String>>(
                                      (String value) {
                                return DropdownMenuEntry<String>(
                                    value: value, label: value);
                              }).toList(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 2, top: 16.0),
                            child: DropdownMenu<String>(
                              initialSelection: "${widget.note.reminder!.year}",
                              onSelected: (String? value) {
                                // This is called when the user selects an item.
                                setState(() {
                                  if (value != null) selectedDay = value;
                                });
                              },
                              dropdownMenuEntries: List.generate(
                                      30,
                                      (index) => (index + DateTime.now().year)
                                          .toString())
                                  .map<DropdownMenuEntry<String>>(
                                      (String value) {
                                return DropdownMenuEntry<String>(
                                    value: value, label: value);
                              }).toList(),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return null;
                    }
                  }(),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: DropdownMenu<String>(
                    initialSelection: importanceDetailOptions.first,
                    onSelected: (String? value) {
                      // This is called when the user selects an item.
                      setState(() {
                        selectedDetailOption = value!;
                      });
                    },
                    dropdownMenuEntries: importanceDetailOptions
                        .map<DropdownMenuEntry<String>>((String value) {
                      return DropdownMenuEntry<String>(
                          value: value, label: value);
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (_noteDetailFormKey.currentState!.validate()) {
                            if (selectedDay == "") {
                              selectedDay =
                                  widget.note.reminder!.day.toString();
                            }
                            if (selectedMonth == "") {
                              selectedMonth =
                                  widget.note.reminder!.month.toString();
                            }
                            if (selectedYear == "") {
                              selectedYear =
                                  widget.note.reminder!.year.toString();
                            }

                            String dateString =
                                "$selectedDay/$selectedMonth/$selectedYear";
                            DateFormat dateFormat = DateFormat("dd/MM/yyyy");
                            DateTime dateTime = dateFormat.parse(dateString);
                            widget.note.reminder = dateTime;

                            widget.note.title =
                                noteTitleDetailPageController.text;
                            widget.note.explanation =
                                noteExplanationDetailPageController.text;
                            widget.note.importanceOfNote =
                                selectedDetailOption == "High"
                                    ? importance.high
                                    : selectedDetailOption == "Middle"
                                        ? importance.mid
                                        : importance.low;
                            widget.note.isShowed = false;
                            widget.note.isNoteEdited = true;
                            widget.note.time = DateTime.now();
                            ref.watch(notesProvider).notifyListeners();
                            Navigator.of(context).pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text("You should complete form...")));
                          }
                        });
                      },
                      child: Text(ref.watch(message))),
                )
              ],
            ),
          ),
        ));
  }
}

class noteAddPage extends ConsumerStatefulWidget {
  const noteAddPage(this.notebooks, {Key? key})
      : super(key: key);

  final List<notebook> notebooks;

  @override
  ConsumerState<noteAddPage> createState() => _noteAddPageState();
}

class _noteAddPageState extends ConsumerState<noteAddPage> {
  final noteBookTitleController = TextEditingController();
  final noteBookExplatanationController = TextEditingController();
  String selectedOption = "High";
  List<String> importanceOptions = ["High", "Middle", "Low"];
  final _noteFormKey = GlobalKey<FormState>();
  bool isReminderActived = false;

  String selectedDay = "${DateTime.now().day}";
  String selectedMonth = "${DateTime.now().month}";
  String selectedYear = "${DateTime.now().year}";

  @override
  void dispose() {
    noteBookTitleController.dispose();
    noteBookExplatanationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("Add new note"),
        ),
        body: Container(
          child: Form(
            key: _noteFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter something valid...';
                    }
                    return null;
                  },
                  controller: noteBookTitleController,
                  decoration: const InputDecoration(
                    labelText: "Title",
                    border: OutlineInputBorder(),
                    hintText: 'Please enter Title...',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 1.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter something valid...';
                      }
                      return null;
                    },
                    controller: noteBookExplatanationController,
                    decoration: const InputDecoration(
                      labelText: "Explanation",
                      border: OutlineInputBorder(),
                      hintText: 'Please enter Explatanation ...',
                    ),
                  ),
                ), // Seçilen seçeneği saklamak için bir değişken

                Row(
                  children: [
                    Checkbox(
                      checkColor: Colors.white,
                      value: isReminderActived,
                      onChanged: (bool? value) {
                        setState(() {
                          isReminderActived = !isReminderActived;
                        });
                      },
                    ),
                    const Text("Remind me on a specific day")
                  ],
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        Visibility(
                          visible: isReminderActived,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: DropdownMenu<String>(
                              initialSelection: "${DateTime.now().day}",
                              onSelected: (String? value) {
                                setState(() {
                                  selectedDay = value!;
                                });
                              },
                              dropdownMenuEntries: List.generate(
                                      30, (index) => (index + 1).toString())
                                  .map<DropdownMenuEntry<String>>(
                                      (String value) {
                                return DropdownMenuEntry<String>(
                                    value: value, label: value);
                              }).toList(),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: isReminderActived,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 1, top: 16.0),
                            child: DropdownMenu<String>(
                              initialSelection: "${DateTime.now().month}",
                              onSelected: (String? value) {
                                // This is called when the user selects an item.
                                setState(() {
                                  selectedMonth = value!;
                                });
                              },
                              dropdownMenuEntries: List.generate(
                                      12, (index) => (index + 1).toString())
                                  .map<DropdownMenuEntry<String>>(
                                      (String value) {
                                return DropdownMenuEntry<String>(
                                    value: value, label: value);
                              }).toList(),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: isReminderActived,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 2, top: 16.0),
                            child: DropdownMenu<String>(
                              initialSelection: "${DateTime.now().year}",
                              onSelected: (String? value) {
                                // This is called when the user selects an item.
                                setState(() {
                                  selectedYear = value!;
                                });
                              },
                              dropdownMenuEntries: List.generate(
                                      30,
                                      (index) => (index + DateTime.now().year)
                                          .toString())
                                  .map<DropdownMenuEntry<String>>(
                                      (String value) {
                                return DropdownMenuEntry<String>(
                                    value: value, label: value);
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: DropdownMenu<String>(
                        initialSelection: importanceOptions.first,
                        onSelected: (String? value) {
                          setState(() {
                            selectedOption = value!;
                          });
                        },
                        dropdownMenuEntries: importanceOptions
                            .map<DropdownMenuEntry<String>>((String value) {
                          return DropdownMenuEntry<String>(
                              value: value, label: value);
                        }).toList(),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (_noteFormKey.currentState!.validate()) {
                            String dateString =
                                "$selectedDay/$selectedMonth/$selectedYear";
                            DateFormat dateFormat = DateFormat("dd/MM/yyyy");
                            DateTime dateTime = dateFormat.parse(dateString);

                            ref.watch(notesProvider).addNotes(notebook(
                                title: noteBookTitleController.text,
                                importanceOfNote: selectedOption == "High"
                                    ? importance.high
                                    : selectedOption == "Middle"
                                        ? importance.mid
                                        : importance.low,
                                explanation:
                                    noteBookExplatanationController.text,
                                isReminderActive: isReminderActived,
                                time: DateTime.now(),
                                reminder: isReminderActived ? dateTime : null));
                            ref
                                .watch(notesProvider)
                                .closeAllNotes(widget.notebooks);

                            Navigator.of(context).pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('You should complete form...')));
                          }
                        });
                      },
                      child: Text(ref.watch(message))),
                )
              ],
            ),
          ),
        ));
  }
}
