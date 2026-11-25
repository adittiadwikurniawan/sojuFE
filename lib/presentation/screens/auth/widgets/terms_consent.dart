import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';

/// Baris persetujuan syarat & ketentuan (frame `546:1547`,
/// node `546:1611` + `546:1614`).
class TermsConsent extends StatefulWidget {
  const TermsConsent({
    super.key,
    required this.scale,
    required this.value,
    required this.onChanged,
    this.onOpenTerms,
    this.onOpenPrivacy,
    this.errorText,
  });

  final double scale;
  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onOpenTerms;
  final VoidCallback? onOpenPrivacy;

  /// Pesan galat bila persetujuan belum dicentang.
  final String? errorText;

  @override
  State<TermsConsent> createState() => _TermsConsentState();
}

class _TermsConsentState extends State<TermsConsent> {
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () => widget.onOpenTerms?.call();
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () => widget.onOpenPrivacy?.call();
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle body = TextStyle(
      fontFamily: AppTypography.wordmarkFamily,
      fontSize: 14 * widget.scale,
      fontWeight: FontWeight.w500,
      height: 22 / 14,
      color: const Color(0xFF131313),
    );
    final TextStyle linkStyle = body.copyWith(color: SojuColors.link);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 22 * widget.scale,
              height: 22 * widget.scale,
              child: Checkbox(
                value: widget.value,
                onChanged: (bool? checked) =>
                    widget.onChanged(checked ?? false),
                activeColor: SojuColors.primary,
                checkColor: SojuColors.surface,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4 * widget.scale),
                ),
                side: BorderSide(
                  color: SojuColors.textMuted,
                  width: 1.5 * widget.scale,
                ),
              ),
            ),
            SizedBox(width: 8 * widget.scale),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: body,
                  children: <InlineSpan>[
                    const TextSpan(text: 'Dengan mendaftar, kamu menyetujui '),
                    TextSpan(
                      text: 'Syarat Layanan',
                      style: linkStyle,
                      recognizer: _termsRecognizer,
                      semanticsLabel: 'Syarat Layanan',
                    ),
                    const TextSpan(text: ' dan '),
                    TextSpan(
                      text: 'Kebijakan Privasi',
                      style: linkStyle,
                      recognizer: _privacyRecognizer,
                      semanticsLabel: 'Kebijakan Privasi',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (widget.errorText != null)
          Padding(
            padding: EdgeInsets.only(
              left: 30 * widget.scale,
              top: 4 * widget.scale,
            ),
            child: Text(
              widget.errorText!,
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 12 * widget.scale,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}
