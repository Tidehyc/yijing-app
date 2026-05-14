import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'src/constants/app_colors.dart';
import 'src/widgets/page_scaffold.dart';
import 'src/features/home/home_page.dart';
import 'src/features/divination/divination_page.dart';
import 'src/features/result/result_page.dart';
import 'src/features/history/history_page.dart';
import 'src/features/record_detail/record_detail_page.dart';
import 'src/features/settings/settings_page.dart';

class YijingApp extends StatelessWidget {
  const YijingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '易经占卜',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.cinnabarRed,
          primary: AppColors.cinnabarRed,
          secondary: AppColors.inkBlack,
          surface: AppColors.antiquePaper,
        ),
        scaffoldBackgroundColor: AppColors.antiquePaper,
        fontFamily: 'KaiTi',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.antiquePaperDark,
          foregroundColor: AppColors.inkBlack,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'KaiTi',
            fontSize: 22,
            color: AppColors.inkBlack,
            fontWeight: FontWeight.bold,
          ),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        cardTheme: CardThemeData(
          color: AppColors.antiquePaperLight,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.cinnabarRed,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontFamily: 'KaiTi',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontFamily: 'KaiTi', color: AppColors.inkBlack),
          headlineMedium: TextStyle(fontFamily: 'KaiTi', color: AppColors.inkBlack),
          bodyLarge: TextStyle(fontFamily: 'FangSong', color: AppColors.inkBlack),
          bodyMedium: TextStyle(fontFamily: 'FangSong', color: AppColors.inkBlack),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const PageScaffold(child: HomePage()),
        '/divination': (_) => const DivinationPage(),
        '/result': (_) => const ResultPage(),
        '/history': (_) => const HistoryListPage(),
        '/settings': (_) => const SettingsPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/record_detail') {
          final recordId = settings.arguments as int?;
          return MaterialPageRoute(
            builder: (_) => RecordDetailPage(recordId: recordId),
          );
        }
        return null;
      },
    );
  }
}
