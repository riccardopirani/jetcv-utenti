# Setup Supabase Storage per Profile Pictures

## Bucket Configuration

Per il corretto funzionamento del caricamento delle foto profilo, è necessario configurare un bucket di storage su Supabase:

### 1. Creazione del Bucket

1. Vai su **Supabase Dashboard** > **Storage**
2. Clicca su **"New bucket"**
3. Nome bucket: `profile-pictures`
4. **Public bucket**: ✅ **ABILITATO** (le foto profilo devono essere pubblicamente accessibili)
5. **File size limit**: 5MB (5242880 bytes)
6. **Allowed MIME types**: `image/jpeg, image/png, image/webp`

### 2. RLS Policies (Row Level Security)

Aggiungi queste policy per il bucket `profile-pictures`:

#### Policy 1: Upload (INSERT)
```sql
-- Permette agli utenti autenticati di caricare immagini nelle proprie cartelle
CREATE POLICY "Users can upload profile pictures" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'profile-pictures' AND
  auth.uid()::text = (storage.foldername(name))[1] AND
  auth.role() = 'authenticated'
);
```

#### Policy 2: Read (SELECT)
```sql
-- Permette a tutti di vedere le foto profilo (sono pubbliche)
CREATE POLICY "Profile pictures are publicly viewable" ON storage.objects
FOR SELECT USING (bucket_id = 'profile-pictures');
```

#### Policy 3: Update (UPDATE)
```sql
-- Permette agli utenti di aggiornare le proprie foto profilo
CREATE POLICY "Users can update their profile pictures" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'profile-pictures' AND
  auth.uid()::text = (storage.foldername(name))[1] AND
  auth.role() = 'authenticated'
) WITH CHECK (
  bucket_id = 'profile-pictures' AND
  auth.uid()::text = (storage.foldername(name))[1] AND
  auth.role() = 'authenticated'
);
```

#### Policy 4: Delete (DELETE)
```sql
-- Permette agli utenti di eliminare le proprie foto profilo
CREATE POLICY "Users can delete their profile pictures" ON storage.objects
FOR DELETE USING (
  bucket_id = 'profile-pictures' AND
  auth.uid()::text = (storage.foldername(name))[1] AND
  auth.role() = 'authenticated'
);
```

### 3. Struttura delle Cartelle

Il servizio organizza i file con questa struttura:
```
profile-pictures/
├── [userId1]/
│   └── [userId1]_profile_[timestamp].jpg
├── [userId2]/
│   └── [userId2]_profile_[timestamp].png
└── ...
```

### 4. Configurazione CORS (se necessario)

Se hai problemi con CORS, aggiungi questa configurazione nel tuo progetto Supabase:

```json
{
  "allowedOrigins": ["http://localhost:3000", "https://yourdomain.com"],
  "allowedMethods": ["GET", "POST", "PUT", "DELETE", "HEAD"],
  "allowedHeaders": ["*"],
  "maxAge": 3600
}
```

## Test della Configurazione

Dopo aver configurato tutto:

1. **Test Upload**: Prova a caricare una foto profilo dall'app
2. **Test View**: Verifica che la foto appaia correttamente
3. **Test Update**: Prova a sostituire la foto
4. **Test Delete**: Prova a rimuovere la foto

### URL di Test Esempio

Le foto caricate avranno URL simili a:
```
https://[PROJECT_ID].supabase.co/storage/v1/object/public/profile-pictures/[USER_ID]/[USER_ID]_profile_[TIMESTAMP].jpg
```

## Risoluzione Problemi

### Errore 401 (Unauthorized)
- Verifica che l'utente sia autenticato
- Controlla le policy RLS

### Errore 403 (Forbidden)
- Verifica le policy RLS
- Assicurati che l'utente stia caricando nella sua cartella

### Errore 413 (File Too Large)
- Il file supera 5MB
- Ridimensiona l'immagine prima del caricamento

### Errore 415 (Unsupported Media Type)
- Il formato file non è supportato
- Usa solo JPG, PNG, o WebP