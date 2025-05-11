import 'auth_api.dart';
import 'user_api.dart';

class ApiManager {
  static final ApiManager _instance = ApiManager._internal();
  late AuthApi auth;
  late UserApi user;
  
  factory ApiManager() {
    return _instance;
  }
  
  ApiManager._internal() {
    auth = AuthApi();
    user = UserApi();
  }
}