import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import '../cubit/cubit.dart';

Widget taskView(Map tasksModel, BuildContext context) => Dismissible(
  key: Key(tasksModel['id'].toString()),
  onDismissed: (direction) {
    AppCubit.get(context).deleteData(id: tasksModel['id']);
  },
  child: Padding(
    padding: EdgeInsets.all(20.0),
    child: Row(
      spacing: 10,
      children: [
        CircleAvatar(radius: 40, child: Text("${tasksModel["time"]}")),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("${tasksModel['title']}", style: TextStyle(fontSize: 18)),
              Text(
                "${tasksModel['date']}",
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
        ConditionalBuilder(
          condition: tasksModel['status'] == 'new',
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.check_box_outlined, color: Colors.green),
              onPressed: () {
                AppCubit.get(
                  context,
                ).upDateData(status: 'done', id: tasksModel['id']);
                AppCubit.get(context).changeIndex(1);
              },
            );
          },
          fallback: (BuildContext context) {
            return ConditionalBuilder(
              condition: tasksModel['status'] == 'done',
              builder: (BuildContext context) {
                return IconButton(
                  icon: Icon(Icons.undo_outlined, color: Colors.red[300]),
                  onPressed: () {
                    AppCubit.get(
                      context,
                    ).upDateData(status: 'new', id: tasksModel['id']);
                    AppCubit.get(context).changeIndex(0);
                  },
                );
              },
              fallback: (BuildContext context) {
                return SizedBox.shrink();
              },
            );
          },
        ),
        ConditionalBuilder(
          condition:
              tasksModel['status'] == 'new' || tasksModel['status'] == 'done',
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.archive_outlined, color: Colors.black45),
              onPressed: () {
                AppCubit.get(
                  context,
                ).upDateData(status: 'archived', id: tasksModel['id']);
                AppCubit.get(context).changeIndex(2);
              },
            );
          },
          fallback: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.undo_outlined, color: Colors.red[300]),
              onPressed: () {
                AppCubit.get(
                  context,
                ).upDateData(status: 'done', id: tasksModel['id']);
                AppCubit.get(context).changeIndex(1);
              },
            );
          },
        ),
      ],
    ),
  ),
);

Widget defaultFormFiled({
  bool readOnly = false,
  onTab,
  onSubmit,
  onChange,
  required TextEditingController controller,
  required TextInputType type,
  required FormFieldValidator<String> validate,
  required String label,
  required IconData prefix,
}) => TextFormField(
  readOnly: readOnly,
  onTap: onTab,
  controller: controller,
  keyboardType: type,
  onFieldSubmitted: onSubmit,
  onChanged: onChange,
  validator: validate,
  decoration: InputDecoration(
    labelText: label,
    prefixIcon: Icon(prefix), // Icon
    border: OutlineInputBorder(),
  ), // InputDecoration
);

Widget taskBuilder({required List<Map> tasks}) => ConditionalBuilder(
  condition: tasks.isNotEmpty,
  builder: (BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, index) => taskView(tasks[index], context),
      separatorBuilder:
          (context, index) => Container(
            width: double.infinity,
            height: 1,
            color: Colors.grey[300],
          ),
      itemCount: tasks.length,
    );
  },
  fallback: (BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu, size: 100, color: Colors.grey),
          Text(
            "No New Tasks Yet, Please Add Some Tasks",
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  },
);
