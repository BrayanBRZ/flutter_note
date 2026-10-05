import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meu_app/shared/appearance.dart';
import 'package:meu_app/shared/app_theme.dart';
import 'package:meu_app/screens/add_subject_screen.dart';
import 'package:meu_app/screens/confirm_action_screen.dart';
import 'package:meu_app/screens/create_task_screen.dart';
import 'package:meu_app/screens/edit_task_screen.dart';
import 'package:meu_app/screens/history_screen.dart';
import 'package:meu_app/screens/home_screen.dart';
import 'package:meu_app/screens/settings_screen.dart';
import 'package:meu_app/screens/statistics_screen.dart';
import 'package:meu_app/screens/subjects_screen.dart';
import 'package:meu_app/screens/tag_form_screen.dart';
import 'package:meu_app/screens/tags_screen.dart';
import 'package:meu_app/screens/task_detail_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');
  final appearance = AppearanceController(DevicePreferenceStore());
  await appearance.load();
  runApp(SchoolDiaryApp(appearance: appearance));
}

class SchoolDiaryApp extends StatelessWidget {
  const SchoolDiaryApp({super.key, required this.appearance});

  final AppearanceController appearance;

  @override
  Widget build(BuildContext context) {
    return AppearanceScope(
      controller: appearance,
      child: ListenableBuilder(
        listenable: appearance,
        builder: (context, _) => MaterialApp(
          title: 'Agenda Escolar',
          debugShowCheckedModeBanner: false,
          locale: const Locale('pt', 'BR'),
          supportedLocales: const [Locale('pt', 'BR')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          theme: buildAppTheme(appearance.palette, Brightness.light),
          darkTheme: buildAppTheme(appearance.palette, Brightness.dark),
          themeMode: appearance.brightness == Brightness.dark
              ? ThemeMode.dark
              : ThemeMode.light,
          initialRoute: '/home',
          routes: {
            '/home': (context) => const HomeScreen(),
            '/history': (context) => const HistoryScreen(),
            '/subject': (context) => const SubjectScreen(),
            '/subject/add': (context) => const AddSubjectScreen(),
            '/setting': (context) => const SettingScreen(),
            '/tags': (context) => const TagsScreen(),
            '/tags/form': (context) => const TagFormScreen(),
            '/task/create': (context) => const CreateTaskScreen(),
            '/task/edit': (context) => const EditTaskScreen(),
            '/task/detail': (context) => const TaskDetailScreen(),
            '/statistics': (context) => const StatisticsScreen(),
            '/confirm-action': (context) => const ConfirmActionScreen(),
          },
        ),
      ),
    );
  }
}
