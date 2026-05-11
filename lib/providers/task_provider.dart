import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';

final firestoreServiceProvider = Provider((ref) => FirestoreService());

final rawTasksProvider = StreamProvider<List<Task>>((ref) {
  return ref.watch(firestoreServiceProvider).getTasks();
});

class FirestoreService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  CollectionReference get _taskRef =>
      _db.collection('users').doc(_auth.currentUser!.uid).collection('tasks');

  Stream<List<Task>> getTasks() {
    return _taskRef
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
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

  Future<void> addTask(Task task) async {
    await _taskRef.add({
      'title': task.title,
      'description': task.description,
      'dateTime': Timestamp.fromDate(task.dateTime),
      'isCompleted': false,
    });
  }

  Future<void> updateTask(
    String id,
    String title,
    String desc,
    DateTime date,
  ) async {
    await _taskRef.doc(id).update({
      'title': title,
      'description': desc,
      'dateTime': Timestamp.fromDate(date),
    });
  }

  Future<void> toggleTask(String id, bool currentStatus) async {
    await _taskRef.doc(id).update({'isCompleted': !currentStatus});
  }

  Future<void> deleteTask(String id) async {
    await _taskRef.doc(id).delete();
  }
}
