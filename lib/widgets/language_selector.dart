import 'package:flutter/material.dart';
import 'package:jetcv__utenti/services/locale_service.dart';

/// Widget per la selezione della lingua con dropdown
class LanguageSelector extends StatelessWidget {
  final bool showText;
  final Color? iconColor;
  final Color? textColor;

  const LanguageSelector({
    super.key,
    this.showText = false,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleService.instance,
      builder: (context, child) {
        final currentLocale = LocaleService.instance.currentLocale;
        final currentLanguageCode = currentLocale?.languageCode ?? 'en';

        return PopupMenuButton<String>(
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                LocaleService.instance.getLanguageEmoji(currentLanguageCode) ??
                    '🌐',
                style: const TextStyle(fontSize: 20),
              ),
              if (showText) ...[
                const SizedBox(width: 8),
                Text(
                  LocaleService.instance.getLanguageName(currentLanguageCode),
                  style: TextStyle(
                    color: textColor ?? Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              Icon(
                Icons.arrow_drop_down,
                color: iconColor ?? Theme.of(context).colorScheme.onSurface,
                size: 16,
              ),
            ],
          ),
          tooltip: 'Seleziona lingua / Select language',
          onSelected: (languageCode) async {
            await LocaleService.instance.setLocale(Locale(languageCode));
          },
          itemBuilder: (context) {
            return LocaleService.fullyTranslatedLocales.map((locale) {
              final languageCode = locale.languageCode;
              final languageName =
                  LocaleService.instance.getLanguageName(languageCode);
              final emoji =
                  LocaleService.instance.getLanguageEmoji(languageCode);
              final isSelected = currentLanguageCode == languageCode;

              return PopupMenuItem<String>(
                value: languageCode,
                child: Row(
                  children: [
                    Text(
                      emoji ?? '🌐',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        languageName,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                        size: 18,
                      ),
                  ],
                ),
              );
            }).toList();
          },
        );
      },
    );
  }
}

/// Widget compatto per la selezione della lingua (solo emoji e freccia)
class CompactLanguageSelector extends StatelessWidget {
  final Color? iconColor;

  const CompactLanguageSelector({
    super.key,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return LanguageSelector(
      showText: false,
      iconColor: iconColor,
    );
  }
}

/// Widget esteso per la selezione della lingua (emoji + testo + freccia)
class ExtendedLanguageSelector extends StatelessWidget {
  final Color? iconColor;
  final Color? textColor;

  const ExtendedLanguageSelector({
    super.key,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return LanguageSelector(
      showText: true,
      iconColor: iconColor,
      textColor: textColor,
    );
  }
}

/// Widget per AppBar con padding appropriato
class AppBarLanguageSelector extends StatelessWidget {
  final bool showText;
  final Color? iconColor;
  final Color? textColor;

  const AppBarLanguageSelector({
    super.key,
    this.showText = false,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: LanguageSelector(
        showText: showText,
        iconColor: iconColor,
        textColor: textColor,
      ),
    );
  }
}
