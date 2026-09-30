import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/home_feed_data.dart';
import '../../domain/entities/offer_entity.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, HomeFeedData>> getHomeFeedData() async {
    try {
      final trendingDtos = await remoteDataSource.fetchTrendingOffers();
      final featuredDtos = await remoteDataSource.fetchFeaturedOffers();

      final feedData = HomeFeedData(
        heroSliderImages: const [
          'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=800&q=80',
          'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=800&q=80',
          'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?auto=format&fit=crop&w=800&q=80',
        ],
        categories: const [
          CategoryEntity(id: '1', name: 'Nearby', iconPath: 'assets/category/nearby.png'),
          CategoryEntity(id: '2', name: 'Dining', iconPath: 'assets/category/dining.png'),
          CategoryEntity(id: '3', name: 'Activities', iconPath: 'assets/category/activities.png'),
          CategoryEntity(id: '4', name: 'Offers', iconPath: 'assets/category/discounts.png'),
          CategoryEntity(id: '5', name: 'Hotels', iconPath: 'assets/category/hotels.png'),
        ],
        trendingOffers: trendingDtos.map((dto) => dto.toEntity()).toList(),
        featuredOffers: featuredDtos.map((dto) => dto.toEntity()).toList(),
        communityReviews: const [
          ReviewEntity(
            id: '1',
            userName: 'Aarav Sharma',
            userAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
            savedAmountText: 'Saved \$55 on BOGOF',
            reviewText: 'Used the Buy 1 Get 1 Free main course at Tribes. The service was top notch and savings were incredible!',
            personalPickMerchant: 'Tribes Restaurant',
          ),
          ReviewEntity(
            id: '2',
            userName: 'Priya Karki',
            userAvatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=200&q=80',
            savedAmountText: 'Saved \$30 on BOGOF',
            reviewText: 'Green Bowl is my absolute favorite for healthy salads. The app made redemption so seamless.',
            personalPickMerchant: 'Green Bowl',
          ),
          ReviewEntity(
            id: '3',
            userName: 'Rohan Shrestha',
            userAvatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
            savedAmountText: 'Saved \$120 on Hotel Stay',
            reviewText: 'Booked our weekend staycation through OfferNepal. Amazing discounts and instant confirmation.',
            personalPickMerchant: 'Himalayan Resort',
          ),
        ],
      );

      return Right(feedData);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OfferEntity>>> searchOffers(String query) async {
    try {
      final trendingDtos = await remoteDataSource.fetchTrendingOffers();
      final filtered = trendingDtos
          .where((o) => o.merchantName.toLowerCase().contains(query.toLowerCase()) || o.title.toLowerCase().contains(query.toLowerCase()))
          .map((dto) => dto.toEntity())
          .toList();
      return Right(filtered);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
