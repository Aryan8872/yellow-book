import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/home_feed_data.dart';
import '../../../offer/domain/entity/offer_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, HomeFeedData>> getHomeFeedData();
  Future<Either<Failure, List<OfferEntity>>> searchOffers(String query);
}
