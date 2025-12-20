// LibreWolf user.js - Custom overrides
// This file overrides LibreWolf's default privacy settings
// Philosophy: Avoid AI integration and telemetry, not paranoid about Google/convenience

// Enable Mozilla Sync (Firefox Accounts)
user_pref("identity.fxaccounts.enabled", true);

// Disable fingerprinting protections to enable proper theming
// Note: This reduces privacy but allows websites to respect your system theme
user_pref("privacy.resistFingerprinting", false);
user_pref("privacy.baselineFingerprintingProtection", false);
user_pref("privacy.fingerprintingProtection", false);

// Enable DRM playback (Netflix, Spotify, etc.)
user_pref("media.eme.enabled", true);

// Enable search suggestions and allow adding custom search engines
user_pref("browser.urlbar.suggest.searches", true);
user_pref("browser.search.suggest.enabled", true);
user_pref("browser.search.update", true);

// Don't delete cookies and site data on shutdown (stay logged in)
user_pref("privacy.sanitize.sanitizeOnShutdown", false);
user_pref("privacy.clearOnShutdown_v2.cookiesAndStorage", false);
