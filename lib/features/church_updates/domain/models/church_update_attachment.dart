enum ChurchUpdateAttachmentKind {
  image,
  pdf,
  document,
}

class ChurchUpdateAttachment {
  const ChurchUpdateAttachment({
    required this.name,
    required this.url,
    required this.contentType,
    required this.sizeBytes,
    required this.kind,
  });

  final String name;
  final String url;
  final String contentType;
  final int sizeBytes;
  final ChurchUpdateAttachmentKind kind;

  factory ChurchUpdateAttachment.fromMap(Map<String, dynamic> map) {
    final name = map['name'] as String? ?? 'Attachment';
    final url = map['url'] as String? ?? '';
    final contentType = map['contentType'] as String? ?? 'application/octet-stream';
    final size = map['sizeBytes'];
    final kindRaw = map['kind'] as String?;

    return ChurchUpdateAttachment(
      name: name,
      url: url,
      contentType: contentType,
      sizeBytes: size is int ? size : size is num ? size.toInt() : 0,
      kind: _kindFromString(kindRaw) ?? _kindFromName(name, contentType),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'url': url,
      'contentType': contentType,
      'sizeBytes': sizeBytes,
      'kind': kind.name,
    };
  }

  static ChurchUpdateAttachmentKind? _kindFromString(String? raw) {
    return switch (raw) {
      'image' => ChurchUpdateAttachmentKind.image,
      'pdf' => ChurchUpdateAttachmentKind.pdf,
      'document' => ChurchUpdateAttachmentKind.document,
      _ => null,
    };
  }

  static ChurchUpdateAttachmentKind _kindFromName(
    String name,
    String contentType,
  ) {
    final lower = name.toLowerCase();
    if (contentType.startsWith('image/') ||
        lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp')) {
      return ChurchUpdateAttachmentKind.image;
    }
    if (contentType == 'application/pdf' || lower.endsWith('.pdf')) {
      return ChurchUpdateAttachmentKind.pdf;
    }
    return ChurchUpdateAttachmentKind.document;
  }
}

String churchUpdateAttachmentContentType(String fileName) {
  final lower = fileName.toLowerCase();
  return switch (lower) {
    _ when lower.endsWith('.png') => 'image/png',
    _ when lower.endsWith('.jpg') || lower.endsWith('.jpeg') => 'image/jpeg',
    _ when lower.endsWith('.gif') => 'image/gif',
    _ when lower.endsWith('.webp') => 'image/webp',
    _ when lower.endsWith('.pdf') => 'application/pdf',
    _ when lower.endsWith('.doc') => 'application/msword',
    _ when lower.endsWith('.docx') =>
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    _ when lower.endsWith('.xls') => 'application/vnd.ms-excel',
    _ when lower.endsWith('.xlsx') =>
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    _ when lower.endsWith('.ppt') => 'application/vnd.ms-powerpoint',
    _ when lower.endsWith('.pptx') =>
      'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    _ when lower.endsWith('.txt') => 'text/plain',
    _ => 'application/octet-stream',
  };
}

String formatAttachmentSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
