import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // Stream of tasks
  Stream<List<Task>> getTasks() {
    final uid = _userId;

    if (uid == null) {
      return Stream.value([]);
    }

    return _db
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return Task(
              id: doc.id,
              title: data['title'] ?? '',
              description: data['description'] ?? '',
              dateTime: (data['dateTime'] as Timestamp).toDate(),
              isCompleted: data['isCompleted'] ?? false,
            );
          }).toList(),
        );
  }

  // Helper for write operations
  DocumentReference _userDoc() {
    final uid = _userId;
    if (uid == null) throw Exception("User not authenticated");
    return _db.collection('users').doc(uid);
  }

  Future<void> addTask(Task task) async {
    await _userDoc().collection('tasks').add({
      'title': task.title,
      'description': task.description,
      'dateTime': Timestamp.fromDate(task.dateTime),
      'isCompleted': task.isCompleted,
    });
  }

  Future<void> updateTask(
    String taskId,
    String title,
    String description,
    DateTime dateTime,
  ) async {
    await _userDoc().collection('tasks').doc(taskId).update({
      'title': title,
      'description': description,
      'dateTime': Timestamp.fromDate(dateTime),
    });
  }

  Future<void> toggleTask(String taskId, bool currentStatus) async {
    await _userDoc().collection('tasks').doc(taskId).update({
      'isCompleted': !currentStatus,
    });
  }

  Future<void> deleteTask(String taskId) async {
    await _userDoc().collection('tasks').doc(taskId).delete();
  }
}
