import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/cubit.dart';
import 'cubit/states.dart';
class Counter extends StatelessWidget {
  const Counter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>  CounterCubit(),
      child:  BlocConsumer<CounterCubit, CounterStates>(
      listener: (BuildContext context, CounterStates state) {
        if(state is CounterInitialState){
          print("Initial State");
        }  if(state is CounterPlusState){
          print("Plus State");
        }  if(state is CounterMinusState){
          print("Minus State");
        }
      },
        builder: (BuildContext context, state) {
          return  Scaffold(
            appBar: AppBar(
              title: Center(child: Text("Counter"))
              ,
            ),
            body: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(onPressed: (){
                    CounterCubit.get(context).minus();
                  }, child: Text("Minus",style: TextStyle(fontSize: 30)),),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("${CounterCubit.get(context).counter}",style: TextStyle(fontSize: 30),),
                  ),
                  TextButton(onPressed: (){
                    CounterCubit.get(context).plus();
                  }, child: Text("Plus",style: TextStyle(fontSize: 30)),),
                ],
              ),
            ),
          );
        }
      ),
    );

  }
}


