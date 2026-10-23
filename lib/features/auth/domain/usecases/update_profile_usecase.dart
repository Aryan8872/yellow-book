import 'package:dartz/dartz.dart';
import 'package:entertainer/core/errors/failure.dart';
import 'package:entertainer/core/usecase/usecase.dart';
import 'package:entertainer/features/auth/domain/entities/user.dart';
import 'package:entertainer/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

class UpdateProfileParams {
  final String name;
  final String? phone;
  final String? avatarUrl;

  const UpdateProfileParams({
    required this.name,
    this.phone,
    this.avatarUrl,
  });
}

@Injectable()
class UpdateProfileUsecase {
  final AuthRepository repository;

  UpdateProfileUsecase(this.repository);

  Future<Either<Failure, User>> call(UpdateProfileParams params) =>
      repository.updateProfile(params);
}
