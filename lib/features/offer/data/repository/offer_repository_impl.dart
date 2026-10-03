import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:entertainer/core/errors/failure.dart';
import 'package:entertainer/features/offer/data/datasource/remote_data_source.dart';
import 'package:entertainer/features/offer/domain/entity/offer_entity.dart';
import 'package:entertainer/features/offer/domain/repository/offer_repository.dart';
import 'package:entertainer/features/offer/domain/usecases/offer_params.dart';

class OfferRepositoryImpl implements OfferRepository {
  final RemoteDataSource remoteDataSource;

  OfferRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, OfferEntity>> getOfferById(GetOfferByIdParams params) async {
    try {
      final response = await remoteDataSource.getOfferById(params);
      return Right(response.toEntity());
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedOfferEntity>> getPaginatedOffers(GetPaginatedOffersParams params) async {
    try {
      final response = await remoteDataSource.getPaginatedOffers(params);
      return Right(response.toEntity());
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OfferEntity>> createOffer(CreateOfferParams params) async {
    try {
      final response = await remoteDataSource.createOffer(params);
      return Right(response.toEntity());
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OfferEntity>> updateOffer(UpdateOfferParams params) async {
    try {
      final response = await remoteDataSource.updateOffer(params);
      return Right(response.toEntity());
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteOffer(DeleteOfferParams params) async {
    try {
      final success = await remoteDataSource.deleteOffer(params);
      return Right(success);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Failure _handleDioError(DioException e) {
    final serverMessage = e.response?.data is Map
        ? (e.response?.data['message'] ?? e.response?.data['error'])
        : null;
    return ServerFailure(serverMessage?.toString() ?? e.message ?? 'Server error occurred');
  }
}
