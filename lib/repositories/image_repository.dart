import 'dart:io';
import 'package:dio/dio.dart';
import 'package:imogoat/models/rest_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageRepository {
  final RestClient _rest;

  ImageRepository({required RestClient restClient}) : _rest = restClient;

  Future<bool> createImage(String path, List<File> url, int immobileId) async {
    try {
      FormData formData = FormData.fromMap({
        'img': await Future.wait(
          url.map((image) async => await MultipartFile.fromFile(image.path)).toList(),
        ),
        'immobileId': immobileId,
      });
      print(formData);
      
      SharedPreferences _sharedPreferences =
        await SharedPreferences.getInstance();
      String? token = _sharedPreferences.getString('token');

      Response response = await Dio().post(
        'http://192.168.1.131:5000/create-image',
        data: formData,
        options: Options(
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          }
        )
      );
      print(response);
      return true;
    } catch (error) {
      print('Erro ao criar imagem: $error');
      return false;
    }
  }
}
