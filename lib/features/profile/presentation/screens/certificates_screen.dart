import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../learning/presentation/learning_progress_store.dart';

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  bool _downloading = false;
  bool _sharing = false;

  Future<void> _exportPdf(_CertificateData data, {required bool share}) async {
    if (!data.isUnlocked || _downloading || _sharing) return;
    setState(() {
      if (share) {
        _sharing = true;
      } else {
        _downloading = true;
      }
    });

    try {
      final bytes = await _buildPdf(data);
      if (share) {
        await Printing.sharePdf(bytes: bytes, filename: data.fileName);
      } else {
        await Printing.layoutPdf(
          name: data.fileName,
          onLayout: (_) async => bytes,
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            share
                ? 'Unable to share the certificate right now.'
                : 'Unable to export the certificate PDF right now.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _downloading = false;
          _sharing = false;
        });
      }
    }
  }

  Future<Uint8List> _buildPdf(_CertificateData data) async {
    final pdf = pw.Document();
    final logoBytes = await rootBundle.load(AppAssets.bioLogo);
    final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        build: (_) => pw.Container(
          padding: const pw.EdgeInsets.all(28),
          decoration: pw.BoxDecoration(
            color: PdfColors.white,
            borderRadius: pw.BorderRadius.circular(16),
            border: pw.Border.all(color: PdfColors.grey300, width: 1.5),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Row(children: [pw.Image(logo, width: 86), pw.Spacer()]),
              pw.SizedBox(height: 20),
              pw.Text(
                'CERTIFICATE',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 30,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 3,
                  color: PdfColor.fromInt(AppColors.primary.toARGB32()),
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                'OF COMPLETION',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 2,
                  color: PdfColor.fromInt(const Color(0xFF5D667D).toARGB32()),
                ),
              ),
              pw.Spacer(),
              pw.Text(
                'This certificate is proudly presented to',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 11,
                  color: PdfColor.fromInt(AppColors.textSecondary.toARGB32()),
                ),
              ),
              pw.SizedBox(height: 14),
              pw.Text(
                data.recipientName,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 25,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromInt(AppColors.primary.toARGB32()),
                ),
              ),
              pw.Divider(color: PdfColors.grey300, thickness: 1),
              pw.SizedBox(height: 12),
              pw.Text(
                'for successfully completing the ${data.courseTitle}',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(fontSize: 13),
              ),
              pw.Spacer(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Issued by: ${data.issuerName}'),
                  pw.Text('Completion Date: ${data.formattedDate}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<LearningProgressState>(
      valueListenable: LearningProgressStore.instance.progress,
      builder: (context, progress, _) {
        final data = _CertificateData.fromProgress(progress);
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            leadingWidth: 64,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16, top: 10, bottom: 10),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.backgroundGrey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final pagePadding = constraints.maxWidth >= 520 ? 24.0 : 16.0;
              final contentWidth =
                  constraints.maxWidth >= 520 ? 430.0 : double.infinity;
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(pagePadding, 4, pagePadding, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('My Certificates', style: AppTextStyles.headingLG),
                        const SizedBox(height: 4),
                        const Text(
                          'Your completed internships and certifications',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _card(data, constraints.maxWidth >= 360),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _card(_CertificateData data, bool wideButtons) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7EBF5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140A0F5C),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F5FC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEBEAF3)),
              ),
              child: AspectRatio(
                aspectRatio: 1.64,
                child: _CertificatePreview(data: data),
              ),
            ),
            const SizedBox(height: 14),
            _status(data.isUnlocked),
            const SizedBox(height: 12),
            Text(
              data.courseTitle,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.backgroundGrey,
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              ),
              child: Column(
                children: [
                  _detail('Issued by', data.issuerName),
                  const SizedBox(height: 10),
                  _detail('Completion Date', data.formattedDate),
                ],
              ),
            ),
            if (!data.isUnlocked) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                ),
                child: const Text(
                  'Complete all lessons and pass the final quiz to reveal this certificate.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                SizedBox(
                  width: wideButtons ? 171 : double.infinity,
                  child: _action(
                    icon: Icons.download_outlined,
                    label: 'Download PDF',
                    enabled: data.isUnlocked,
                    loading: _downloading,
                    onTap: () => _exportPdf(data, share: false),
                  ),
                ),
                SizedBox(
                  width: wideButtons ? 171 : double.infinity,
                  child: _action(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    enabled: data.isUnlocked,
                    loading: _sharing,
                    onTap: () => _exportPdf(data, share: true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _status(bool unlocked) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: unlocked ? AppColors.successLight : AppColors.backgroundGrey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            unlocked ? Icons.verified_outlined : Icons.lock_outline_rounded,
            size: 15,
            color: unlocked ? AppColors.success : AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            unlocked ? 'Verified Certificate' : 'Certificate Locked',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: unlocked ? AppColors.success : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detail(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _action({
    required IconData icon,
    required String label,
    required bool enabled,
    required bool loading,
    required VoidCallback onTap,
  }) {
    final color = enabled ? AppColors.textPrimary : AppColors.textHint;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      child: InkWell(
        onTap: enabled && !loading ? onTap : null,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        child: Ink(
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            border: Border.all(color: AppColors.border),
          ),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 18, color: color),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _CertificatePreview extends StatelessWidget {
  const _CertificatePreview({required this.data});

  final _CertificateData data;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFD8DFED)),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: width * 0.42,
                    height: height * 0.24,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(width * 0.22),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: width * 0.14,
                  child: Container(
                    width: width * 0.34,
                    height: height * 0.13,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(width * 0.18),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    width: width * 0.36,
                    height: height * 0.21,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(width * 0.2),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: width * 0.12,
                  child: Container(
                    width: width * 0.3,
                    height: height * 0.1,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(width * 0.16),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: height * 0.08,
                  left: width * 0.06,
                  child: Image.asset(
                    AppAssets.bioLogo,
                    width: width * 0.23,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  top: height * 0.05,
                  right: width * 0.05,
                  child: Icon(
                    Icons.military_tech_rounded,
                    size: height * 0.22,
                    color: const Color(0xFFE1B24A),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.15),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'CERTIFICATE',
                          style: TextStyle(
                            fontSize: width * 0.08,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: width * 0.01,
                          ),
                        ),
                        SizedBox(height: height * 0.01),
                        Text(
                          'OF COMPLETION',
                          style: TextStyle(
                            fontSize: width * 0.034,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF5C657D),
                            letterSpacing: 1.4,
                          ),
                        ),
                        SizedBox(height: height * 0.06),
                        Text(
                          'This certificate is proudly presented to',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: width * 0.026,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: height * 0.03),
                        Text(
                          data.recipientName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: width * 0.05,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: height * 0.01),
                        Container(
                          width: width * 0.42,
                          height: 1,
                          color: const Color(0xFFC4CBD8),
                        ),
                        SizedBox(height: height * 0.03),
                        Text(
                          'for successfully completing the ${data.courseTitle}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: width * 0.027,
                            color: const Color(0xFF4D5870),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!data.isUnlocked)
                  Positioned.fill(
                    child: Container(
                      color: Colors.white.withValues(alpha: 0.72),
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: const Color(0xFFE7EAF4)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_outline_rounded, size: 16),
                            SizedBox(width: 8),
                            Text(
                              'Certificate Locked',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CertificateData {
  const _CertificateData({
    required this.courseTitle,
    required this.recipientName,
    required this.issuerName,
    required this.completionDate,
    required this.isUnlocked,
  });

  factory _CertificateData.fromProgress(LearningProgressState progress) {
    return _CertificateData(
      courseTitle: LearningProgressState.courseTitle,
      recipientName: LearningProgressState.recipientName,
      issuerName: LearningProgressState.issuerName,
      completionDate: progress.completionDate,
      isUnlocked: progress.certificateUnlocked,
    );
  }

  final String courseTitle;
  final String recipientName;
  final String issuerName;
  final DateTime? completionDate;
  final bool isUnlocked;

  String get formattedDate => completionDate == null
      ? 'Locked until completion'
      : DateFormat('MMMM d, y').format(completionDate!);

  String get fileName =>
      '${courseTitle.toLowerCase().replaceAll(' ', '-')}-certificate.pdf';
}
