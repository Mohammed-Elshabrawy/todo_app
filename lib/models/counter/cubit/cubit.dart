import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/models/counter/cubit/states.dart';
class CounterCubit extends Cubit<CounterStates>{
  int counter = 0;
  //Constructor
  CounterCubit():super(CounterInitialState()); //instate
  static CounterCubit get(context)=>BlocProvider.of(context); //get

  //Functions
  void plus(){
    counter++;
    emit(CounterPlusState());
  }

  void minus(){
    counter--;
    emit(CounterMinusState());
  }

}