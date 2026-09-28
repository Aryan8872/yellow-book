class TokenStorage {
  String? accessToken;
  String? refreshToken;

  void save(String access, String refresh) {
    accessToken = access;
    refreshToken = refresh;
  }

  void clear() {
    accessToken = null;
    refreshToken = null;
  }

  bool hasAccess() => accessToken != null && accessToken!.isNotEmpty;
}