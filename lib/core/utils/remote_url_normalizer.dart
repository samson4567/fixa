String? normalizeRemoteUrl(String? rawUrl) {
  final value = rawUrl?.trim();
  if (value == null || value.isEmpty) {
    return null;
  }

  if (value.startsWith('assets/') ||
      value.startsWith('mock://') ||
      value.startsWith('file://') ||
      value.startsWith('data:')) {
    return value;
  }

  final parsed = Uri.tryParse(value);
  if (parsed != null && parsed.hasScheme) {
    return value;
  }

  final origin = _apiOrigin();
  if (origin == null || origin.isEmpty) {
    return value;
  }

  if (value.startsWith('//')) {
    final scheme = Uri.tryParse(origin)?.scheme;
    return scheme == null || scheme.isEmpty ? 'https:$value' : '$scheme:$value';
  }

  final baseUri = Uri.tryParse(origin);
  if (baseUri == null) {
    return value;
  }

  final normalizedPath = value.startsWith('/') ? value : '/$value';
  return baseUri.resolve(normalizedPath).toString();
}

String? _apiOrigin() {
  try {
    final apiUrl = AppEnv().apiUrl.trim();
    if (apiUrl.isEmpty) {
      return null;
    }

    final parsed = Uri.tryParse(apiUrl);
    if (parsed == null || !parsed.hasScheme || parsed.host.isEmpty) {
      return apiUrl;
    }

    return parsed.origin;
  } catch (_) {
    return null;
  }
}
