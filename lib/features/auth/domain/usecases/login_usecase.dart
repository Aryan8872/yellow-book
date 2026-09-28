import 'package:dartz/dartz.dart';
import 'package:entertainer/core/errors/failure.dart';
import 'package:entertainer/features/auth/domain/entities/user.dart';
import 'package:entertainer/features/auth/domain/repositories/auth_repository.dart';
import 'package:entertainer/features/auth/domain/usecases/login_params.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class LoginUsecase {
  final AuthRepository repo;
  LoginUsecase(this.repo);

  Future<Either<Failure,User>>call(LoginParams params)=>
    repo.login(params.email, params.password);

}