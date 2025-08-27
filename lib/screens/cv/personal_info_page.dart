import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jetcv__utenti/models/user_model.dart';
import 'package:jetcv__utenti/services/user_service.dart';
import 'package:jetcv__utenti/services/country_service.dart';
import 'package:jetcv__utenti/models/country_model.dart';
import 'package:jetcv__utenti/supabase/structure/enumerated_types.dart';
import 'package:jetcv__utenti/supabase/supabase_config.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:jetcv__utenti/l10n/app_localizations.dart';
import 'package:jetcv__utenti/widgets/language_selector.dart';

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;
    
    // Allow complete clearing
    if (text.isEmpty) {
      return TextEditingValue(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }
    
    // Allow only digits and + at the beginning
    if (text.startsWith('+')) {
      // Keep the + and allow only digits after it
      String filtered = '+' + text.substring(1).replaceAll(RegExp(r'[^0-9]'), '');
      return TextEditingValue(
        text: filtered,
        selection: TextSelection.collapsed(offset: filtered.length),
      );
    } else {
      // Allow only digits
      String filtered = text.replaceAll(RegExp(r'[^0-9]'), '');
      return TextEditingValue(
        text: filtered,
        selection: TextSelection.collapsed(offset: filtered.length),
      );
    }
  }
}

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;
    
    // Allow only digits and slashes
    text = text.replaceAll(RegExp(r'[^0-9/]'), '');
    
    // Allow complete clearing
    if (text.isEmpty) {
      return TextEditingValue(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }
    
    // Don't allow more than 10 characters (dd/mm/yyyy)
    if (text.length > 10) {
      return oldValue;
    }
    
    // Remove consecutive slashes
    text = text.replaceAll(RegExp(r'/+'), '/');
    
    // Don't allow slash at the beginning (but allow empty)
    if (text.startsWith('/') && text.length > 1) {
      return oldValue;
    }
    
    // If user is deleting and we have only "/" or ends with "/", allow it
    if (text == '/' || text.endsWith('/')) {
      // If we're going backwards (deleting), allow incomplete states
      if (newValue.text.length < oldValue.text.length) {
        return TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    }
    
    // Extract digits only for processing
    String digitsOnly = text.replaceAll('/', '');
    
    // If no digits, return empty
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }
    
    // Build formatted string based on digits
    String formattedText = '';
    
    // Add day (first 2 digits)
    if (digitsOnly.isNotEmpty) {
      formattedText += digitsOnly.substring(0, digitsOnly.length >= 2 ? 2 : digitsOnly.length);
      
      // Add slash after day if we have more digits or if user typed one
      if (digitsOnly.length >= 2) {
        formattedText += '/';
      }
    }
    
    // Add month (next 2 digits)
    if (digitsOnly.length > 2) {
      int monthStart = 2;
      int monthEnd = digitsOnly.length >= 4 ? 4 : digitsOnly.length;
      formattedText += digitsOnly.substring(monthStart, monthEnd);
      
      // Add slash after month if we have more digits
      if (digitsOnly.length >= 4) {
        formattedText += '/';
      }
    }
    
    // Add year (remaining digits, up to 4)
    if (digitsOnly.length > 4) {
      int yearStart = 4;
      int yearEnd = digitsOnly.length >= 8 ? 8 : digitsOnly.length;
      formattedText += digitsOnly.substring(yearStart, yearEnd);
    }
    
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class PersonalInfoPage extends StatefulWidget {
  final UserModel? initialUser;
  
  const PersonalInfoPage({
    super.key,
    this.initialUser,
  });

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers per i campi del form
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  
  // Variabili di stato
  UserModel? _currentUser;
  DateTime? _dateOfBirth;
  UserGender? _selectedGender;
  String? _selectedCountryCode;
  String? _profilePicture;
  dynamic _selectedImage; // XFile on web, File on mobile
  Uint8List? _selectedImageBytes; // For web compatibility
  bool _isUploadingImage = false; // Track upload state
  bool _isLoading = false;
  bool _isSaving = false;
  List<CountryModel> _countries = [];
  List<CountryModel> _filteredCountries = [];
  final TextEditingController _countrySearchController = TextEditingController();
  bool _showCountryDropdown = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadCountries();
    _initializeFormData();
  }

  Future<void> _loadCurrentUser() async {
    try {
      _currentUser = await UserService.getCurrentUser();
    } catch (e) {
      debugPrint('Errore nel caricamento utente corrente: $e');
    }
  }

  Future<void> _loadCountries() async {
    try {
      final countries = await CountryService.getAllCountries();
      setState(() {
        _countries = countries;
        _filteredCountries = countries;
      });
      _updateCountryTextField();
    } catch (e) {
      debugPrint('Errore nel caricamento paesi: $e');
    }
  }

  void _updateCountryTextField() {
    if (_selectedCountryCode != null && _countries.isNotEmpty) {
      final selectedCountry = _countries.firstWhere(
        (country) => country.code == _selectedCountryCode,
        orElse: () => CountryModel(
          code: '',
          name: '',
          createdAt: DateTime.now(),
          emoji: null,
        ),
      );
      if (selectedCountry.code.isNotEmpty) {
        _countrySearchController.text = selectedCountry.name;
      }
    }
  }

  void _filterCountries(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = _countries;
      } else {
        _filteredCountries = _countries.where((country) {
          return country.name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _selectCountry(CountryModel country) {
    setState(() {
      _selectedCountryCode = country.code;
      _countrySearchController.text = country.name;
      _showCountryDropdown = false;
    });
  }

  void _initializeFormData() {
    if (widget.initialUser != null) {
      final user = widget.initialUser!;
      
      // Inferisci firstName e lastName dal fullName se valorizzato
      if (user.firstName != null && user.lastName != null) {
        _firstNameController.text = user.firstName!;
        _lastNameController.text = user.lastName!;
      } else if (user.fullName != null) {
        final nameParts = user.fullName!.trim().split(' ');
        if (nameParts.length >= 2) {
          _firstNameController.text = _capitalizeWords(nameParts[0]);
          _lastNameController.text = _capitalizeWords(nameParts.sublist(1).join(' '));
        } else if (nameParts.isNotEmpty) {
          _firstNameController.text = _capitalizeWords(nameParts[0]);
        }
      }
      
      // Popola gli altri campi
      _emailController.text = user.email ?? '';
      _phoneController.text = user.phone ?? '';
      _addressController.text = user.address ?? '';
      _cityController.text = user.city ?? '';
      _stateController.text = user.state ?? '';
      _postalCodeController.text = user.postalCode ?? '';
      _dateOfBirth = user.dateOfBirth;
      if (user.dateOfBirth != null) {
        _dateOfBirthController.text = '${user.dateOfBirth!.day.toString().padLeft(2, '0')}/${user.dateOfBirth!.month.toString().padLeft(2, '0')}/${user.dateOfBirth!.year}';
      }
      _selectedGender = user.gender;
      _selectedCountryCode = user.countryCode ?? 'it'; // Default to Italy
      _profilePicture = user.profilePicture;
    } else {
      // Se non c'è un utente iniziale, imposta l'Italia come paese predefinito
      _selectedCountryCode = 'it';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _dateOfBirthController.dispose();
    _countrySearchController.dispose();
    super.dispose();
  }

  String _capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  DateTime? _parseDateFromText(String text) {
    // Check if we have a complete date (dd/mm/yyyy format)
    if (text.length != 10) return null;
    
    final parts = text.split('/');
    if (parts.length != 3) return null;
    
    try {
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      
      // Basic validation
      if (day < 1 || day > 31) return null;
      if (month < 1 || month > 12) return null;
      if (year < 1900 || year > DateTime.now().year) return null;
      
      // More detailed date validation
      final date = DateTime(year, month, day);
      if (date.day != day || date.month != month || date.year != year) {
        return null; // Invalid date (e.g., 31/02/2000)
      }
      
      return date;
    } catch (e) {
      return null;
    }
  }

  void _onDateChanged(String value) {
    final parsedDate = _parseDateFromText(value);
    setState(() {
      _dateOfBirth = parsedDate;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final localizations = AppLocalizations.of(context)!;
    
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Validate file size (5MB max)
        final fileSizeBytes = await pickedFile.length();
        if (fileSizeBytes > 5 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localizations.fileTooLarge),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        if (kIsWeb) {
          // On web, store the XFile and read bytes
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _selectedImage = pickedFile;
            _selectedImageBytes = bytes;
          });
        } else {
          // On mobile, validate file format and store as File
          final file = File(pickedFile.path);
          final extension = pickedFile.path.toLowerCase().split('.').last;
          if (!['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(localizations.unsupportedFormat),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }
          setState(() {
            _selectedImage = file;
            _selectedImageBytes = null;
          });
        }

        // Image selected successfully - will be uploaded when saving the page
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.imageSelectionError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    final localizations = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.selectPhoto),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(localizations.takePhoto),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(localizations.chooseFromGallery),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localizations.cancel),
            ),
          ],
        );
      },
    );
  }



  Future<void> _uploadProfilePicture() async {
    if (_selectedImageBytes == null || _currentUser?.idUser == null) return;
    
    final localizations = AppLocalizations.of(context)!;
    
    setState(() {
      _isUploadingImage = true;
    });

    try {
      late Uint8List fileBytes;
      late String fileName;
      late String contentType;
      
      if (kIsWeb) {
        fileBytes = _selectedImageBytes!;
        fileName = 'profile_picture_${DateTime.now().millisecondsSinceEpoch}.jpg';
        contentType = 'image/jpeg';
      } else {
        fileBytes = await _selectedImage!.readAsBytes();
        fileName = _selectedImage!.path.split('/').last;
        
        // Determina il content type dal nome del file
        final extension = fileName.toLowerCase().split('.').last;
        switch (extension) {
          case 'png':
            contentType = 'image/png';
            break;
          case 'jpg':
          case 'jpeg':
            contentType = 'image/jpeg';
            break;
          case 'webp':
            contentType = 'image/webp';
            break;
          default:
            contentType = 'image/jpeg'; // Default fallback
        }
      }

      // Ottieni il token di autenticazione dal client Supabase
      final session = SupabaseConfig.client.auth.currentSession;
      if (session?.accessToken == null) {
        throw Exception('Sessione non valida');
      }

      // Prepara la richiesta multipart - verifica che l'edge function esista
      final uri = Uri.parse('${SupabaseConfig.supabaseUrl}/functions/v1/updateUserProfilePicture');
      debugPrint('🔍 Calling edge function: $uri');
      final request = http.MultipartRequest('POST', uri);
      
      // Aggiungi headers - solo token utente, non apikey anonima
      request.headers['Authorization'] = 'Bearer ${session!.accessToken}';
      
      // Aggiungi il file con il content type corretto
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
          contentType: MediaType.parse(contentType),
        ),
      );

      // Invia la richiesta
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📋 Response status: ${response.statusCode}');
      debugPrint('📋 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        
        if (data['success'] == true) {
          // Aggiorna l'URL della foto profilo nell'UI solo se non siamo in modalità salvataggio
          if (!_isSaving) {
            setState(() {
              _profilePicture = data['publicUrl'];
            });
            _showSnackBar(localizations.profilePictureUploaded);
          } else {
            // Durante il salvataggio, aggiorna solo l'URL senza mostrare messaggi
            _profilePicture = data['publicUrl'];
          }
        } else {
          throw Exception(data['message'] ?? 'Errore sconosciuto durante il caricamento');
        }
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData is Map<String, dynamic> 
          ? errorData['message'] ?? errorData['error'] ?? 'Errore ${response.statusCode}'
          : 'Errore ${response.statusCode}';
        throw Exception(errorMessage);
      }
      
    } catch (e) {
      if (!_isSaving) {
        _showSnackBar(localizations.uploadError(e.toString()), isError: true);
      } else {
        // Durante il salvataggio, rilancia l'errore per essere gestito dalla funzione chiamante
        rethrow;
      }
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }


  Future<void> _savePersonalInfo() async {
    if (!_formKey.currentState!.validate()) return;

    final localizations = AppLocalizations.of(context)!;
    
    setState(() {
      _isSaving = true;
    });

    try {
      // Upload profile picture first if a new image was selected
      bool profilePictureUploadFailed = false;
      if (_selectedImage != null || _selectedImageBytes != null) {
        try {
          await _uploadProfilePicture();
          // Clear selected image data after successful upload
          _selectedImage = null;
          _selectedImageBytes = null;
        } catch (uploadError) {
          // Se l'upload della foto fallisce, mostra l'errore ma continua con il salvataggio
          profilePictureUploadFailed = true;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localizations.photoUploadError(uploadError.toString())),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 4),
              ),
            );
          }
          // Non fare return - continua con il salvataggio dei dati utente
        }
      }
      // Prepara i dati per l'aggiornamento
      final updateData = <String, dynamic>{};
      
      if (_firstNameController.text.isNotEmpty) {
        updateData['firstName'] = _firstNameController.text.trim();
      }
      if (_lastNameController.text.isNotEmpty) {
        updateData['lastName'] = _lastNameController.text.trim();
      }
      if (_emailController.text.isNotEmpty) {
        updateData['email'] = _emailController.text.trim().toLowerCase();
      }
      if (_phoneController.text.isNotEmpty) {
        updateData['phone'] = _phoneController.text.trim();
      }
      if (_addressController.text.isNotEmpty) {
        updateData['address'] = _addressController.text.trim();
      }
      if (_cityController.text.isNotEmpty) {
        updateData['city'] = _cityController.text.trim();
      }
      if (_stateController.text.isNotEmpty) {
        updateData['state'] = _stateController.text.trim();
      }
      if (_postalCodeController.text.isNotEmpty) {
        updateData['postalCode'] = _postalCodeController.text.trim();
      }
      if (_dateOfBirth != null) {
        updateData['dateOfBirth'] = _dateOfBirth!.toIso8601String().split('T')[0];
      }
      if (_selectedGender != null) {
        updateData['gender'] = _selectedGender!.toDbString();
      }
      if (_selectedCountryCode != null) {
        updateData['countryCode'] = _selectedCountryCode;
      }
      // Profile picture update is handled by the Edge Function, so we don't pass it here

      // Ottieni l'utente corrente per l'ID
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Utente non trovato');
      }

      // Aggiorna i dati tramite Edge Function
      final result = await UserService.updateUser(currentUser.idUser, updateData);
      
      if (mounted) {
        if (result['success'] == true) {
          // Personalizza il messaggio in base al successo dell'upload della foto
          final successMessage = profilePictureUploadFailed 
              ? localizations.informationSavedWithPhotoError
              : localizations.informationSaved;
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successMessage),
              backgroundColor: profilePictureUploadFailed ? Colors.orange : Colors.green,
              duration: Duration(seconds: profilePictureUploadFailed ? 5 : 3),
            ),
          );
          Navigator.of(context).pop(true); // Ritorna true per indicare il successo
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? result['error'] ?? 'Errore durante il salvataggio'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.saveError(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.personalInformation),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          // Close country dropdown when tapping outside
          if (_showCountryDropdown) {
            setState(() {
              _showCountryDropdown = false;
              _updateCountryTextField();
            });
          }
          // Hide keyboard
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Intestazione
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.yourProfile,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  AppLocalizations.of(context)!.enterYourPersonalInfo,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),

                // Foto profilo
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(60),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(57),
                            child: _selectedImage != null 
                                ? (kIsWeb
                                    ? Image.memory(
                                        _selectedImageBytes!,
                                        width: 114,
                                        height: 114,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        _selectedImage as File,
                                        width: 114,
                                        height: 114,
                                        fit: BoxFit.cover,
                                      ))
                                : _profilePicture != null 
                                    ? Image.network(
                                        _profilePicture!,
                                        width: 114,
                                        height: 114,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Icon(
                                          Icons.person,
                                          size: 56,
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                      )
                                    : Icon(
                                        Icons.person_add_alt_1,
                                        size: 56,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                                      ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: _isUploadingImage ? null : _showImageSourceDialog,
                        icon: _isUploadingImage
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(
                                _selectedImage != null || _profilePicture != null 
                                    ? Icons.edit 
                                    : Icons.add_a_photo,
                              ),
                        label: Text(
                          _isUploadingImage
                              ? AppLocalizations.of(context)!.uploading
                              : _selectedImage != null || _profilePicture != null 
                                  ? AppLocalizations.of(context)!.replacePhoto
                                  : AppLocalizations.of(context)!.addPhoto,
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Sezione: Informazioni anagrafiche
                _buildSectionHeader(AppLocalizations.of(context)!.personalData),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextFormField(
                        controller: _firstNameController,
                        label: AppLocalizations.of(context)!.firstName,
                        icon: Icons.person_outline,
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return AppLocalizations.of(context)!.firstNameRequired;
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextFormField(
                        controller: _lastNameController,
                        label: AppLocalizations.of(context)!.lastName,
                        icon: Icons.person_outline,
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return AppLocalizations.of(context)!.lastNameRequired;
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildGenderDropdown(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDateField(),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Sezione: Contatti
                _buildSectionHeader(AppLocalizations.of(context)!.contactInformation),
                const SizedBox(height: 16),

                _buildTextFormField(
                  controller: _emailController,
                  label: AppLocalizations.of(context)!.email,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return AppLocalizations.of(context)!.emailRequired;
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                      return AppLocalizations.of(context)!.validEmailRequired;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                _buildTextFormField(
                  controller: _phoneController,
                  label: AppLocalizations.of(context)!.phone,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [PhoneInputFormatter()],
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return AppLocalizations.of(context)!.phoneRequired;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Sezione: Indirizzo
                _buildSectionHeader(AppLocalizations.of(context)!.address),
                const SizedBox(height: 16),

                _buildTextFormField(
                  controller: _addressController,
                  label: AppLocalizations.of(context)!.address,
                  icon: Icons.home_outlined,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return AppLocalizations.of(context)!.addressRequired;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextFormField(
                        controller: _cityController,
                        label: AppLocalizations.of(context)!.city,
                        icon: Icons.location_city_outlined,
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return AppLocalizations.of(context)!.cityRequired;
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextFormField(
                        controller: _stateController,
                        label: AppLocalizations.of(context)!.state,
                        icon: Icons.map_outlined,
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return AppLocalizations.of(context)!.stateRequired;
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextFormField(
                        controller: _postalCodeController,
                        label: AppLocalizations.of(context)!.postalCode,
                        icon: Icons.local_post_office_outlined,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.characters,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return AppLocalizations.of(context)!.postalCodeRequired;
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildCountryDropdown(),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Sezione: Selezione Lingua
                const LanguageSelector(showAsCard: false),

                const SizedBox(height: 24),

                // Pulsante di salvataggio
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _savePersonalInfo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(AppLocalizations.of(context)!.saving),
                            ],
                          )
                        : Text(
                            AppLocalizations.of(context)!.saveInformation,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    TextCapitalization? textCapitalization,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
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
    );
  }

  Widget _buildGenderDropdown() {
    final localizations = AppLocalizations.of(context)!;
    
    return DropdownButtonFormField<UserGender>(
      value: _selectedGender,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: localizations.gender,
        prefixIcon: const Icon(Icons.person_outline),
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
      items: UserGender.values.map((gender) {
        return DropdownMenuItem<UserGender>(
          value: gender,
          child: Text(
            gender.displayLabel,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedGender = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return localizations.genderRequired;
        }
        return null;
      },
    );
  }

  Widget _buildDateField() {
    final localizations = AppLocalizations.of(context)!;
    
    return TextFormField(
      controller: _dateOfBirthController,
      keyboardType: TextInputType.number,
      inputFormatters: [DateInputFormatter()],
      onChanged: _onDateChanged,
      decoration: InputDecoration(
        labelText: localizations.dateOfBirth,
        hintText: 'es. 21/10/1955',
        prefixIcon: const Icon(Icons.date_range),
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return localizations.validDateRequired;
        }
        
        // Check exact format dd/mm/yyyy
        final dateRegex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
        if (!dateRegex.hasMatch(value)) {
          return localizations.dateFormatRequired;
        }
        
        final parts = value.split('/');
        if (parts.length != 3) {
          return localizations.dateFormatRequired;
        }
        
        // Validate ranges for dd, mm, yyyy
        final day = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final year = int.tryParse(parts[2]);
        
        if (day == null || month == null || year == null) {
          return localizations.invalidDate;
        }
        
        if (day < 1 || day > 31) {
          return localizations.invalidDay;
        }
        if (month < 1 || month > 12) {
          return localizations.invalidMonth;
        }
        if (year < 1900 || year > DateTime.now().year) {
          return localizations.invalidYear(DateTime.now().year);
        }
        
        final date = _parseDateFromText(value);
        if (date == null) {
          return localizations.inexistentDate;
        }
        
        return null;
      },
    );
  }

  Widget _buildCountryDropdown() {
    // Find selected country to show in text field
    CountryModel? selectedCountry;
    if (_selectedCountryCode != null) {
      selectedCountry = _countries.firstWhere(
        (country) => country.code == _selectedCountryCode,
        orElse: () => CountryModel(
          code: '',
          name: '',
          createdAt: DateTime.now(),
          emoji: null,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _showCountryDropdown = !_showCountryDropdown;
              if (_showCountryDropdown) {
                _countrySearchController.text = '';
                _filteredCountries = _countries;
              } else if (selectedCountry != null && selectedCountry.code.isNotEmpty) {
                _countrySearchController.text = selectedCountry.name;
              }
            });
          },
          child: AbsorbPointer(
            absorbing: !_showCountryDropdown,
            child: TextFormField(
              controller: _countrySearchController,
              onChanged: _showCountryDropdown ? _filterCountries : null,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.country,
                hintText: _showCountryDropdown ? AppLocalizations.of(context)!.searchCountry : AppLocalizations.of(context)!.selectCountry,
                suffixIcon: Icon(
                  _showCountryDropdown ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                ),
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
              validator: (value) {
                if (_selectedCountryCode == null || _selectedCountryCode!.isEmpty) {
                  return AppLocalizations.of(context)!.countryRequired;
                }
                return null;
              },
              readOnly: !_showCountryDropdown,
            ),
          ),
        ),
        if (_showCountryDropdown)
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
              constraints: const BoxConstraints(maxHeight: 200),
              child: _filteredCountries.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      AppLocalizations.of(context)!.noCountryFound,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredCountries.length,
                    itemBuilder: (context, index) {
                      final country = _filteredCountries[index];
                      final isSelected = country.code == _selectedCountryCode;
                      
                      return ListTile(
                        dense: true,
                        title: Text(
                          country.name,
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
                        onTap: () => _selectCountry(country),
                      );
                    },
                  ),
            ),
      ],
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError 
            ? Theme.of(context).colorScheme.error 
            : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}