import 'package:dartz/dartz.dart';
import 'package:entertainer/core/errors/failure.dart';
import 'package:entertainer/core/usecase/usecase.dart';
import 'package:entertainer/features/auth/domain/entities/user.dart';
import 'package:entertainer/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

class GoogleAuthParams {
  final String idToken;

  const GoogleAuthParams({required this.idToken});
}

@Injectable()
class GoogleAuthUsecase {
  final AuthRepository repository;

  GoogleAuthUsecase(this.repository);

  Future<Either<Failure, User>> call(GoogleAuthParams params) =>
      repository.googleAuth(params.idToken);
}
