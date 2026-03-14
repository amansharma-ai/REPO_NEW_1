import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/challenge_repo.dart';
import '../data/models/daily_challenge.dart';

final challengeRepositoryProvider = Provider((ref) => ChallengeRepository());

final todayChallengesProvider = FutureProvider<List<DailyChallenge>>((ref) {
  return ref.watch(challengeRepositoryProvider).getTodayChallenges();
});
