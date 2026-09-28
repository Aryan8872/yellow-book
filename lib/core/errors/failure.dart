abstract class Failure {
  final String message;
  const Failure([this.message='An error occured']);
}

class ServerFailure extends Failure{
  const ServerFailure([super.message = 'Server error']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([ super.message = 'No Internet connection']);
}
class AuthFailure extends Failure{
  const AuthFailure([super.message = 'Auth error occurred']);
}