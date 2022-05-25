import 'package:ameerorder/shared/cubit/cubit.dart';
import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget defaultButton({
  double width = double.infinity,
  Color background = Colors.blue,
  bool isUpperCase = true,
  double radius = 3.0,
  @required Function function,
  @required String text,
}) =>
    Container(
      width: width,
      height: 50.0,
      child: MaterialButton(
        //هاي  عشان فيها اون بريس
        onPressed: function,
        child: Text(
          isUpperCase ? text.toUpperCase() : text,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          radius,
        ),
        color: background,
      ),
    );

Widget defaultFormField({
  @required TextEditingController controller,
  @required TextInputType type,
  Function onSubmit,
  Function onChange,
  Function onTab,
  bool isPassword = false,
  @required Function validate,
  @required String label,
  @required IconData prefix,
  IconData suffix,
  Function suffixPressed,
}) =>
    TextFormField(
      controller: controller,
      //معرفو فوق عشان اصلو من اي مكان  وهين بعرف انوهاد للحقل هاد
      keyboardType: type,
      obscureText: isPassword,
      onFieldSubmitted: onSubmit,
      onChanged: onChange,
      onTap: onTab,
      validator: validate,
      //validator بتعطي القيمة المكتوبة وبعمل فحص عليها وهي بترجع قيمة او نل مثلا
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          prefix,
        ),
        suffixIcon: suffix != null
            ? IconButton(
                onPressed: suffixPressed,
                icon: Icon(
                  suffix,
                ),
              )
            : null,
        border: OutlineInputBorder(),
      ),
    );

Widget buildTaskItem(Map model, context) => Dismissible(
      //هاد ودجت عشان اعينKey وحدف عن طريقها عنصر معين من الليست مثلا لمن اسحب يمين او شمال
      key: Key(model['id'].toString()), //لأنو الكي هين لازم يكون نص toString
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40.0,
              child: Text(
                '${model['time']}',
              ),
            ),
            SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${model['title']}',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${model['date']}',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 20.0,
            ),
            IconButton(
              onPressed: () {
                AppCubit.get(context).updateData(
                  status: 'done',
                  id: model['id'],
                );
              },
              icon: Icon(
                Icons.check_box,
                color: Colors.green,
              ),
            ),
            IconButton(
              onPressed: () {
                AppCubit.get(context).updateData(
                  status: 'archive',
                  id: model['id'],
                );
              },
              icon: Icon(
                Icons.archive,
                color: Colors.black45,
              ),
            ),
          ],
        ),
      ),
      onDismissed:
          (direction) //هاد بحدد انو هتسحب العنصر يمين اوشمال ولكن هين علجهتين عيزين نحذف
          {
        AppCubit.get(context).deleteData(
          id: model['id'],
        );
      },
    );

Widget tasksBuilder({
  @required List<Map> tasks, //بتستقبل ليست من نوع ماب
}) =>
    ConditionalBuilder(
      //بلدر مشروط هاد من مكتبة
      condition: tasks.length > 0, //شرط بفحص الليست فيها عناصر ولا لا
      builder: (context) => ListView.separated(
        //اذ تم اعرض الليست
        itemBuilder: (context, index) {
          AppCubit cubit =
              AppCubit.get(context); //عملت متغير  عشان هستخدمو كثير

          if (DateFormat.yMMMd().format(cubit.SelectedDate) ==
              tasks[index]['date']
              ||tasks==cubit.archivedTasks||tasks==cubit.doneTasks
          ) {
            //هاد الشرط عشان يجيب الليستة بتاريخ لمن احددو
            return buildTaskItem(
                tasks[index], context); //هاد الريتيرن العادي لليست

          } else {
            return Container(); //عشان البلدر لازم يوخد ويدجت  ف بحط كونتينر فاضي
          }
        },
        separatorBuilder: (context, index) {
          AppCubit cubit = AppCubit.get(context);
          if (DateFormat.yMMMd().format(cubit.SelectedDate) ==
              tasks[index]['date']
          ||tasks==cubit.archivedTasks||tasks==cubit.doneTasks//هدول عشان انا بديش اياه يتطبق هين
          ) {
            //هاد الشرط عشان يجيب الليستة بتاريخ لمن احددو
            return Padding(
              padding: const EdgeInsetsDirectional.only(
                start: 20.0,
              ),
              child: Container(
                width: double.infinity,
                height: 1.0,
                color: Colors.grey[300],
              ),
            );
          } else {
            return Container();
          }
        },

        itemCount: tasks.length,
      ),
      fallback: //اذ ما تم الشرط
          (context) => Center(
        //
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu,
              size: 100.0,
              color: Colors.grey,
            ),
            Text(
              'No Order Yet, Please Add Some Order',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
