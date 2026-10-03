import 'package:dartz/dartz.dart';
import 'package:entertainer/core/errors/failure.dart';
import 'package:entertainer/features/auth/domain/entities/user.dart';
import 'package:entertainer/features/auth/domain/repositories/auth_repository.dart';
import 'package:entertainer/features/auth/domain/usecases/register_params.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class RegisterUsecase {
  final AuthRepository repository;

  RegisterUsecase(this.repository);

  Future<Either<Failure,User>> call (RegisterParams params)=>
      repository.register(params.name, params.email, params.phone, params.password);
}