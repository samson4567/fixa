String? resolveRemoteMediaUrl(String? rawUrl) {
  final trimmed = rawUrl?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }

  if (trimmed.startsWith('assets/')) {
    return trimmed;
  }

  if (trimmed.startsWith('/') || trimmed.startsWith('file://')) {
    return trimmed;
  }

  final parsed = Uri.tryParse(trimmed);
  final apiUri = Uri.tryParse(AppEnv().apiUrl);
  if (parsed == null || parsed.hasScheme || apiUri == null) {
    return trimmed;
  }

  return apiUri.resolveUri(parsed).toString();
}
