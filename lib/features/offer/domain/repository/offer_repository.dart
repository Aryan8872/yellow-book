import 'package:dartz/dartz.dart';
import 'package:entertainer/core/errors/failure.dart';
import 'package:entertainer/features/offer/domain/entity/offer_entity.dart';
import 'package:entertainer/features/offer/domain/usecases/offer_params.dart';

abstract class OfferRepository {
  Future<Either<Failure, OfferEntity>> getOfferById(GetOfferByIdParams params);
  Future<Either<Failure, PaginatedOfferEntity>> getPaginatedOffers(GetPaginatedOffersParams params);
  Future<Either<Failure, OfferEntity>> createOffer(CreateOfferParams params);
  Future<Either<Failure, OfferEntity>> updateOffer(UpdateOfferParams params);
  Future<Either<Failure, bool>> deleteOffer(DeleteOfferParams params);
}
