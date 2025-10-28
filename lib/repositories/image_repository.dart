import 'dart:io';
import 'package:dio/dio.dart';
import 'package:imogoat/models/rest_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageRepository {
  final RestClient _rest;

  ImageRepository({required RestClient restClient}) : _rest = restClient;

  /// Envia uma ou mais imagens para a API, associando-as a um imóvel específico.
  ///
  /// Este método lida com:
  /// 1. Criação do [FormData] com as imagens (usando [MultipartFile]) e o [immobileId].
  /// 2. Recuperação do token de autenticação ([token]) das [SharedPreferences].
  /// 3. Execução de uma requisição POST diretamente via [Dio] para o endpoint de upload.
  ///
  /// @param path O endpoint da API para a requisição (embora o URL esteja fixo no corpo).
  /// @param url Uma lista de arquivos [File] (imagens) a serem carregadas.
  /// @param immobileId O ID do imóvel ao qual as imagens pertencerão.
  /// @returns Uma [Future] que resolve para `true` se o upload for bem-sucedido,
  ///          ou `false` em caso de falha (erro de rede, timeout, etc.).
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
        'http://192.168.1.194:5000/create-image',
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
