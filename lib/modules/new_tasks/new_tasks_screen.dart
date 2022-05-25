import 'package:ameerorder/shared/components/components.dart';
import 'package:ameerorder/shared/cubit/cubit.dart';
import 'package:ameerorder/shared/cubit/states.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_date_picker_timeline/flutter_date_picker_timeline.dart';
import 'package:intl/intl.dart';



class NewTasksScreen extends StatelessWidget
{



  @override
  Widget build(BuildContext context)
  {


    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {},

      builder: (context, state)
      {
        List<Map> tasks = AppCubit.get(context).newTasks;
        var  c = tasks[0]['time'];
        AppCubit cubit = AppCubit.get(context);//عملت متغير  عشان هستخدمو كثير

        return Column(

          children: <Widget>[
            FlutterDatePickerTimeline(
              startDate: DateTime(2021, 10, 01),
              endDate: DateTime.now().add(const Duration(days: 10)),
              initialSelectedDate: cubit.SelectedDate,
              onSelectedDateChange: (DateTime dateTime) {
                cubit.changeSelectedDate(dateTime);
              },
            ),
            SizedBox(height: 20,),
            Expanded(
              flex: 1,
              child:tasksBuilder(
                tasks: tasks,
              ) ,

            )

          ],
        );


      },
    );
  }
}