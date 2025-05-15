import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import '../models/archived_tasks/archived_tasks_screen.dart';
import '../models/done_tasks/done_tasks_screen.dart';
import '../models/new_tasks/new_tasks_screen.dart';
import '../shared/components/components.dart';
import '../shared/components/constants.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

// 1. create database
// 2. create tables
// 3. open the database
// 4. insert to database
// 5. get from database
// 6. update in database
// 7. delete from database
class _HomeLayoutState extends State<HomeLayout> {
  int currentIndex = 0;
  late Database dataBase;
  bool isBottomSheetShown = false;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();

  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  List<Widget> screens = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];
  List<String> titles = ["New Tasks", "Done Tasks", "Archived Tasks"];
  @override
  void initState() {
    super.initState();
    createDataBase();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: scaffoldKey,
        body: ConditionalBuilder(
          condition: tasks.isNotEmpty,
          builder: (context) => screens[currentIndex],
          fallback:
              (context) => Center(
                child: Center(
                  child: Text(
                    "No Tasks Yet, Please Add Some Tasks",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
        ),
        appBar: AppBar(title: Center(child: Text(titles[currentIndex]))),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(left: 30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                visible: isBottomSheetShown,
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      isBottomSheetShown = false;
                      titleController.text = "";
                      timeController.text = "";
                      dateController.text = "";
                    });
                  },
                  child: Icon(Icons.close),
                ),
              ),
              Spacer(),
              FloatingActionButton(
                onPressed: () {
                  if (isBottomSheetShown) {
                    if (formKey.currentState!.validate()) {
                      insertToDataBase(
                        title: titleController.text,
                        date: dateController.text,
                        time: timeController.text,
                      ).then((onValue) {
                        getDataFromDataBase(dataBase).then((onValue) {
                          print(tasks);
                          Navigator.pop(context);
                          setState(() {
                            tasks = onValue;
                            isBottomSheetShown = false;
                            titleController.text = "";
                            timeController.text = "";
                            dateController.text = "";
                          });
                        });

                      });
                    }
                  } else {
                    setState(() {
                      scaffoldKey.currentState
                          ?.showBottomSheet(
                            (context) => Container(
                              color: Colors.grey[200],
                              padding: EdgeInsets.all(20.0),
                              child: Form(
                                key: formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    defaultFormFiled(
                                      controller: titleController,
                                      type: TextInputType.text,
                                      validate: (value) {
                                        if (value!.isEmpty) {
                                          return "title must not be empty";
                                        }
                                        return null;
                                      },
                                      label: "Task Title",
                                      prefix: Icons.title,
                                    ),
                                    SizedBox(height: 10),

                                    defaultFormFiled(
                                      readOnly: true,
                                      onTab: () {
                                        showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now(),
                                        ).then((value) {
                                          if (value != null) {
                                            timeController.text =
                                                value
                                                    .format(context)
                                                    .toString();
                                          }
                                        });
                                      },
                                      controller: timeController,
                                      type: TextInputType.datetime,
                                      validate: (value) {
                                        if (value!.isEmpty) {
                                          return "Time must not be empty";
                                        }
                                        return null;
                                      },
                                      label: "Task Time",
                                      prefix: Icons.watch_later_outlined,
                                    ),
                                    SizedBox(height: 10),

                                    defaultFormFiled(
                                      readOnly: true,
                                      onTab: () {
                                        showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime.now().add(
                                            Duration(days: 365),
                                          ),
                                        ).then((value) {
                                          if (value != null) {
                                            dateController
                                                .text = DateFormat.yMMMd()
                                                .format(value);
                                          }
                                        });
                                      },
                                      controller: dateController,
                                      type: TextInputType.datetime,
                                      validate: (value) {
                                        if (value!.isEmpty) {
                                          return "Date must not be empty";
                                        }
                                        return null;
                                      },
                                      label: "Task Date",
                                      prefix: Icons.date_range_outlined,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .closed
                          .then((value) {
                            setState(() {
                              isBottomSheetShown = false;
                              titleController.text = "";
                              timeController.text = "";
                              dateController.text = "";
                            });
                          });
                      isBottomSheetShown = true;
                    });
                  }
                },
                child: Icon(isBottomSheetShown ? Icons.check : Icons.edit),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.menu), label: "Tasks"),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline),
              label: 'Done',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.archive_outlined),
              label: 'Archive',
            ),
          ],
        ),
        //body: ,
      ),
    );
  }

  Future<List<Map>> getDataFromDataBase(Database dataBase) async {
    return await dataBase.rawQuery("SELECT * FROM tasks");
  }

  void createDataBase() async {
    dataBase = await openDatabase(
      "todo.db",
      version: 1,
      onCreate: (database, version) {
        database
            .execute(
              "CREATE TABLE tasks(id INTEGER PRIMARY KEY,title TEXT,date TEXT,time TEXT,status TEXT)",
            )
            .then((value) {
              print("Table created");
            })
            .catchError((error) {
              print("Error when creating table ${error.toString()}");
            });
        print("DataBase created");
      },
      onOpen: (database) {
        getDataFromDataBase(database).then((onValue) {
          setState(() {
            tasks = onValue;
          });
          print(tasks);
        });
        print("DataBase opened");
      },
    );
  }

  Future<void> insertToDataBase({
    required String title,
    required String date,
    required String time,
  }) async {
    await dataBase.transaction((txn) async {
      txn
          .rawInsert(
            'INSERT INTO tasks(title,date,time,status) VALUES("$title","$date","$time","new")',
          )
          .then((onValue) {
            print("$onValue inserted successfully");
          })
          .catchError((error) {
            print("Error when inserting table ${error.toString()}");
          });
    });
  }
}
