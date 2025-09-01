import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jetcv__utenti/l10n/app_localizations.dart';
import 'package:jetcv__utenti/services/locale_service.dart';
import 'package:jetcv__utenti/services/user_service.dart';
import 'package:jetcv__utenti/supabase/supabase_config.dart';

class LanguageSelector extends StatefulWidget {
  final bool showAsCard;

  const LanguageSelector({
    super.key,
    this.showAsCard = true,
  });

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  final TextEditingController _searchController = TextEditingController();
  List<Locale> _filteredLocales = [];
  bool _showDropdown = false;
  final GlobalKey _buttonKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _showAbove = false; // Track dropdown position

  @override
  void initState() {
    super.initState();
    _filteredLocales = LocaleService.fullyTranslatedLocales;
  }

  @override
  void dispose() {
    _cleanupOverlay();
    _searchController.dispose();
    super.dispose();
  }

  void _cleanupOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _showDropdown = false;
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {
        _showDropdown = false;
      });
    }
  }

  void _showOverlayDropdown() {
    if (_showDropdown) {
      _removeOverlay();
      return;
    }

    final renderBox =
        _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    // Calculate available space above and below
    final screenHeight = MediaQuery.of(context).size.height;
    final spaceBelow = screenHeight - offset.dy - size.height;
    final spaceAbove = offset.dy;

    // Calculate actual dropdown height based on content
    final searchFieldHeight = 60.0; // Search field height
    final itemHeight = 48.0; // Height per language item
    final maxItems = 8; // Maximum items to show
    final actualDropdownHeight = searchFieldHeight +
        (itemHeight * _filteredLocales.length.clamp(0, maxItems));
    final dropdownHeight =
        actualDropdownHeight.clamp(100.0, 300.0); // Min 100, Max 300

    // Determine if we should show dropdown above or below
    _showAbove = spaceBelow < dropdownHeight && spaceAbove > dropdownHeight;
    final topPosition = _showAbove
        ? offset.dy - dropdownHeight - 4
        : offset.dy + size.height + 4;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Invisible barrier to detect taps outside
          Positioned.fill(
            child: GestureDetector(
              onTap: _removeOverlay,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          // Handle Escape key
          Positioned.fill(
            child: RawKeyboardListener(
              focusNode: FocusNode(),
              onKey: (event) {
                if (event is RawKeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.escape) {
                  _removeOverlay();
                }
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          // Actual dropdown menu
          Positioned(
            left: offset.dx,
            top: topPosition,
            width: size.width,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: 300,
                  minHeight: 100,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search field
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _searchController,
                        onChanged: _filterLocales,
                        autofocus: true, // Auto-focus on search field
                        onFieldSubmitted: (value) {
                          // Prevent form submission when Enter is pressed
                          return;
                        },
                        onTapOutside: (event) {
                          // Close dropdown when clicking outside
                          _removeOverlay();
                        },
                        decoration: InputDecoration(
                          hintText: _getSearchHintText(),
                          prefixIcon: const Icon(Icons.search, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.3),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                    // Language list
                    Flexible(
                      child: _filteredLocales.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                _getNoLanguageFoundText(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: _filteredLocales.length,
                              itemBuilder: (context, index) {
                                final locale = _filteredLocales[index];
                                final languageName = LocaleService.instance
                                    .getLanguageName(locale.languageCode);
                                final languageEmoji = LocaleService.instance
                                    .getLanguageEmoji(locale.languageCode);
                                final currentLocale =
                                    LocaleService.instance.currentLocale;
                                final isSelected =
                                    currentLocale?.languageCode ==
                                        locale.languageCode;

                                return InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () => _selectLanguage(locale),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    child: Row(
                                      children: [
                                        if (languageEmoji != null) ...[
                                          Text(
                                            languageEmoji,
                                            style:
                                                const TextStyle(fontSize: 20),
                                          ),
                                          const SizedBox(width: 12),
                                        ],
                                        Expanded(
                                          child: Text(
                                            languageName,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontWeight: isSelected
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                  color: isSelected
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .primary
                                                      : null,
                                                ),
                                          ),
                                        ),
                                        if (isSelected)
                                          Icon(
                                            Icons.check,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            size: 20,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _showDropdown = true;
      _searchController.clear();
      _filteredLocales = LocaleService.fullyTranslatedLocales;
    });
  }

  String _getSearchHintText() {
    final localizations = AppLocalizations.of(context);
    if (localizations != null) {
      // Try to get localized search text, fallback to English
      switch (localizations.localeName) {
        case 'it':
          return 'Cerca lingua...';
        case 'es':
          return 'Buscar idioma...';
        case 'fr':
          return 'Rechercher une langue...';
        case 'de':
          return 'Sprache suchen...';
        default:
          return 'Search language...';
      }
    }
    return 'Search language...';
  }

  String _getNoLanguageFoundText() {
    final localizations = AppLocalizations.of(context);
    if (localizations != null) {
      // Try to get localized no results text, fallback to English
      switch (localizations.localeName) {
        case 'it':
          return 'Nessuna lingua trovata';
        case 'es':
          return 'No se encontró ningún idioma';
        case 'fr':
          return 'Aucune langue trouvée';
        case 'de':
          return 'Keine Sprache gefunden';
        default:
          return 'No language found';
      }
    }
    return 'No language found';
  }

  void _filterLocales(String query) {
    // Update filtered locales without triggering a full rebuild
    final newFilteredLocales = query.isEmpty
        ? LocaleService.fullyTranslatedLocales
        : LocaleService.fullyTranslatedLocales.where((locale) {
            final languageName =
                LocaleService.instance.getLanguageName(locale.languageCode);
            return languageName.toLowerCase().contains(query.toLowerCase()) ||
                locale.languageCode.toLowerCase().contains(query.toLowerCase());
          }).toList();

    // Only update if the list actually changed
    if (!_listEquals(_filteredLocales, newFilteredLocales)) {
      setState(() {
        _filteredLocales = newFilteredLocales;
      });
    }
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _selectLanguage(Locale locale) async {
    _removeOverlay();

    // Prima salviamo localmente la lingua
    await LocaleService.instance.setLocale(locale);

    // La UI si aggiorna automaticamente grazie al listener nel main.dart

    // Poi proviamo a salvare sul server (se l'utente è autenticato)
    try {
      final currentUser = SupabaseConfig.client.auth.currentUser;
      if (currentUser != null) {
        await UserService.updateUser(currentUser.id, {
          'languageCodeApp': locale.languageCode,
        });
        debugPrint(
            '✅ Lingua ${locale.languageCode} salvata nel profilo utente');
      }
    } catch (e) {
      // Se il salvataggio su server fallisce, non interrompiamo l'esperienza utente
      debugPrint('⚠️ Errore nel salvare la lingua nel profilo: $e');
      // La lingua rimane comunque salvata localmente e funzionante
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    if (!widget.showAsCard) {
      return _buildDropdownOnly();
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.language,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  localizations?.languageSettings ?? 'Language Settings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDropdownOnly(),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownOnly() {
    final localizations = AppLocalizations.of(context);
    final currentLocale = LocaleService.instance.currentLocale;
    final currentLanguageName = currentLocale != null
        ? LocaleService.instance.getLanguageName(currentLocale.languageCode)
        : localizations?.selectLanguage ?? 'Select Language';
    final currentLanguageEmoji = currentLocale != null
        ? LocaleService.instance.getLanguageEmoji(currentLocale.languageCode)
        : null;

    return GestureDetector(
      key: _buttonKey,
      onTap: _showOverlayDropdown,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Row(
          children: [
            if (currentLanguageEmoji != null) ...[
              Text(
                currentLanguageEmoji,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 12),
            ] else ...[
              Icon(
                Icons.language,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations?.language ?? 'Language',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    currentLanguageName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              _showDropdown
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
