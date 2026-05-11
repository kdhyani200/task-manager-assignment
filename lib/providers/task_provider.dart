import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../services/firestore_service.dart';
import 'auth_gate.dart';

final firestoreServiceProvider = Provider((ref) => FirestoreService());

final rawTasksProvider = StreamProvider<List<Task>>((ref) {
  // Watch auth state. If it changes to null, this whole provider invalidates.
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return ref.watch(firestoreServiceProvider).getTasks();
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});
