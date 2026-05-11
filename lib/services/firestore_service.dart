import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Reference to the user's tasks collection
  CollectionReference get _taskRef =>
      _db.collection('users').doc(_auth.currentUser!.uid).collection('tasks');

  // List of tasks for the current user
  Stream<List<Task>> getTasks() {
    return _taskRef
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Task(
              title: data['title'],
              description: data['description'],
              dateTime: (data['dateTime'] as Timestamp).toDate(),
              isCompleted: data['isCompleted'],
            );
          }).toList(),
        );
  }

  // NEW TASK
  Future<void> addTask(Task task) async {
    await _taskRef.add({
      'title': task.title,
      'description': task.description,
      'dateTime': Timestamp.fromDate(task.dateTime),
      'isCompleted': task.isCompleted,
    });
  }

  // UPDATE TASK
  Future<void> toggleTask(String taskId, bool currentStatus) async {
    await _taskRef.doc(taskId).update({'isCompleted': !currentStatus});
  }

  // DELETE TASK
  Future<void> deleteTask(String taskId) async {
    await _taskRef.doc(taskId).delete();
  }
}
