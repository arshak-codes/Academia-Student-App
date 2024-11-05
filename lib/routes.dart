import 'package:new_project/screens/login_screen/login_screen.dart';
import 'package:new_project/screens/splash_screen/splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'screens/assignment_screen/assignment_screen.dart';
import 'screens/datesheet_screen/datesheet_screen.dart';
import 'screens/fee_screen/fee_screen.dart';
import 'screens/home_screen/home_screen.dart';
import 'screens/my_profile/my_profile.dart';
import 'screens/task_screen/tasks.dart';
import 'package:new_project/screens/logout_screen/logout_screen.dart';
import 'package:new_project/screens/time_table_screen/time_table_screen.dart';
import 'package:new_project/screens/ask_ai_screen/ask_ai_screen.dart';
import 'package:new_project/screens/quiz_screen/create_quiz_screen.dart';

Map<String, WidgetBuilder> routes = {
  //all screens will be registered here like manifest in android
  SplashScreen.routeName: (context) => const SplashScreen(),
  LoginScreen.routeName: (context) => const LoginScreen(),
  HomeScreen.routeName: (context) => const HomeScreen(),
  MyProfileScreen.routeName: (context) => const MyProfileScreen(),
  FeeScreen.routeName: (context) => const FeeScreen(),
  AssignmentScreen.routeName: (context) => const AssignmentScreen(),
  DateSheetScreen.routeName: (context) => const DateSheetScreen(),
  TasksScreen.routeName: (context) => const TasksScreen(),
  LogoutScreen.routeName: (context) => const LogoutScreen(),
  TimeTableScreen.routeName: (context) => const TimeTableScreen(),
  AskAIScreen.routeName: (context) => const AskAIScreen(),
  CreateQuizScreen.routeName: (context) => const CreateQuizScreen(),
};
