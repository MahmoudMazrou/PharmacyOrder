
import 'package:ameerorder/shared/components/components.dart';
import 'package:ameerorder/shared/cubit/cubit.dart';
import 'package:ameerorder/shared/cubit/states.dart';
import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_date_picker_timeline/flutter_date_picker_timeline.dart';

import 'package:intl/intl.dart';

class HomeLayout extends StatelessWidget {
  var scaffoldKey = GlobalKey<ScaffoldState>();//بنفتح منو البوتوم شيت

  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  var nameController = TextEditingController();

  var formKey = GlobalKey<FormState>();//  هاي عشان دعطي الفليديت للبوتوم شيت

  @override
  Widget build(BuildContext context) {

   return BlocProvider(
        //في الكريت بستدعي كلاس لكيوبت تاعنا
        //الداتا بيز بدي اياها اولمكريت فستدعيتها هين لهيكcreateDatabase
        create: (BuildContext context) => AppCubit()..createDatabase(),
    child: BlocConsumer<AppCubit, AppStates>(
    listener: (BuildContext context, AppStates state) {
    if(state is AppInsertDatabaseState)
    {
    Navigator.pop(context);
    }
    },
    builder: (BuildContext context, AppStates state) {
      //جوا البلدر انتبه
      AppCubit cubit = AppCubit.get(context);//عملت متغير  عشان هستخدمو كثير
      if(cubit.currentIndex ==0){
        cubit.fabIcon= Icons.search;
      }else{
       if(cubit.isBottomSheetShown==true){
        cubit.fabIcon= Icons.add;

      }else if (cubit.isBottomSheetShown==false)
        {
          cubit.fabIcon= Icons.edit;
        }
      }

    //جوا البلدر انتبه
    return Scaffold(
      key: scaffoldKey,//هاي الاكي تعت البوتوم شيت

      appBar: AppBar(
        title: Text("Order"
        ),
      ),


      body:ConditionalBuilder(


          condition: state is! AppGetDatabaseLoadingState,//condition الشرط
          builder:

              (context) => cubit.screens[cubit.currentIndex],//في حالة تحقق الشرط محدد السكرين الي انتقللها وعامل ستيت عليها
          //CircularProgressIndicator هاد هوالي  بيلف لليستنا الداتا تحمل
          fallback: (context) => Center(child: CircularProgressIndicator()),//fallback في حالة فشل الشرط ما تحقق

      ),

      floatingActionButton:  FloatingActionButton(
        onPressed: () {
          if(cubit.currentIndex==0){//اذ انا بقائمة الأولى اعمل هيك غير ئلك افتح تعت الاضافة
            print("yes Go");
            cubit.searchDataFromDatabase(name: "yes");

            if (cubit.isBottomSheetShown)
            {

              if (formKey.currentState.validate())//اذ شرطالفايديشن تمام نفذ
                  {
                 print("off");
//اذ بدي انفذ شي ل من اضغط عليها
              }
            }

            else
            {
              scaffoldKey.currentState
                  .showBottomSheet(
                    (context) => Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(
                    20.0,
                  ),
                  child: Form(
                    key: formKey,
                    child: Container(
                      height: 300,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          defaultFormField(
                            controller: nameController,
                            type: TextInputType.text,
                            validate: (String value) {
                              if (value.isEmpty) {
                                return 'title must not be empty';
                              }

                              return null;
                            },
                            label: 'Task Title',
                            prefix: Icons.title,
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                      Expanded(
                        flex: 1,
                        child:tasksBuilder(
                          tasks: cubit.doneTasks,
                        ) ,
                      ),
                        ],
                      ),
                    ),
                  ),
                ),
                elevation: 20.0,
              );
            }
          }else{
            if (cubit.isBottomSheetShown)
            {
              if (formKey.currentState.validate())//اذ شرطالفايديشن تمام نفذ
                  {
                String addDate= DateFormat.yMMMd().format(cubit.SelectedDate);//هاي بتحول الديت ل نص عشان نحفظو بداتا بيز
                cubit.insertToDatabase(//احنا عمليتها بستقبل هاي الامور
                  title: titleController.text,
                  time: timeController.text,
                  date: addDate,
                );
              }
            }

            else
            {
              scaffoldKey.currentState
                  .showBottomSheet(
                    (context) => Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(
                    20.0,
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        defaultFormField(
                          controller: titleController,
                          type: TextInputType.text,
                          validate: (String value) {
                            if (value.isEmpty) {
                              return 'title must not be empty';
                            }

                            return null;
                          },
                          label: 'Task Title',
                          prefix: Icons.title,
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        defaultFormField(
                          controller: timeController,
                          type: TextInputType.datetime,
                          onTab: () {
                            showTimePicker(//هاي جاهزة تايم بكر بتعرض وقت ممكن تختار منو
                              context: context,
                              initialTime: TimeOfDay.now(),//الوقت الافتراضي
                            ).then((value) {
                              timeController.text =//timeController هاد الكونترولر تاع التكست فيلد بقدر اعطي نص عادي هيك
                              value.format(context).toString();//فرمت تايم ل وقت عادي الي اخدتو وحولها ل نص
                              print(value.format(context));
                            });
                          },
                          validate: (String value) {
                            if (value.isEmpty) {
                              return 'time must not be empty';
                            }

                            return null;
                          },
                          label: 'Task Time',
                          prefix: Icons.watch_later_outlined,
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        defaultFormField(
                          controller: dateController,
                          type: TextInputType.datetime,
                          onTab: () {
                            showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),//تاريخ البداية الافتراضي
                              firstDate: DateTime.now(),//اول تاريخ ممكن ابدا احدد منو
                              lastDate: DateTime.parse('2021-12-03'),//اخر تاريخ ممكن نصلو
                            ).then((value) {
                              dateController.text =//اعطينا الحقل القيمة هاي
                              DateFormat.yMMMd().format(value);//هاي بكج فرمتنا التاريخ عن طريقها وحولها ل نص برضو
                            });
                          },
                          validate: (String value) {
                            if (value.isEmpty) {
                              return 'date must not be empty';
                            }

                            return null;
                          },
                          label: 'Task Date',
                          prefix: Icons.calendar_today,
                        ),
                      ],
                    ),
                  ),
                ),
                elevation: 20.0,
              ).closed.then((value)//هاي لمن اقفل البوتوم شيت بايدي يعني انزلو ل تحت
              {
                cubit.changeBottomSheetState(
                  isShow: false,//غيرنا حالتو
                  icon: Icons.edit,//وغيرنا الايقونة
                );
              });

              cubit.changeBottomSheetState(
                isShow: true,
                icon: Icons.add,
              );
            }
          }

        },

        child: Icon(
          cubit.fabIcon,
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(//الشريط الي تحت
        type: BottomNavigationBarType.fixed,
        currentIndex: cubit.currentIndex,//currentIndex الديفولت تاعو زيرو معنها اش بدك يكون معلم بلبداية
        onTap: (index) {
          cubit.changeIndex(index);//عند الضغط بستدعي  هاي المثود الي بتغير الاندكس
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(//الايقونة تعتها
              Icons.menu,
            ),
            label: 'Tasks',//الاسم
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.check_circle_outline,
            ),
            label: 'Done',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.archive_outlined,
            ),
            label: 'Archived',
          ),
        ],
      ),
    );
  },
    ),
   );
  }

// Instance of 'Future<String>'

// Future<String> getName() async
// {
//   return 'Ahmed Ali';
// }
}