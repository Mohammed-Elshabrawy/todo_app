import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../shared/components/components.dart';
import '../shared/cubit/cubit.dart';
import '../shared/cubit/states.dart';
// 1. create database
// 2. create tables
// 3. open the database
// 4. insert to database
// 5. get from database
// 6. update in database
// 7. delete from database

class HomeLayout extends StatelessWidget {
  HomeLayout({super.key});

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final timeController = TextEditingController();
  final dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppCubit()..createDataBase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (BuildContext context, Object? state) {
          if (state is AppInsertToDataBaseState) {
            Navigator.pop(context);
            AppCubit.get(context).changeBottomSheetState(isShow: false);
            titleController.text = "";
            timeController.text = "";
            dateController.text = "";
          }
        },
        builder: (BuildContext context, state) {
          AppCubit cubit = AppCubit.get(context);
          return PopScope(
            canPop: false,
            child: Scaffold(
              key: scaffoldKey,
              appBar: AppBar(
                title: Center(child: Text(cubit.titles[cubit.currentIndex])),
              ),
              body: ConditionalBuilder(
                condition: true,
                builder: (context) => cubit.screens[cubit.currentIndex],
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
              floatingActionButton: Padding(
                padding: const EdgeInsets.only(left: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: cubit.isBottomSheetShown,
                      child: FloatingActionButton(
                        onPressed: () {
                          Navigator.pop(context);
                          cubit.changeBottomSheetState(isShow: false);
                          titleController.text = "";
                          timeController.text = "";
                          dateController.text = "";
                        },
                        child: Icon(Icons.close),
                      ),
                    ),
                    Spacer(),
                    FloatingActionButton(
                      onPressed: () {
                        if (cubit.isBottomSheetShown) {
                          if (formKey.currentState!.validate()) {
                            cubit.insertToDataBase(
                              title: titleController.text,
                              date: dateController.text,
                              time: timeController.text,
                            );
                          }
                        } else {
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
                                cubit.changeBottomSheetState(isShow: false);
                                titleController.text = "";
                                timeController.text = "";
                                dateController.text = "";
                              });
                          cubit.changeBottomSheetState(isShow: true);
                        }
                      },
                      child: Icon(
                        cubit.isBottomSheetShown ? Icons.check : Icons.edit,
                      ),
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: BottomNavigationBar(
                onTap: (index) {
                  cubit.changeIndex(index);
                },
                type: BottomNavigationBarType.fixed,
                currentIndex: cubit.currentIndex,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.menu),
                    label: "Tasks",
                  ),
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
            ),
          );
        },
      ),
    );
  }
}
