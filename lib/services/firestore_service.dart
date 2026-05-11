import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // 1. Helper to get the UID safely
  String? get _userId => _auth.currentUser?.uid;

  // 2. Updated getTasks to handle the null user case
  Stream<List<Task>> getTasks() {
    final uid = _userId;

    // If no user is logged in, return an empty list stream instead of crashing
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
              id: doc.id, // Ensure your Task model has an 'id' field!
              title: data['title'] ?? '',
              description: data['description'] ?? '',
              dateTime: (data['dateTime'] as Timestamp).toDate(),
              isCompleted: data['isCompleted'] ?? false,
            );
          }).toList(),
        );
  }

  // 3. Helper for write operations to avoid code repetition
  DocumentReference _userDoc() {
    final uid = _userId;
    if (uid == null) throw Exception("User not authenticated");
    return _db.collection('users').doc(uid);
  }

  // NEW TASK
  Future<void> addTask(Task task) async {
    await _userDoc().collection('tasks').add({
      'title': task.title,
      'description': task.description,
      'dateTime': Timestamp.fromDate(task.dateTime),
      'isCompleted': task.isCompleted,
    });
  }

  // UPDATE TASK (Added from previous step)
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

  // TOGGLE STATUS
  Future<void> toggleTask(String taskId, bool currentStatus) async {
    await _userDoc().collection('tasks').doc(taskId).update({
      'isCompleted': !currentStatus,
    });
  }

  // DELETE TASK
  Future<void> deleteTask(String taskId) async {
    await _userDoc().collection('tasks').doc(taskId).delete();
  }
}
