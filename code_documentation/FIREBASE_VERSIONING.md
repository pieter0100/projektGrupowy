# Firebase Configuration Management

## Description

This document describes the backup and versioning process for Firebase configuration: Firestore rules, indexes, and Cloud Functions. It ensures repeatable export/import and version control in the repository.

## Prerequisites

- Firebase CLI installed: `npm install -g firebase-tools`
- Authenticated with Firebase: `firebase login`
- Access to the Firebase project (projektgrupowy-ba8f2)

## Files

The following files are version-controlled in this repository:

- **`firestore.rules`** - Firestore security rules
- **`firestore.indexes.json`** - Firestore database indexes (including users.nickname index)
- **`firebase.json`** - Firebase project and emulator configuration
- **`functions/index.ts`** - Cloud Functions source code

```
projektGrupowy/
├── firestore.rules        ← Copy of security rules
├── firestore.indexes.json ← Copy of indexes
├── functions/
│   └── index.ts           ← Cloud Functions code
└── firebase.json          ← Configuration file
```

## API/Rules

### Backup Procedure

#### Export Rules

```bash
# Export Firestore rules
npm run backup:rules
# or
firebase firestore:rules > firestore.rules
```

#### Export Indexes

```bash
# Export Firestore indexes
npm run backup:indexes
# or
firebase firestore:indexes > firestore.indexes.json
```

#### Backup Functions

Cloud Functions code in `functions/` is version-controlled in Git. Publish via:
```bash
firebase deploy --only functions
```

#### Backup All
```bash
# Export both rules and indexes
npm run backup:all

# Commit to git
git add firestore.rules firestore.indexes.json functions/
git commit -m "Backup: Firebase configuration"
git push
```

### Restore/Deploy Procedure

#### Import Rules
```bash
# Deploy rules
npm run deploy:rules
# or
firebase deploy --only firestore:rules
```

#### Import Indexes
```bash
# Deploy indexes
npm run deploy:indexes
# or
firebase deploy --only firestore:indexes
```

#### Deploy Functions
```bash
# Deploy functions
npm run deploy:functions
# or
firebase deploy --only functions
```

#### Deploy All
```bash
# Deploy everything
npm run deploy:all
# or
firebase deploy --only firestore:rules,firestore:indexes,functions
```

## Environments

Separate projectId for dev/prod using Firebase aliases:

### Configure Aliases

Configure aliases for different environments:

```bash
# Set up dev environment (if using separate dev project)
firebase use --add
# Select your dev project and give it alias 'dev'

# Set up production environment
firebase use --add
# Select your production project and give it alias 'prod'

# Switch between environments
firebase use dev
firebase use prod

# Check current project
firebase use
```

## Environments

Separate projectId for dev/prod using Firebase aliases:

### Configure Aliases

```bash
# Set up dev environment
firebase use --add
# Select your dev project and give it alias 'dev'

# Set up production environment
firebase use --add
# Select your production project and give it alias 'prod'

# Switch between environments
firebase use dev
firebase use prod

# Check current project
firebase use
```

## Tests

### Manual Testing: Export

```bash
# 1. Start Firebase emulators or use dev project
firebase emulators:start

# 2. Run export in emulator/dev project; files update
npm run backup:rules
npm run backup:indexes

# Verify files changed
git diff firestore.rules
git diff firestore.indexes.json
```

### Manual Testing: Deploy

```bash
# 1. Deploy rules and indexes to emulator/dev
firebase use dev
npm run deploy:rules
npm run deploy:indexes

# 2. Run rules tests - should pass
npm run test:rules
```

### Complete Backup & Deploy Cycle Example

```bash
# 1. Export rules and indexes
npm run backup:all

# 2. Commit to git
git add firestore.rules firestore.indexes.json functions/
git commit -m "Backup: Firebase configuration - $(date +%Y-%m-%d)"
git push origin dev
## Additional Information

### Complete Backup & Deploy Cycle Example

**Full Export (Backup)**
```bash
# 1. Export rules and indexes
npm run backup:all

# 2. Commit to git
git add firestore.rules firestore.indexes.json functions/
git commit -m "Backup: Firebase configuration - $(date +%Y-%m-%d)"
git push origin dev
```

**Full Deploy (Restore/Deploy)**
```bash
# 1. Ensure you're on the correct environment
firebase use dev  # or prod

# 2. Deploy all configurations
npm run deploy:all

# 3. Verify deployment
firebase firestore:indexes  # Check indexes
firebase functions:list     # Check functions
```

### Firestore Indexes in Repository

The project includes the following indexes in `firestore.indexes.json`:

1. **users.profile.displayName** - For sorting users by display name
2. **users.profile.nickname** - For unique nickname validation and queries
3. **results** (uid + timestamp) - For user result queries
4. **progress** (uid + lastUpdated) - For user progress tracking
5. **levelProgress** (lastPlayedAt) - For recent play history
6. **leaderboards.entries** - For leaderboard queries

The **users.nickname index** is critical for:
- Checking nickname uniqueness during registration
- Querying users by nickname
- Validating nicknames in parallel requests
