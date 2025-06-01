import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agpop/models/user_model.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

class UserRepository {
  final _firestore = FirebaseFirestore.instance;
  final _collectionName = 'users';

  Future<List<UserModel>> getUsers() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').get();
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar os usuários: $e');
      }
      throw Exception('Falha ao carregar usuários. Tente novamente.');
    }
  }

  Future<List<UserModel>> getActiveUsers() async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('is_active', isEqualTo: true)
          .get();
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar usuários ativos: $e');
      }
      throw Exception('Falha ao carregar usuários ativos. Tente novamente.');
    }
  }

  Future<void> update(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_collectionName).doc(userId).update(data);
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao atualizar o usuário $userId: $e');
      }
      throw Exception('Falha ao atualizar o usuário. Verifique a conexão e tente novamente.');
    }
  }

  Future<void> add(UserModel user) async {
    try {
      await _firestore.collection(_collectionName).doc(user.id).set(user.toMap());
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao adicionar usuário: $e');
      }
      throw Exception('Falha ao adicionar usuário. Tente novamente.');
    }
  }

  Future<void> delete(String userId) async {
    try {
      await _firestore.collection(_collectionName).doc(userId).delete();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao excluir usuário: $e');
      }
      throw Exception('Falha ao excluir usuário. Tente novamente.');
    }
  }
  
  Future<int> getCount() async {
    try {
      final aggregateQuery = await _firestore.collection(_collectionName).count().get();
      return aggregateQuery.count ?? 0;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao contar usuários: $e');
      }
      throw Exception('Falha ao contar usuários. Tente novamente.');
    }
  }
}