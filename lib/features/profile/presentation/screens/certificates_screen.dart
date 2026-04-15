import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/student_service.dart';
import '../../../../shared/models/user_session_store.dart';

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  final _studentService = StudentService();
  List<Map<String, dynamic>> _certs = [];
  bool _loading = true;
  String? _error;
  bool _downloading = false;
  bool _sharing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final res = await _studentService.getCertificates();
    if (!mounted) return;
    if (res.success) {
      setState(() { _certs = res.data ?? []; _loading = false; });
    } else {
      setState(() { _error = res.message ?? 'Failed to load certificates'; _loading = false; });
    }
  }

  Future<void> _exportPdf(_CertData data, {required bool share}) async {
    if (_downloading || _sharing) return;
    setState(() => share ? _sharing = true : _downloading = true);
    try {
      final bytes = await _buildPdf(data);
      if (share) {
        await Printing.sharePdf(bytes: bytes, filename: data.fileName);
      } else {
        await Printing.layoutPdf(name: data.fileName, onLayout: (_) async => bytes);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(share ? 'Unable to share certificate.' : 'Unable to export certificate PDF.')),
      );
    } finally {
      if (mounted) setState(() { _downloading = false; _sharing = false; });
    }
  }

  Future<Uint8List> _buildPdf(_CertData data) async {
    final pdf = pw.Document();
    final logoBytes = await rootBundle.load(AppAssets.bioLogo);
    final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());

    pdf.addPage(pw.Page(
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
            pw.Text('CERTIFICATE',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold,
                    letterSpacing: 3, color: PdfColor.fromInt(AppColors.primary.toARGB32()))),
            pw.SizedBox(height: 6),
            pw.Text('OF COMPLETION',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold,
                    letterSpacing: 2, color: PdfColor.fromInt(const Color(0xFF5D667D).toARGB32()))),
            pw.Spacer(),
            pw.Text('This certificate is proudly presented to',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(fontSize: 11,
                    color: PdfColor.fromInt(AppColors.textSecondary.toARGB32()))),
            pw.SizedBox(height: 14),
            pw.Text(data.recipientName,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(fontSize: 25, fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromInt(AppColors.primary.toARGB32()))),
            pw.Divider(color: PdfColors.grey300, thickness: 1),
            pw.SizedBox(height: 12),
            pw.Text('for successfully completing the ${data.courseTitle}',
                textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 13)),
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
    ));
    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Certificates'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: AppColors.error)),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _load, child: const Text('Retry')),
                    ],
                  ),
                )
              : _certs.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.workspace_premium_outlined, size: 64, color: AppColors.textHint),
                          SizedBox(height: 16),
                          Text('No certificates yet',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                          SizedBox(height: 8),
                          Text('Complete a course to earn your certificate.',
                              style: TextStyle(fontSize: 13, color: AppColors.textHint)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(AppSizes.paddingMD),
                        itemCount: _certs.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final cert = _certs[index];
                          final session = UserSessionStore.instance.state.value;
                          final data = _CertData(
                            courseTitle: cert['course_title']?.toString() ?? cert['course_name']?.toString() ?? 'Course',
                            recipientName: session.displayName.isNotEmpty ? session.displayName : 'Student',
                            issuerName: 'Bioxplora',
                            completionDate: cert['issued_at'] != null
                                ? DateTime.tryParse(cert['issued_at'].toString())
                                : null,
                          );
                          return _CertCard(
                            data: data,
                            downloading: _downloading,
                            sharing: _sharing,
                            onDownload: () => _exportPdf(data, share: false),
                            onShare: () => _exportPdf(data, share: true),
                          );
                        },
                      ),
                    ),
    );
  }
}

class _CertData {
  final String courseTitle;
  final String recipientName;
  final String issuerName;
  final DateTime? completionDate;

  const _CertData({
    required this.courseTitle,
    required this.recipientName,
    required this.issuerName,
    this.completionDate,
  });

  String get formattedDate => completionDate == null
      ? 'N/A'
      : DateFormat('MMMM d, y').format(completionDate!);

  String get fileName => '${courseTitle.toLowerCase().replaceAll(' ', '-')}-certificate.pdf';
}

class _CertCard extends StatelessWidget {
  const _CertCard({
    required this.data,
    required this.downloading,
    required this.sharing,
    required this.onDownload,
    required this.onShare,
  });

  final _CertData data;
  final bool downloading;
  final bool sharing;
  final VoidCallback onDownload;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7EBF5)),
        boxShadow: const [BoxShadow(color: Color(0x140A0F5C), blurRadius: 18, offset: Offset(0, 8))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Certificate preview
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.workspace_premium_rounded, size: 48, color: AppColors.primary),
                  const SizedBox(height: 8),
                  Text('CERTIFICATE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                      color: AppColors.primary, letterSpacing: 2)),
                  Text('OF COMPLETION', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, letterSpacing: 1)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_outlined, size: 15, color: AppColors.success),
                SizedBox(width: 6),
                Text('Verified Certificate', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(data.courseTitle, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.backgroundGrey, borderRadius: BorderRadius.circular(AppSizes.radiusMD)),
            child: Column(
              children: [
                _detail('Issued by', data.issuerName),
                const SizedBox(height: 8),
                _detail('Completion Date', data.formattedDate),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _actionBtn(icon: Icons.download_outlined, label: 'Download PDF', loading: downloading, onTap: onDownload)),
              const SizedBox(width: 10),
              Expanded(child: _actionBtn(icon: Icons.share_outlined, label: 'Share', loading: sharing, onTap: onShare)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detail(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _actionBtn({required IconData icon, required String label, required bool loading, required VoidCallback onTap}) {
    return OutlinedButton.icon(
      onPressed: loading ? null : onTap,
      icon: loading
          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
          : Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 13)),
    );
  }
}
