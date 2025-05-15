import 'package:flutter/material.dart';
import '../../shared/components/components.dart';
import '../../shared/components/constants.dart';

class NewTasksScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return ListView.separated(
      itemBuilder: (context,index)=>taskView(tasks[index]),
      separatorBuilder:  (context,index)=>Container(
        width: double.infinity,
        height: 1,
        color: Colors.grey[300],
      ),
      itemCount: tasks.length,
    );
  }
}
