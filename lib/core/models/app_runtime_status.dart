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
}
