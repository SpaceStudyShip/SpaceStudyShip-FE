import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/constants/text_styles.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        title: 'Font Test',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const FontTestPage(),
      ),
    );
  }
}

class FontTestPage extends StatelessWidget {
  const FontTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Pretendard 폰트 테스트', style: AppTextStyles.heading4.bold()),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Heading 1', style: AppTextStyles.heading1),
            Text('Heading 2', style: AppTextStyles.heading2),
            Text('Heading 3', style: AppTextStyles.heading3),
            Text('Heading 4', style: AppTextStyles.heading4),
            SizedBox(height: 20.h),
            Text('Body 1', style: AppTextStyles.body1),
            Text('Body 2', style: AppTextStyles.body2),
            SizedBox(height: 20.h),
            Text('Caption', style: AppTextStyles.caption),
            Text('Overline', style: AppTextStyles.overline),
            SizedBox(height: 30.h),
            Text('Weight 테스트:', style: AppTextStyles.heading4.bold()),
            SizedBox(height: 10.h),
            Text('Thin (100)', style: AppTextStyles.body1.thin()),
            Text('ExtraLight (200)', style: AppTextStyles.body1.extraLight()),
            Text('Light (300)', style: AppTextStyles.body1.light()),
            Text('Regular (400)', style: AppTextStyles.body1.regular()),
            Text('Medium (500)', style: AppTextStyles.body1.medium()),
            Text('SemiBold (600)', style: AppTextStyles.body1.semiBold()),
            Text('Bold (700)', style: AppTextStyles.body1.bold()),
            Text('ExtraBold (800)', style: AppTextStyles.body1.extraBold()),
            Text('Black (900)', style: AppTextStyles.body1.black()),
          ],
        ),
      ),
    );
  }
}
