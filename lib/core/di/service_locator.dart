import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/api_config.dart';
import '../../config/constants.dart';
import '../network/api_client.dart';
import '../network/api_interceptor.dart';
import '../storage/local_storage.dart';
import '../storage/secure_storage.dart';
import '../../services/auth_service.dart';
import '../../services/bid_service.dart';
import '../../services/connectivity_service.dart';
import '../../services/sync_service.dart';
import '../../screens/splash/splash_cubit.dart';
import '../../screens/auth/login_cubit.dart';
import '../../screens/auth/forgot_password_cubit.dart';
import '../../screens/dashboard/dashboard_cubit.dart';
import '../../screens/bid/create_bid_cubit.dart';
import '../../screens/bid/bid_list_cubit.dart';
import '../../screens/bid/bid_details_cubit.dart';
import '../../screens/offline/offline_cubit.dart';
import '../../screens/sync/sync_cubit.dart';
import '../../screens/profile/profile_cubit.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // ==================== EXTERNAL ====================
  
  // Shared Preferences
  final sharedPrefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPrefs);
  
  // Flutter Secure Storage
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
  sl.registerSingleton<FlutterSecureStorage>(secureStorage);

  // Hive Boxes
  final bidBox = await Hive.openBox(AppConstants.bidBoxName);
  final syncBox = await Hive.openBox(AppConstants.syncQueueBoxName);
  final settingsBox = await Hive.openBox(AppConstants.settingsBoxName);
  
  sl.registerSingleton<Box>(bidBox, instanceName: AppConstants.bidBoxName);
  sl.registerSingleton<Box>(syncBox, instanceName: AppConstants.syncQueueBoxName);
  sl.registerSingleton<Box>(settingsBox, instanceName: AppConstants.settingsBoxName);

  // Dio
  final dio = _createDio();
  sl.registerSingleton<Dio>(dio);

  // ==================== CORE ====================
  
  // Storage
  sl.registerLazySingleton<SecureStorageHelper>(
    () => SecureStorageHelper(sl()),
  );
  sl.registerLazySingleton<LocalStorageHelper>(
    () => LocalStorageHelper(sl()),
  );

  // API Client
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(sl()),
  );

  // ==================== SERVICES ====================
  
  sl.registerLazySingleton<ConnectivityService>(
    () => ConnectivityService(),
  );
  
  sl.registerLazySingleton<AuthService>(
    () => AuthService(
      apiClient: sl(),
      secureStorage: sl(),
      localStorage: sl(),
    ),
  );
  
  sl.registerLazySingleton<BidService>(
    () => BidService(
      apiClient: sl(),
      bidBox: sl(instanceName: AppConstants.bidBoxName),
      syncBox: sl(instanceName: AppConstants.syncQueueBoxName),
      connectivityService: sl(),
    ),
  );
  
  sl.registerLazySingleton<SyncService>(
    () => SyncService(
      bidService: sl(),
      connectivityService: sl(),
      syncBox: sl(instanceName: AppConstants.syncQueueBoxName),
    ),
  );

  // ==================== CUBITS ====================
  
  sl.registerFactory<SplashCubit>(
    () => SplashCubit(authService: sl()),
  );
  
  sl.registerFactory<LoginCubit>(
    () => LoginCubit(authService: sl()),
  );
  
  sl.registerFactory<ForgotPasswordCubit>(
    () => ForgotPasswordCubit(authService: sl()),
  );
  
  sl.registerFactory<DashboardCubit>(
    () => DashboardCubit(
      bidService: sl(),
      connectivityService: sl(),
      syncService: sl(),
    ),
  );
  
  sl.registerFactory<CreateBidCubit>(
    () => CreateBidCubit(
      bidService: sl(),
      connectivityService: sl(),
    ),
  );
  
  sl.registerFactory<BidListCubit>(
    () => BidListCubit(
      bidService: sl(),
      connectivityService: sl(),
    ),
  );
  
  sl.registerFactory<BidDetailsCubit>(
    () => BidDetailsCubit(bidService: sl()),
  );
  
  sl.registerFactory<OfflineCubit>(
    () => OfflineCubit(
      bidService: sl(),
      syncService: sl(),
    ),
  );
  
  sl.registerFactory<SyncCubit>(
    () => SyncCubit(
      syncService: sl(),
      connectivityService: sl(),
    ),
  );
  
  sl.registerFactory<ProfileCubit>(
    () => ProfileCubit(
      authService: sl(),
      localStorage: sl(),
    ),
  );
}

Dio _createDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      sendTimeout: ApiConfig.sendTimeout,
      headers: ApiConfig.defaultHeaders,
    ),
  );

  // Add Interceptors
  dio.interceptors.addAll([
    AuthInterceptor(sl()),
    LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
      logPrint: (obj) => print('📡 API: $obj'),
    ),
  ]);

  return dio;
}