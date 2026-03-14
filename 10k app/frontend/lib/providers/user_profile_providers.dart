import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_profile.dart';
import '../data/repositories/user_profile_repo.dart';

final userProfileRepositoryProvider = Provider((ref) => UserProfileRepository());

final userProfileProvider = FutureProvider<UserProfile>(
    (ref) => ref.watch(userProfileRepositoryProvider).getProfile());
