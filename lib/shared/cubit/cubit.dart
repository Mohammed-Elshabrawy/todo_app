import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/shared/cubit/states.dart';
import '../../models/archived_tasks/archived_tasks_screen.dart';
import '../../models/done_tasks/done_tasks_screen.dart';
import '../../models/new_tasks/new_tasks_screen.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() :super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);

  late Database dataBase;
  int currentIndex = 0;
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];

  bool isBottomSheetShown = false;
  List<Widget> screens = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];
  List<String> titles = ["New Tasks", "Done Tasks", "Archived Tasks"];


  void changeIndex(int index) {
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }

 void getDataFromDataBase(Database dataBase) async {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];
     await dataBase.rawQuery("SELECT * FROM tasks").then((onValue) {
       for (var element in onValue) {
         if(element["status"] == "new"){
           newTasks.add(element);
         }else if(element["status"] == "done"){
           doneTasks.add(element);
         }else{
           archivedTasks.add(element);
         }
         print(element["status"]);
       }
       emit(AppGetFromDataBaseState());
     });
  }

  void createDataBase() async {
    openDatabase(
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
        getDataFromDataBase(database);
        print("DataBase opened");
      },
    ).then((value) {
      dataBase = value;
      emit(AppCreateDataBaseState());
    });
  }

  Future<void> insertToDataBase({
    required String title,
    required String date,
    required String time,
  }) async {
    await dataBase.transaction((txn) async {
      txn.rawInsert(
        'INSERT INTO tasks(title,date,time,status) VALUES("$title","$date","$time","new")',
      ).then((onValue) {
        print("$onValue inserted successfully");
        emit(AppInsertToDataBaseState());
        getDataFromDataBase(dataBase);
      }).catchError((error) {
        print("Error when inserting table ${error.toString()}");
      });
    });
  }


  void upDateData({
    required String status,
    required int id,}) async {
    dataBase.rawUpdate(
      'UPDATE tasks SET status = ? WHERE id = ?',
      [status, id],
    ).then((onValue){
      getDataFromDataBase(dataBase);
      emit(AppUpDateDataBaseState());

    });
  }
  void deleteData({
    required int id,}) async {
    dataBase.rawDelete(
      'DELETE FROM tasks WHERE id = ?',
      [id],
    ).then((onValue){
      getDataFromDataBase(dataBase);
      emit(AppDeleteFromDataBaseState());

    });
  }


   void changeBottomSheetState({required bool isShow,}){
     currentIndex= 0;
     isBottomSheetShown = isShow;
     emit(AppChangeBottomSheetState());

   }

}