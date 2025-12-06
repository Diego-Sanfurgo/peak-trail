Map<String, dynamic> normalizeMap(Map? m) {
  final result = <String, dynamic>{};
  if (m == null) return result;
  m.forEach((key, value) {
    final k = key?.toString() ?? '';
    result[k] = _normalizeValue(value);
  });
  return result;
}

dynamic _normalizeValue(dynamic v) {
  if (v is Map) return normalizeMap(v);
  if (v is List) return v.map(_normalizeValue).toList();
  return v;
}