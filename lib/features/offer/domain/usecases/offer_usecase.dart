import 'package:dartz/dartz.dart';
import 'package:entertainer/core/errors/failure.dart';
import 'package:entertainer/features/offer/domain/entity/offer_entity.dart';
import 'package:entertainer/features/offer/domain/repository/offer_repository.dart';
import 'package:entertainer/features/offer/domain/usecases/offer_params.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class GetOfferByIdUsecase {
  final OfferRepository repository;
  GetOfferByIdUsecase(this.repository);

  Future<Either<Failure, OfferEntity>> call(GetOfferByIdParams params) =>
      repository.getOfferById(params);
}

@Injectable()
class GetPaginatedOffersUsecase {
  final OfferRepository repository;
  GetPaginatedOffersUsecase(this.repository);

  Future<Either<Failure, PaginatedOfferEntity>> call(GetPaginatedOffersParams params) =>
      repository.getPaginatedOffers(params);
}

@Injectable()
class CreateOfferUsecase {
  final OfferRepository repository;
  CreateOfferUsecase(this.repository);

  Future<Either<Failure, OfferEntity>> call(CreateOfferParams params) =>
      repository.createOffer(params);
}

@Injectable()
class UpdateOfferUsecase {
  final OfferRepository repository;
  UpdateOfferUsecase(this.repository);

  Future<Either<Failure, OfferEntity>> call(UpdateOfferParams params) =>
      repository.updateOffer(params);
}

@Injectable()
class DeleteOfferUsecase {
  final OfferRepository repository;
  DeleteOfferUsecase(this.repository);

  Future<Either<Failure, bool>> call(DeleteOfferParams params) =>
      repository.deleteOffer(params);
}
