// lib/presentation/screens/chatbot/widgets/ai_citations_sheet.dart
//
// Bottom sheet daftar sumber sitasi Hybrid RAG AI (`[D1]`, `[SQL-1]`, dst.).

import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';
import '../../../../domain/entities/ai_chat_entity.dart';

/// Menampilkan Citations Bottom Sheet berisi judul sumber dan cuplikan teks.
Future<void> showAiCitationsSheet(
  BuildContext context, {
  required List<AiCitation> citations,
  String? selectedCitationId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext sheetContext) {
      return AiCitationsSheet(
        citations: citations,
        selectedCitationId: selectedCitationId,
      );
    },
  );
}

class AiCitationsSheet extends StatelessWidget {
  const AiCitationsSheet({
    super.key,
    required this.citations,
    this.selectedCitationId,
  });

  final List<AiCitation> citations;
  final String? selectedCitationId;

  @override
  Widget build(BuildContext context) {
    final double maxHeight = MediaQuery.of(context).size.height * 0.72;

    return Container(
      key: const Key('ai_citations_sheet'),
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: SojuColors.border,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 12, 12),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: SojuColors.infoSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.menu_book_outlined,
                      size: 18,
                      color: SojuColors.badgeBlue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'Sumber Referensi',
                          style: TextStyle(
                            fontFamily: AppTypography.family,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: SojuColors.ink,
                          ),
                        ),
                        Text(
                          '${citations.length} sumber digunakan untuk jawaban ini',
                          style: const TextStyle(
                            fontFamily: AppTypography.family,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: SojuColors.analyticsMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Tutup',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: SojuColors.analyticsLabel,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: SojuColors.hairline),
            Flexible(
              child: citations.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Tidak ada sitasi yang tersedia untuk pesan ini.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTypography.family,
                          fontSize: 13,
                          color: SojuColors.analyticsMuted,
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      itemCount: citations.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (BuildContext context, int index) {
                        final AiCitation citation = citations[index];
                        final bool highlighted =
                            selectedCitationId != null &&
                            citation.id == selectedCitationId;
                        return _CitationCard(
                          citation: citation,
                          highlighted: highlighted,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CitationCard extends StatelessWidget {
  const _CitationCard({
    required this.citation,
    required this.highlighted,
  });

  final AiCitation citation;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final String? relevanceLabel = citation.score == null
        ? null
        : 'Relevansi ${(citation.score! * 100).clamp(0, 100).round()}%';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlighted ? SojuColors.infoSoft : SojuColors.chatSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlighted ? SojuColors.primary : SojuColors.hairline,
          width: highlighted ? 1.4 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: SojuColors.primary,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  citation.chipLabel,
                  style: const TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: SojuColors.surface,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: SojuColors.hairline),
                ),
                child: Text(
                  citation.sourceTypeLabel,
                  style: const TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: SojuColors.analyticsLabel,
                  ),
                ),
              ),
              const Spacer(),
              if (relevanceLabel != null)
                Text(
                  relevanceLabel,
                  style: const TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: SojuColors.badgeBlue,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            citation.title,
            style: const TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: SojuColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            citation.excerpt,
            style: const TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: SojuColors.analyticsLabel,
            ),
          ),
          if (citation.sourceRef != null &&
              citation.sourceRef!.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              'Referensi: ${citation.sourceRef}',
              style: const TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: SojuColors.analyticsMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
