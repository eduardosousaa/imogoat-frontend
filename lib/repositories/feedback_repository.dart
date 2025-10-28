import 'package:imogoat/models/feeback.dart';
import 'package:imogoat/models/rest_client.dart';

class FeedbackRepository {
  final RestClient _rest;

  FeedbackRepository({required RestClient restClient}) : _rest = restClient;

  /// Cria um novo feedback no servidor.
  Future<bool> createFeedback(FeedbackModel feedback) async {
    try {
      await _rest.post('/create-feedback', feedback.toMap());
      return true;
    } catch (error) {
      print('Erro ao criar feedback: $error');
      return false;
    }
  }

  /// Busca todos os feedbacks de um imóvel específico.
  Future<List<FeedbackModel>> buscarFeedbacksPorImovel(int immobileId) async {
    try {
      // CORREÇÃO: Chamar o endpoint do imóvel que contém os feedbacks aninhados
      final response = await _rest.get('/immobile/$immobileId');

      // O endpoint /immobile/$immobileId retorna um Map que contém a lista de feedbacks
      if (response is Map<String, dynamic>) {
        final feedbacksData = response['feedbacks']; // Extrair a lista aninhada

        // Verifica se a chave 'feedbacks' existe e é uma List
        if (feedbacksData is List) {
          return feedbacksData
              .map<FeedbackModel>(
                  (item) => FeedbackModel.fromMap(item as Map<String, dynamic>))
              .toList();
        } else {
          // Caso a chave 'feedbacks' não seja uma lista (ou seja null/vazia)
          return [];
        }
      }

      // Se a resposta não for um Map (tipo inesperado), loga e retorna vazio
      print('Resposta inesperada da API (Não é um Map): $response');
      return [];
    } catch (error) {
      print('Erro ao buscar feedbacks: $error');
      return [];
    }
  }
}
