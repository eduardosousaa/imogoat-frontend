abstract class RestClient {
  Future<dynamic> get(String path, {Map<String, dynamic>? params});
  Future<Map> post(String path, Map<String, dynamic> data);
  Future<Map> put(String path, Map<String, dynamic> data);
  Future<Map> delete(String path, String data);
}