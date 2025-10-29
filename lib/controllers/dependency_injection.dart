import 'package:get_it/get_it.dart';
import 'package:imogoat/core/rest_client/dioClient.dart';
import 'package:imogoat/models/rest_client.dart';
import 'package:imogoat/repositories/user_repository.dart';

final sl = GetIt.instance;

void setupDependencies() {
  sl.registerLazySingleton<RestClient>(() => DioCliente());
  sl.registerLazySingleton<UserRepository>(
      () => UserRepository(restClient: sl<RestClient>()));
}
