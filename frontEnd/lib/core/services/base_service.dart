// filepath: c:\Users\abdulazeezbrhomi\OneDrive\University\Epi\Sem3\flutter\epiApp\lib\core\services\base_service.dart
abstract class BaseService {
  final ApiClient apiClient;

  BaseService(this.apiClient);

  String get basePath;
}

class ApiClient {
  // This would be the same as your existing ApiClient
  // Including all the methods we enhanced
}
