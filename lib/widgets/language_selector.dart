import 'package:flutter/material.dart';
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
  
  @override
  void initState() {
    super.initState();
    _filteredLocales = LocaleService.fullyTranslatedLocales;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterLocales(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredLocales = LocaleService.fullyTranslatedLocales;
      } else {
        _filteredLocales = LocaleService.fullyTranslatedLocales.where((locale) {
          final languageName = LocaleService.instance.getLanguageName(locale.languageCode);
          return languageName.toLowerCase().contains(query.toLowerCase()) ||
                 locale.languageCode.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _selectLanguage(Locale locale) async {
    // Prima salviamo localmente la lingua
    await LocaleService.instance.setLocale(locale);
    setState(() {
      _showDropdown = false;
      _searchController.text = LocaleService.instance.getLanguageName(locale.languageCode);
    });
    
    // La UI si aggiorna automaticamente grazie al listener nel main.dart
    
    // Poi proviamo a salvare sul server (se l'utente è autenticato)
    try {
      final currentUser = SupabaseConfig.client.auth.currentUser;
      if (currentUser != null) {
        await UserService.updateUser(currentUser.id, {
          'languageCode': locale.languageCode,
        });
        debugPrint('✅ Lingua ${locale.languageCode} salvata nel profilo utente');
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
    final currentLocale = LocaleService.instance.currentLocale;
    final currentLanguageName = currentLocale != null 
        ? LocaleService.instance.getLanguageName(currentLocale.languageCode)
        : localizations?.selectLanguage ?? 'Select Language';

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _showDropdown = !_showDropdown;
              if (_showDropdown) {
                _searchController.text = '';
                _filteredLocales = LocaleService.fullyTranslatedLocales;
              } else {
                _searchController.text = currentLanguageName;
              }
            });
          },
          child: AbsorbPointer(
            absorbing: !_showDropdown,
            child: TextFormField(
              controller: _searchController,
              onChanged: _showDropdown ? _filterLocales : null,
              decoration: InputDecoration(
                labelText: localizations?.language ?? 'Language',
                hintText: _showDropdown 
                    ? 'Search language...' 
                    : currentLanguageName,
                suffixIcon: Icon(
                  _showDropdown ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                ),
                prefixIcon: currentLanguageEmoji != null 
                    ? Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          currentLanguageEmoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                      )
                    : const Icon(Icons.language),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
              readOnly: !_showDropdown,
            ),
          ),
        ),
        if (_showDropdown)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 300),
            child: _filteredLocales.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No language found',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredLocales.length,
                    itemBuilder: (context, index) {
                      final locale = _filteredLocales[index];
                      final languageName = LocaleService.instance.getLanguageName(locale.languageCode);
                      final languageEmoji = LocaleService.instance.getLanguageEmoji(locale.languageCode);
                      final isSelected = currentLocale?.languageCode == locale.languageCode;
                      
                      return ListTile(
                        dense: true,
                        leading: languageEmoji != null
                            ? Text(
                                languageEmoji,
                                style: const TextStyle(fontSize: 20),
                              )
                            : null,
                        title: Text(
                          languageName,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected 
                                ? Theme.of(context).colorScheme.primary 
                                : null,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                        onTap: () => _selectLanguage(locale),
                      );
                    },
                  ),
          ),
      ],
    );
  }
}