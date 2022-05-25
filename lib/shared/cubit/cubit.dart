import 'package:ameerorder/modules/archived_tasks/archived_tasks_screen.dart';
import 'package:ameerorder/modules/done_tasks/done_tasks_screen.dart';
import 'package:ameerorder/modules/new_tasks/new_tasks_screen.dart';
import 'package:ameerorder/shared/cubit/states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';


class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());//هاد البداية

  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;
  DateTime  SelectedDate = DateTime.now();
  bool isBottomSheetShown = false;//عشان اخفي وظهر البوتوم شيت
  IconData fabIcon = Icons.edit;


  void changeSelectedDate(DateTime dateTime) {//هاي المثود بستدعيها لمن احتاجها
    SelectedDate = dateTime;//بتعمل العملية
    emit(AppChangeSelectedDateState());//وبتحدد لستيت الخاص بيها
  }
  List<Widget> screens = [//سكرينات BottomNavigationBar
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];

  List<String> titles = [//عناوين  BottomNavigationBar
    'New Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];

  void changeIndex(int index) {//هاي المثود بستدعيها لمن احتاجها
    currentIndex = index;//بتعمل العملية

    emit(AppChangeBottomNavBarState());//وبتحدد لستيت الخاص بيها
  }

  Database database;
  List<Map> newTasks = [];//هاي ليستا الي بنحفظ فيها الداتا
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];

  void createDatabase() {
    openDatabase(//بتعطي فيوتشر داتا بيز لهيك عملنا thin وما حطينا ال asynk برضو عشان thin افضل
      'todo.db',
      version: 1,//بغيرو لمن اغير استركشر الداتا بيز
      onCreate: (database, version) {//بتعطي اوبجكت من الداتا بيز
        // id integer
        // title String
        // date String
        // time String
        // status String

        print('database created');
        database
            .execute(//نفذ امر
          //tasks اسم الجدول
          //بلقوس اسم كل كولوم ونوعو
            'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)')
            .then((value) {
          print('table created');
        }).catchError((error) {
          print('Error When Creating Table ${error.toString()}');
        });
      },
      onOpen: (database)
      {
        getDataFromDatabase(database);//بستدعيها هين عشان اول متفتح الداتا بيز يستدعيها
        print('database opened');
      },
    ).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

  insertToDatabase({
    @required String title,
    @required String time,
    @required String date,
  }) async {
    await database.transaction((txn) {
      txn.rawInsert(
        'INSERT INTO tasks(title, date, time, status) VALUES("$title", "$date", "$time", "new")',
      )
          .then((value) {
        print('$value inserted successfully');
        emit(AppInsertDatabaseState());

        getDataFromDatabase(database);  //هين مستدعيها عشان بعد مضيف اجيب الداتا مرة اخرى
      }).catchError((error) {
        print('Error When Inserting New Record ${error.toString()}');
      });

      return null;
    });
  }

  void getDataFromDatabase(database)//database هاي الي بستقبل عن طريقها الداتا بيز
  {  //بصفر الليست عشان ميضيفش فوق الموجود
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];

    emit(AppGetDatabaseLoadingState());

    database.rawQuery('SELECT * FROM tasks').then((value) {

      value.forEach((element)//عشان الداتا بتكون محفوظة بليستة
      {
        if(element['status'] == 'new')
          newTasks.add(element);
        else if(element['status'] == 'done')
          doneTasks.add(element);
        else archivedTasks.add(element);
      });

      emit(AppGetDatabaseState());
    });
  }
  void searchDataFromDatabase(
      {@required String name}
      )async//database هاي الي بستقبل عن طريقها الداتا بيز
  {

    database.rawQuery('SELECT * FROM tasks WHERE  title = ?', ['yes']).then((value) {

      getDataFromDatabase(database);

      emit(AppSearchDatabaseState());
    });
  }


  void updateData({
    @required String status,
    @required int id,
  }) async
  {
    database.rawUpdate(
      //علامة الاستفهام الاولى بتوخد  المتغير الأول والثانية الثاني
      'UPDATE tasks SET status = ? WHERE id = ?',
      ['$status', id],
    ).then((value)
    {
      getDataFromDatabase(database);
      emit(AppUpdateDatabaseState());
    });
  }

  void deleteData({
    @required int id,
  }) async
  {
    database.rawDelete('DELETE FROM tasks WHERE id = ?', [id])
        .then((value)
    {
      getDataFromDatabase(database);
      emit(AppDeleteDatabaseState());
    });
  }







  void changeBottomSheetState({
    @required bool isShow,
    @required IconData icon,
  }) {
    isBottomSheetShown = isShow;
    fabIcon = icon;

    emit(AppChangeBottomSheetState());
  }
}

