import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/auth_repo.dart';

final authRepoProvider = Provider<AuthRepo>((ref) {
  return AuthRepo();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepoProvider).authStateChanges;
});
