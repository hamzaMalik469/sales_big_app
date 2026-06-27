import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'config/app_theme.dart';
import 'config/routes.dart';
import 'core/di/service_locator.dart';
import 'screens/splash/splash_cubit.dart';
import 'screens/auth/login_cubit.dart';
import 'screens/dashboard/dashboard_cubit.dart';

class BidManagementApp extends StatelessWidget {
  const BidManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<SplashCubit>()),
        BlocProvider(create: (_) => sl<LoginCubit>()),
        BlocProvider(create: (_) => sl<DashboardCubit>()),
      ],
      child: MaterialApp(
        title: 'Bid Management',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
