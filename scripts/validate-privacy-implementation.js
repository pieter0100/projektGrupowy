// Comprehensive Privacy Rules Validation
const fs = require('fs');

console.log('Validating Firestore Privacy Rules Implementation...');

try {
    // Read the rules file
    const rulesContent = fs.readFileSync('firestore.rules', 'utf8');

    const requirements = {
        userDataPrivacy: {
            name: 'User data privacy (users, user_results, game_progress)',
            checks: [
                { name: 'Users collection with owner check', pattern: /match \/users\/\{uid\}.*isOwner\(uid\)/s },
                { name: 'User results with UID validation', pattern: /match \/user_results.*resource\.data\.uid == request\.auth\.uid/s },
                { name: 'Game progress with UID validation', pattern: /match \/game_progress.*resource\.data\.uid == request\.auth\.uid/s }
            ]
        },

        immutableResults: {
            name: 'Immutable user_results documents',
            checks: [
                { name: 'No updates allowed', pattern: /user_results.*allow update.*if false/s },
                { name: 'No deletes allowed', pattern: /user_results.*allow.*delete.*if false/s }
            ]
        },

        publicData: {
            name: 'Public data access (bez autoryzacji)',
            checks: [
                { name: 'Levels public read', pattern: /match \/levels.*allow read: if true/s },
                { name: 'Leaderboards public read', pattern: /match \/leaderboards.*allow read: if true/s }
            ]
        },

        authentication: {
            name: 'Authentication requirements',
            checks: [
                { name: 'Auth helper function', pattern: /function isAuthenticated\(\).*request\.auth != null/s },
                { name: 'Owner helper function', pattern: /function isOwner.*request\.auth\.uid == uid/s }
            ]
        },

        serverOnlyWrites: {
            name: 'Server-only writes for public data',
            checks: [
                { name: 'Levels no user writes', pattern: /match \/levels.*allow write: if false/s },
                { name: 'Leaderboards no user writes', pattern: /match \/leaderboards.*allow write: if false/s }
            ]
        }
    };

    let allPassed = true;
    let totalChecks = 0;
    let passedChecks = 0;

    console.log('\nRequirements Validation:');

    Object.entries(requirements).forEach(([key, req]) => {
        console.log(`\n${req.name}:`);
        req.checks.forEach(check => {
            totalChecks++;
            const passed = check.pattern.test(rulesContent);
            const status = passed ? 'PASS' : 'FAIL';
            console.log(`  ${status} ${check.name}`);
            if (passed) passedChecks++;
            if (!passed) allPassed = false;
        });
    });

    console.log('\nCollection Name Verification:');

    // Check for correct collection names
    const correctNames = {
        userResults: rulesContent.includes('match /user_results/{'),
        gameProgress: rulesContent.includes('match /game_progress/{'),
        levels: rulesContent.includes('match /levels/{'),
        leaderboards: rulesContent.includes('match /leaderboards/{'),
        users: rulesContent.includes('match /users/{')
    };

    Object.entries(correctNames).forEach(([name, found]) => {
        const status = found ? 'PASS' : 'FAIL';
        console.log(`  ${status} ${name} collection defined`);
        if (!found) allPassed = false;
    });

    // Check for old/incorrect collection names
    const oldNames = [
        { name: 'Old "results" collection', pattern: /match \/results\/\{/ },
        { name: 'Old "progress" collection', pattern: /match \/progress\/\{/ }
    ];

    oldNames.forEach(check => {
        const found = check.pattern.test(rulesContent);
        if (found) {
            console.log(`  FAIL ${check.name} found (should be removed)`);
            allPassed = false;
        } else {
            console.log(`  PASS ${check.name} not found`);
        }
    });

    console.log('\nSummary:');
    console.log(`Passed: ${passedChecks}/${totalChecks} checks`);

    if (allPassed) {
        console.log('ALL REQUIREMENTS IMPLEMENTED CORRECTLY!');
        console.log('\nImplementation Status: COMPLETE');
        console.log('Privacy rules: Enforced');
        console.log('Immutable results: Enforced');
        console.log('Public data access: Enabled');
        console.log('Authentication: Required for user data');
        console.log('Server-only writes: Enforced');
    } else {
        console.log('Some requirements not fully implemented');
        console.log('Please review the failed checks above');
    }

    console.log('\nNext Steps:');
    console.log('1. Run tests: npm run test:rules');
    console.log('2. Start emulator: npm run emulator:start');
    console.log('3. Deploy rules: firebase deploy --only firestore:rules');

} catch (error) {
    console.error('Error validating rules:', error.message);
    process.exit(1);
}
