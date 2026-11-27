import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/themes/soju_colors.dart';

/// Widget foto produk dengan mode **Smart Auto-Fit Utuh**:
/// - Gambar tampil utuh 100% (`BoxFit.contain`) tanpa terpotong.
/// - Latar belakang otomatis memakai versi blur lembut (`BoxFit.cover`) agar
///   rasio vertikal/horizontal tetap rapi dan estetik di semua ukuran kartu.
/// - Opsional [enableLightbox] untuk tap-to-zoom layar penuh dengan `InteractiveViewer`.
class SmartAutoFitImage extends StatelessWidget {
  const SmartAutoFitImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
    this.enableLightbox = false,
    this.heroTag,
    this.placeholderIcon = Icons.fastfood_rounded,
    this.placeholderLabel,
  });

  final String? imageUrl;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final bool enableLightbox;
  final Object? heroTag;
  final IconData placeholderIcon;
  final String? placeholderLabel;

  @override
  Widget build(BuildContext context) {
    final trimmed = imageUrl?.trim() ?? '';
    final Widget content = ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: width,
        height: height,
        child: trimmed.isEmpty
            ? _buildPlaceholder()
            : _SmartImageCanvas(
                source: trimmed,
                placeholder: _buildPlaceholder(),
              ),
      ),
    );

    final Widget wrapped = heroTag != null
        ? Hero(tag: heroTag!, child: content)
        : content;

    if (!enableLightbox || trimmed.isEmpty) {
      return wrapped;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: () => _openLightbox(context, trimmed),
        child: Stack(
          fit: StackFit.passthrough,
          children: <Widget>[
            wrapped,
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.zoom_in_rounded,
                      size: 13,
                      color: Colors.white,
                    ),
                    SizedBox(width: 3),
                    Text(
                      'Zoom',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFFEFF6FF), Color(0xFFE2E8F0)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              placeholderIcon,
              size: 28,
              color: SojuColors.brandNavy.withOpacity(0.45),
            ),
            if (placeholderLabel != null && placeholderLabel!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  placeholderLabel!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: SojuColors.brandNavy.withOpacity(0.55),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openLightbox(BuildContext context, String source) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.88),
      builder: (BuildContext dialogContext) {
        return Dialog.fullscreen(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: <Widget>[
              Center(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4.0,
                  child: _buildRawImage(
                    source: source,
                    fit: BoxFit.contain,
                    errorWidget: _buildPlaceholder(),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: SafeArea(
                  child: IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.65),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Tutup pratinjau',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SmartImageCanvas extends StatelessWidget {
  const _SmartImageCanvas({
    required this.source,
    required this.placeholder,
  });

  final String source;
  final Widget placeholder;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF1F5F9),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // Latar blur lembut agar tidak ada letterbox kaku.
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Opacity(
              opacity: 0.35,
              child: _buildRawImage(
                source: source,
                fit: BoxFit.cover,
                errorWidget: const SizedBox.shrink(),
              ),
            ),
          ),
          // Foto utama utuh 100% tanpa crop.
          _buildRawImage(
            source: source,
            fit: BoxFit.contain,
            errorWidget: placeholder,
          ),
        ],
      ),
    );
  }
}

Widget _buildRawImage({
  required String source,
  required BoxFit fit,
  required Widget errorWidget,
}) {
  if (source.startsWith('data:image/')) {
    final Uint8List? bytes = _decodeDataUri(source);
    if (bytes == null || bytes.isEmpty) {
      return errorWidget;
    }
    return Image.memory(
      bytes,
      fit: fit,
      errorBuilder: (_, __, ___) => errorWidget,
    );
  }

  if (source.startsWith('assets/')) {
    return Image.asset(
      source,
      fit: fit,
      errorBuilder: (_, __, ___) => errorWidget,
    );
  }

  return Image.network(
    source,
    fit: fit,
    errorBuilder: (_, __, ___) => errorWidget,
    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? progress) {
      if (progress == null) return child;
      return const Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: SojuColors.brandNavy,
          ),
        ),
      );
    },
  );
}

Uint8List? _decodeDataUri(String dataUri) {
  final int commaIndex = dataUri.indexOf(',');
  if (commaIndex == -1) return null;
  try {
    return base64Decode(dataUri.substring(commaIndex + 1).trim());
  } catch (_) {
    return null;
  }
}
