import 'package:dartz/dartz.dart';
import 'package:entertainer/core/errors/failure.dart';
import 'package:entertainer/core/usecase/usecase.dart';
import 'package:entertainer/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class ForgotPasswordUsecase {
  final AuthRepository repository;

  ForgotPasswordUsecase(this.repository);

  Future<Either<Failure, void>> call(String email) =>
      repository.forgotPassword(email);
}
