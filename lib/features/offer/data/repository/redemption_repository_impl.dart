import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:entertainer/core/errors/failure.dart';
import 'package:entertainer/core/network/interceptors/error_interceptor.dart';
import 'package:entertainer/features/offer/data/datasource/redemption_remote_datasource.dart';
import 'package:entertainer/features/offer/domain/entity/redemption_entity.dart';
import 'package:entertainer/features/offer/domain/repository/redemption_repository.dart';

class RedemptionRepositoryImpl implements RedemptionRepository {
  final RedemptionRemoteDatasource remote;

  RedemptionRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, RedemptionEntity>> initRedemption(
    String offerId, {
    String? branchId,
  }) async {
    try {
      final dto = await remote.initRedemption(offerId, branchId: branchId);
      return Right(dto.toEntity());
    } on DioException catch (e) {
      return Left(ErrorInterceptor.mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RedemptionEntity>>> getMyRedemptions(
      {String? offerId}) async {
    try {
      final dtos = await remote.getMyRedemptions(offerId: offerId);
      return Right(dtos.map((d) => d.toEntity()).toList());
    } on DioException catch (e) {
      return Left(ErrorInterceptor.mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelRedemption(String sessionId) async {
    try {
      await remote.cancelRedemption(sessionId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ErrorInterceptor.mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
