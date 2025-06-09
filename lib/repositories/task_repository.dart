import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agpop/models/task_model.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

class TaskRepository {
  final _firestore = FirebaseFirestore.instance;
  final _collectionName = 'tasks';

  Future<List<TaskModel>> getTasks() async {
    try {
      final snapshot = await _firestore.collection(_collectionName).get();
      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar as tarefas: $e');
      }
      throw Exception('Falha ao carregar tarefas. Tente novamente.');
    }
  }

  Future<List<TaskModel>> getActiveTasks() async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('is_active', isEqualTo: true)
          .get();
      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar tarefas ativas: $e');
      }
      throw Exception('Falha ao carregar tarefas ativas. Tente novamente.');
    }
  }

  Future<void> update(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_collectionName).doc(userId).update(data);
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao atualizar a tarefa $userId: $e');
      }
      throw Exception('Falha ao atualizar a tarefa. Verifique a conexão e tente novamente.');
    }
  }

  Future<void> add(TaskModel user) async {
    try {
      await _firestore.collection(_collectionName).add(user.toMap());
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao adicionar tarefa: $e');
      }
      throw Exception('Falha ao adicionar tarefa. Tente novamente.');
    }
  }

  Future<void> delete(String userId) async {
    try {
      await _firestore.collection(_collectionName).doc(userId).delete();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao excluir tarefa: $e');
      }
      throw Exception('Falha ao excluir tarefa. Tente novamente.');
    }
  }
  
  Future<int> getCount() async {
    try {
      final aggregateQuery = await _firestore.collection(_collectionName).count().get();
      return aggregateQuery.count ?? 0;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao contar tarefas: $e');
      }
      throw Exception('Falha ao contar tarefas. Tente novamente.');
    }
  }

  Future<int> getPendingCount() async {
    try {
      final aggregateQuery = await _firestore
          .collection(_collectionName)
          .where('status', isEqualTo: 'pending') // ou TaskStatus.pending.name
          .count()
          .get();

      return aggregateQuery.count ?? 0;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao contar tarefas pendentes: $e');
      }
      throw Exception('Falha ao contar tarefas pendentes. Tente novamente.');
    }
  }

}