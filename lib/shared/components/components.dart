import 'package:flutter/material.dart';

Widget taskView(Map tasksModel) => Padding(
  padding: EdgeInsets.all(20.0),
  child: Row(
    spacing: 20,
    children: [
      CircleAvatar(radius: 40, child: Text("${tasksModel["time"]}")),
      Column(
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
    ],
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
