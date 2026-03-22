class AppRuntimeStatus {
  const AppRuntimeStatus({
    required this.supabaseConfigured,
    required this.liveDataAvailable,
    required this.aiServerAvailable,
  });

  final bool supabaseConfigured;
  final bool liveDataAvailable;
  final bool aiServerAvailable;

  bool get isDemoMode => !liveDataAvailable;

  bool get needsSetup => !supabaseConfigured;

  String get label {
    if (needsSetup) return 'SETUP';
    if (liveDataAvailable) return 'LIVE';
    return 'NO DATA';
  }
}
