import 'package:grpc/grpc.dart';
import 'package:app_server/user.dart';


void main() async {
  final server = Server(
    [UserService()],
  );
  await server.serve(port: 8080);
  print('Server listening on port ${server.port}...');
}
