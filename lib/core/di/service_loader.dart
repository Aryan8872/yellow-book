import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'service_loader.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async => getIt.init();
