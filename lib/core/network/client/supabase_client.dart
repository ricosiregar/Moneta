import 'package:supabase_flutter/supabase_flutter.dart';

/// Helper client and table constants for Supabase
class SupabaseTables {
  static const String profiles = 'profiles';
  static const String categories = 'categories';
  static const String transactions = 'transactions';
  static const String budgetLimits = 'budget_limits';
  static const String spendingChallenges = 'spending_challenges';
}

extension SupabaseClientX on SupabaseClient {
  User? get currentUser => auth.currentUser;
  String? get currentUserId => auth.currentUser?.id;
}
