import 'package:dartz/dartz.dart';
import 'package:entertainer/core/errors/failure.dart';
import 'package:entertainer/features/offer/domain/entity/redemption_entity.dart';
import 'package:entertainer/features/offer/domain/repository/redemption_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class InitRedemptionUsecase {
  final RedemptionRepository repository;
  InitRedemptionUsecase(this.repository);

  Future<Either<Failure, RedemptionEntity>> call(String offerId) =>
      repository.initRedemption(offerId);
}

@Injectable()
class GetMyRedemptionsUsecase {
  final RedemptionRepository repository;
  GetMyRedemptionsUsecase(this.repository);

  Future<Either<Failure, List<RedemptionEntity>>> call() =>
      repository.getMyRedemptions();
}
