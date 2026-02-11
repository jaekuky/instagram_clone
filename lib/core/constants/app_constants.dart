class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Instagram';
  static const String appVersion = '1.0.0';

  // Supabase Tables
  static const String usersTable = 'users';
  static const String postsTable = 'posts';
  static const String commentsTable = 'comments';
  static const String likesTable = 'likes';
  static const String followsTable = 'follows';
  static const String storiesTable = 'stories';
  static const String messagesTable = 'messages';
  static const String notificationsTable = 'notifications';

  // Supabase Storage Buckets
  static const String avatarsBucket = 'avatars';
  static const String postsBucket = 'posts';
  static const String storiesBucket = 'stories';

  // Pagination
  static const int feedPageSize = 10;
  static const int searchPageSize = 20;
  static const int commentsPageSize = 20;
  static const int chatPageSize = 30;

  // Image
  static const int maxImageWidth = 1080;
  static const int maxImageHeight = 1350;
  static const int thumbnailSize = 300;
  static const double imageQuality = 0.85;

  // UI
  static const double webMaxWidth = 935.0;
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;

  // Default Avatar
  static const String defaultAvatarUrl =
      'https://upload.wikimedia.org/wikipedia/commons/a/ac/Default_pfp.jpg';
}
