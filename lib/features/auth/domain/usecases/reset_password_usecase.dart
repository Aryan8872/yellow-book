import 'package:dartz/dartz.dart';
import 'package:entertainer/core/errors/failure.dart';
import 'package:entertainer/core/usecase/usecase.dart';
import 'package:entertainer/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class ResetPasswordUsecase {
  final AuthRepository repository;

  ResetPasswordUsecase(this.repository);

  Future<Either<Failure, void>> call(String token, String newPassword) =>
      repository.resetPassword(token, newPassword);
}
