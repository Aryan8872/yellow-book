import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/home_feed_data.dart';
import '../repositories/home_repository.dart';

@Injectable()
class GetHomeFeedUseCase implements UseCase<HomeFeedData, NoParams> {
  final HomeRepository repository;

  GetHomeFeedUseCase(this.repository);

  @override
  Future<Either<Failure, HomeFeedData>> call(NoParams params) {
    return repository.getHomeFeedData();
  }
}
