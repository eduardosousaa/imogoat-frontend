import 'dart:io';
import 'package:flutter/material.dart';
import 'package:imogoat/repositories/image_repository.dart';

class ControllerImage extends ChangeNotifier {
  final ImageRepository _imageRepository;

  bool loading = false;
  bool result = true;

  ControllerImage({required ImageRepository imageRepository})
      : _imageRepository = imageRepository;

  /// Envia uma lista de arquivos de imagem para serem associados a um imóvel.
  ///
  /// 1. Define o estado de carregamento ([loading]) como `true` e notifica os listeners.
  /// 2. Chama [ImageRepository.createImage] para realizar o upload.
  /// 3. Em caso de sucesso, o estado [result] permanece `true`.
  /// 4. Em caso de erro, [result] é definido como `false` e o erro é registrado.
  /// 5. No bloco `finally`, [loading] é definido como `false` e os listeners são notificados.
  ///
  /// @param path O endpoint da API para o upload.
  /// @param url A lista de arquivos [File] (imagens) a serem enviadas.
  /// @param immobileId O ID do imóvel ao qual estas imagens serão associadas.
  Future<void> createImage(String path, List<File> url, int immobileId) async {
    try {
      loading = true;
      result = true;
      notifyListeners();

      await _imageRepository.createImage(path, url, immobileId);
    } catch (e) {
      result = false;
      debugPrint('Erro ao enviar as imagens: $e');
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}