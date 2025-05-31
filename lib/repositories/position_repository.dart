import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agpop/models/position_model.dart';

class PositionRepository {
  final _firestore = FirebaseFirestore.instance;
  final _collectionName = 'positions';

  Future<List<PositionModel>> getPositions() async {
    try {
      final snapshot = await _firestore.collection(_collectionName).get();
      return snapshot.docs.map((doc) => PositionModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Erro ao buscar as funções: $e');
      throw Exception('Falha ao carregar funções. Tente novamente.');
    }
  }

  Future<List<PositionModel>> getActivePositions() async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('is_active', isEqualTo: true)
          .get();
      return snapshot.docs.map((doc) => PositionModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Erro ao buscar funções ativas: $e');
      throw Exception('Falha ao carregar funções ativas. Tente novamente.');
    }
  }

  Future<void> update(String positionId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_collectionName).doc(positionId).update(data);
    } catch (e) {
      print('Erro ao atualizar a função $positionId: $e');
      throw Exception('Falha ao atualizar a função. Verifique a conexão e tente novamente.');
    }
  }

  Future<void> add(PositionModel position) async {
    try {
      await _firestore.collection(_collectionName).add(position.toMap());
    } catch (e) {
      print('Erro ao adicionar função: $e');
      throw Exception('Falha ao adicionar função. Tente novamente.');
    }
  }

  Future<void> delete(String positionId) async {
    try {
      await _firestore.collection(_collectionName).doc(positionId).delete();
    } catch (e) {
      print('Erro ao excluir função: $e');
      throw Exception('Falha ao excluir função. Tente novamente.');
    }
  }

  Future<int> getCount() async {
    try {
      final aggregateQuery = await _firestore.collection(_collectionName).count().get();
      return aggregateQuery.count ?? 0;
    } catch (e) {
      print('Erro ao contar funções: $e');
      throw Exception('Falha ao contar funções. Tente novamente.');
    }
  }
}