import 'dart:io';
import 'package:dio/dio.dart';
import 'package:imogoat/models/rest_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioCliente extends RestClient {
  Dio dio = Dio(BaseOptions(baseUrl: 'http://192.168.1.131:5000'));

  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? params}) async {
    SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();
    String? token = _sharedPreferences.getString('token');

    final response = await dio.get(path,
        queryParameters: params,
        options: Options(headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          'content-Type': 'application/json'
        }));

    return response.data;
  }

  @override
  Future<Map> post(String path, Map<String, dynamic> data) async {
    SharedPreferences _sharedPreferences =
        await SharedPreferences.getInstance();

    String? token = _sharedPreferences.getString('token');
    final response = await dio.post(path,
        data: data,
        options: Options(headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          'content-Type': 'application/json'
        }));
    return response.data;
  }

  @override
  Future<Map> put(String path, Map<String, dynamic> data) async {
    SharedPreferences _sharedPreferences =
        await SharedPreferences.getInstance();

    String? token = _sharedPreferences.getString('token');
    final response = await dio.put(path,
        data: data,
        options: Options(headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          'content-Type': 'application/json'
        }));
    return response.data;
  }

  @override
  Future<Map> delete(String path, String data) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    String? token = sharedPreferences.getString('token');
    print('Token: $token');

    try {
      final response = await dio.delete('$path/$data',
          options: Options(headers: {
            HttpHeaders.authorizationHeader: 'Bearer $token',
            'content-Type': 'application/json'
          }));
      print('Path: $response');
      return response.data;
    } catch (e) {
      print('Erro $e');
      rethrow;
    }
  }
}