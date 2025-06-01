import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:agpop/models/user_model.dart';
import 'package:agpop/models/position_model.dart';
import 'package:agpop/models/task_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference get usersRef => _firestore.collection('users');
  CollectionReference get positionsRef => _firestore.collection('positions');
  CollectionReference get tasksRef => _firestore.collection('tasks');
  CollectionReference get userPositionsRef => _firestore.collection('user_positions');
  CollectionReference get taskPositionsRef => _firestore.collection('task_positions');
  CollectionReference get taskUsersRef => _firestore.collection('task_users');

  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await usersRef.doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UserModel>> getAllUsers({bool? isActive}) async {
    try {
      Query query = usersRef.orderBy('name');
      
      if (isActive != null) {
        query = query.where('is_active', isEqualTo: isActive);
      }
      
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createUser(UserModel user) async {
    try {
      await usersRef.doc(user.id).set(user.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await usersRef.doc(user.id).update(user.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleUserStatus(String userId, bool isActive) async {
    try {
      await usersRef.doc(userId).update({'is_active': isActive});
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PositionModel>> getAllPositions({bool? isActive}) async {
    try {
      Query query = positionsRef.orderBy('name');
      
      if (isActive != null) {
        query = query.where('is_active', isEqualTo: isActive);
      }
      
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => PositionModel.fromFirestore(doc)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createPosition(PositionModel position) async {
    try {
      final docRef = await positionsRef.add(position.toMap());
      await positionsRef.doc(docRef.id).update({'id': docRef.id});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePosition(PositionModel position) async {
    try {
      await positionsRef.doc(position.id).update(position.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> togglePositionStatus(String positionId, bool isActive) async {
    try {
      await positionsRef.doc(positionId).update({'is_active': isActive});
    } catch (e) {
      rethrow;
    }
  }

  Future<List<TaskModel>> getAllTasks({TaskStatus? status}) async {
    try {
      Query query = tasksRef.orderBy('due_at');
      
      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }
      
      final snapshot = await query.get();
      List<TaskModel> tasks = [];
      
      for (var doc in snapshot.docs) {
        final task = TaskModel.fromFirestore(doc);
        
        final userTasksSnapshot = await taskUsersRef
            .where('task_id', isEqualTo: task.id)
            .get();
        
        List<String> userIds = userTasksSnapshot.docs
            .map((doc) => doc['user_id'] as String)
            .toList();
        
        final positionTasksSnapshot = await taskPositionsRef
            .where('task_id', isEqualTo: task.id)
            .get();
        
        List<String> positionIds = positionTasksSnapshot.docs
            .map((doc) => doc['position_id'] as String)
            .toList();
        
        tasks.add(task.copyWith(
          assignedUserIds: userIds,
          assignedPositionIds: positionIds,
        ));
      }
      
      return tasks;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<TaskModel>> getTasksForUser(String userId) async {
    try {
      final userTasksSnapshot = await taskUsersRef
          .where('user_id', isEqualTo: userId)
          .get();
      
      List<String> taskIds = userTasksSnapshot.docs
          .map((doc) => doc['task_id'] as String)
          .toList();
      
      if (taskIds.isEmpty) {
        return [];
      }
      
      List<TaskModel> tasks = [];
      
      for (var taskId in taskIds) {
        final taskDoc = await tasksRef.doc(taskId).get();
        if (taskDoc.exists) {
          tasks.add(TaskModel.fromFirestore(taskDoc));
        }
      }
      
      return tasks;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> createTask(TaskModel task) async {
    try {
      final docRef = await tasksRef.add(task.toMap());
      final taskId = docRef.id;
      await tasksRef.doc(taskId).update({'id': taskId});
      
      for (var userId in task.assignedUserIds) {
        await taskUsersRef.add({
          'task_id': taskId,
          'user_id': userId
        });
      }
      
      for (var positionId in task.assignedPositionIds) {
        await taskPositionsRef.add({
          'task_id': taskId,
          'position_id': positionId
        });
      }
      
      return taskId;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      await tasksRef.doc(task.id).update(task.toMap());
      
      final userTasksSnapshot = await taskUsersRef
          .where('task_id', isEqualTo: task.id)
          .get();
      
      for (var doc in userTasksSnapshot.docs) {
        await doc.reference.delete();
      }
      
      for (var userId in task.assignedUserIds) {
        await taskUsersRef.add({
          'task_id': task.id,
          'user_id': userId
        });
      }
      
      final positionTasksSnapshot = await taskPositionsRef
          .where('task_id', isEqualTo: task.id)
          .get();
      
      for (var doc in positionTasksSnapshot.docs) {
        await doc.reference.delete();
      }
      
      for (var positionId in task.assignedPositionIds) {
        await taskPositionsRef.add({
          'task_id': task.id,
          'position_id': positionId
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    try {
      final taskDoc = await tasksRef.doc(taskId).get();
      final data = taskDoc.data() as Map<String, dynamic>?;

      final updateData = <String, dynamic>{
        'status': status.name
      };

      final startAt = data?['start_at'];
      final isStarted = status == TaskStatus.started;
      final isCompleted = status == TaskStatus.completed;

      if (isStarted && startAt == null) {
        updateData['start_at'] = FieldValue.serverTimestamp();
      }

      if (isCompleted) {
        updateData['complete_at'] = FieldValue.serverTimestamp();
      }

      await tasksRef.doc(taskId).update(updateData);
    } catch (e) {
      rethrow;
    }
  }


  Future<void> deleteTask(String taskId) async {
    try {
      final userTasksSnapshot = await taskUsersRef
          .where('task_id', isEqualTo: taskId)
          .get();
      
      for (var doc in userTasksSnapshot.docs) {
        await doc.reference.delete();
      }
      
      final positionTasksSnapshot = await taskPositionsRef
          .where('task_id', isEqualTo: taskId)
          .get();
      
      for (var doc in positionTasksSnapshot.docs) {
        await doc.reference.delete();
      }
      
      await tasksRef.doc(taskId).delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> getPositionsForUser(String userId) async {
    try {
      final snapshot = await userPositionsRef
          .where('user_id', isEqualTo: userId)
          .get();
      
      return snapshot.docs
          .map((doc) => doc['position_id'] as String)
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> assignPositionToUser(String userId, String positionId) async {
    try {
      await userPositionsRef.add({
        'user_id': userId,
        'position_id': positionId
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removePositionFromUser(String userId, String positionId) async {
    try {
      final snapshot = await userPositionsRef
          .where('user_id', isEqualTo: userId)
          .where('position_id', isEqualTo: positionId)
          .get();
      
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String> uploadFile(String path, dynamic file) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteFile(String path) async {
    try {
      await _storage.ref().child(path).delete();
    } catch (e) {
      rethrow;
    }
  }
}
