import 'package:flutter/material.dart';
import 'package:imogoat/models/feeback.dart';
import 'package:imogoat/repositories/feedback_repository.dart';

class ControllerFeedback extends ChangeNotifier {
  final FeedbackRepository _repository;
  bool loading = false;
  var _feedbacks = <FeedbackModel>[];
  List<FeedbackModel> get feedbacks => _feedbacks;
  bool result = true;

  ControllerFeedback({required FeedbackRepository repository})
      : _repository = repository;

  /// Cria e envia um novo feedback para um imóvel.
  ///
  /// Define [loading] como `true` antes da operação e `false` após.
  ///
  /// @param rating A pontuação de 1 a 5 dada ao imóvel.
  /// @param comment O comentário do usuário.
  /// @param userId O ID do usuário que está avaliando.
  /// @param immobileId O ID do imóvel que está sendo avaliado.
  /// @returns Uma [Future] que resolve para `true` se o feedback foi criado com sucesso.
  Future<bool> createFeedback(
      int rating, String comment, int userId, int immobileId) async {
    loading = true;
    notifyListeners();

    final feedback = FeedbackModel(
      rating: rating,
      comment: comment,
      userId: userId,
      immobileId: immobileId,
    );

    final result = await _repository.createFeedback(feedback);

    loading = false;
    notifyListeners();
    return result;
  }

  /// Busca e atualiza a lista de feedbacks para um imóvel específico.
  ///
  /// 1. Define [loading] como `true` e notifica os listeners.
  /// 2. Chama o método de busca do repositório.
  /// 3. Armazena o resultado em [_feedbacks] e define [result] como `true` ou `false`.
  /// 4. Garante que [loading] seja definido como `false` e notifica os listeners no bloco `finally`.
  ///
  /// @param immobileId O ID do imóvel cujos feedbacks devem ser buscados.
  Future<void> fetchFeedbacksByImmobile(int immobileId) async {
    try {
      loading = true;
      notifyListeners();

      final feedbacks = await _repository.buscarFeedbacksPorImovel(immobileId);

      _feedbacks = feedbacks;
      result = true;
    } catch (error) {
      print('Erro ao carregar feedbacks: $error');
      result = false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
