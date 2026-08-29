import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/about_content.dart';
import '../version.dart';

/// Gorgeous Glassmorphic About Dialog for Tubature.
/// Supports switching between Italian and English with interactive links.
class AboutTubatureDialog extends StatefulWidget {
  const AboutTubatureDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const AboutTubatureDialog(),
    );
  }

  @override
  State<AboutTubatureDialog> createState() => _AboutTubatureDialogState();
}

class _AboutTubatureDialogState extends State<AboutTubatureDialog> {
  AboutLanguage _currentLanguage = AboutLanguage.italian;

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = AboutContent.of(_currentLanguage);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          decoration: BoxDecoration(
            color: const Color(0xFF161F28).withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFFFD54F).withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.7),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Language Switcher Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '📜 ABOUT',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFFFD54F),
                        letterSpacing: 2,
                      ),
                    ),
                    _buildLanguageToggle(),
                  ],
                ),
                const SizedBox(height: 16),

                // 2. Title & Subtitle Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFFFD54F).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        content.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFFD54F),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        content.subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF80DEEA),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 3. Story Paragraph
                Text(
                  content.storyParagraph,
                  style: const TextStyle(
                    fontSize: 14.5,
                    height: 1.55,
                    color: Color(0xFFECEFF1),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Highlight badge: Made for Ale & Sebi
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE91E63).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFF48FB1).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text('👦👦', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          content.createdFor,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF8BBD0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 5. Interactive Links & Badges
                const Text(
                  'LINKS & CREDITS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF90A4AE),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildLinkChip(
                      icon: Icons.code_rounded,
                      label: 'Riccardo (@palladius)',
                      url: AboutLinks.riccardoGithub,
                      color: const Color(0xFF64B5F6),
                    ),
                    _buildLinkChip(
                      icon: Icons.auto_awesome,
                      label: 'Antigravity',
                      url: AboutLinks.antigravity,
                      color: const Color(0xFFFFD54F),
                    ),
                    _buildLinkChip(
                      icon: Icons.flutter_dash,
                      label: 'Flutter',
                      url: AboutLinks.flutter,
                      color: const Color(0xFF4DD0E1),
                    ),
                    _buildLinkChip(
                      icon: Icons.folder_zip_rounded,
                      label: 'GitHub Repo',
                      url: AboutLinks.repository,
                      color: const Color(0xFFAED581),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // 6. Footer with Close Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'v$appVersion',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.4),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF37474F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: Text(
                        content.closeButton,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: AboutLanguage.values.map((lang) {
          final isSelected = _currentLanguage == lang;
          return InkWell(
            onTap: () => setState(() => _currentLanguage = lang),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFFD54F).withValues(alpha: 0.25)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFFD54F)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(lang.flagEmoji, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    lang.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                      color: isSelected ? const Color(0xFFFFD54F) : const Color(0xFFB0BEC5),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLinkChip({
    required IconData icon,
    required String label,
    required String url,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _launchUrl(url),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.open_in_new_rounded, size: 11, color: color.withValues(alpha: 0.7)),
            ],
          ),
        ),
      ),
    );
  }
}
