import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/shared/bloc_observer.dart';
import 'Layout/home_layout.dart';
import 'models/counter/counter.dart';

void main() {
  Bloc.observer = MyBlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
      ),
      home:  Counter(),
    );
  }
}


