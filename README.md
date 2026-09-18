# Ticketmaster — project guide

Last updated: 2026-09-19. Workspace: `P:\Ticketmaster`.

This README is the canonical project memory. Read the quick context first; open only the detailed section and source needed for the current task. The verification section records the checks performed and their limits.

## Quick context — read first

- Flutter/Dart app with Ticketmaster-styled editable ticket screens; Firebase Google auth, Firestore metadata, Storage images, native JSON cache.
- Mobile integrations exist for Android and iOS. Web/desktop Firebase startup is unconfigured. Event feed, barcode/map, wallet and transfer actions are partly or wholly sample UI.
- `lib/main.dart` plus six `lib/app/*.dart` part files form ONE library. Private declarations and imports are shared. State uses setState/static stores; navigation uses Navigator.
- Custom `Text` enables long-press editing; `material.Text` stays non-editable. Preserve stored text keys, ticket IDs, and normalized image crop coordinates.
- Flow: Firebase/store initialization → auth/device/session check → login or video/network splash → four-tab home. Session duration: 14 days.
- Bottom tabs: Home, Watchlist, My Tickets, Account. All four remain mounted. The legacy Sell screen remains in source but is no longer in the bottom navigation. Logout works; transfer sending, contacts and wallet actions are placeholders.
- Gestures: long-press text to edit; double-tap/long-press Upcoming for card count, Past for search, card for image options, quantity badge for per-card ticket count.
- Storage: Firestore `ticketmaster_user_state/{uid}` + `tickets/{id}`; Storage `ticketmaster_user_state/{uid}/tickets/ticket_{id}.bin`; native `ticketmaster_state/{safeUid}.json`.
- Android/Firebase baseline: Z72 builds use Flutter's configured JDK 17; the Firebase CLI default project is `ticketmaster-61fd5`. Google provider, Android package, signing SHA-1/SHA-256, and deployed Firestore rules were verified on 2026-09-18. Google users must also have an active `authorized_users/{lowercase-email}` document.
- Full source review already exists below. Do not repeat it for routine changes. Source takes precedence if documentation is stale.

## Working preference — minimize unnecessary credit use

1. Start with this quick context and the task map. If already read in the current session, reuse that context.
2. Choose relevant files, locate symbols with scoped `rg -n`, and read nearby lines. Avoid dumping whole large files or scanning the entire project by default.
3. Read only the relevant detailed README section when additional context is needed; do not automatically load all project notes.
4. Make the requested change and run checks appropriate to it. Expand investigation when dependencies, failures, or uncertainty justify it; correctness still matters.
5. Avoid repeated checks, unrelated refactors, broad tool calls, and long status/final reports. Do not delegate unless explicitly requested.
6. Update the affected README section when behavior, setup, schema, or architecture changes. Keep one current account of each fact; do not append repetitive session transcripts.

This workflow reduces repeated context reading; it does not guarantee a fixed credit cost.

## Task → source map

| Task | Start with |
| --- | --- |
| Startup, splash, routes | `lib/app/app_core.dart` |
| Login | `lib/app/auth_flow.dart` |
| Tabs, Discover, ticket list/count/search, logout | `lib/app/home_shell.dart` |
| Ticket detail/pager, barcode, transfer, metadata | `lib/app/tickets_flow.dart` |
| Editable text or persisted keys | `lib/app/editable_text.dart`; model getters in home_shell |
| Sync, sessions, device lock, serialization | `lib/app/local_persistence.dart` |
| Crop geometry/rendering | `lib/ticket_image_cropper.dart` |
| Camera/gallery and device identity | Dart services; Android MainActivity; iOS AppDelegate |
| Theme/assets/dependencies | `lib/theme/tm_tokens.dart`; `pubspec.yaml` |
| Test baseline | `test/widget_test.dart`; verification section below |

## Detailed reference index — read as needed

- [Project identity](#project-identity-and-scope), [complete file map](#file-map), [architecture/startup](#architecture-and-startup)
- [Screens and gestures](#screen-behavior-and-editing-gestures), [text keys](#text-persistence-contract)
- [Data and sync](#data-model-and-persistence), [images/native channels](#image-and-native-integrations)
- [Assets](#assets-and-reference-material), [platform/build setup](#build-configuration-and-platform-limits)
- [Verification baseline and commands](#verification-baseline-from-this-review)

## Project identity and scope

- Flutter application named `ticketmaster`, version `2.0.0+2`, with Ticketmaster-styled screens, editable ticket presentations, Firebase authentication, and per-user cloud/local state.
- Android and iOS have Firebase options and custom native integrations. Desktop and web folders exist, but Firebase startup explicitly rejects those platforms.
- The event feed and much ticket content are generated/sample content. No actual Ticketmaster event, booking, purchase, ticket-validation, or transfer API integration was found in application source.
- Barcode and map visuals are custom paintings. The barcode is a fixed pattern, not an encoded ticket credential.
- README is the canonical project guide. No Git repository was detected at the workspace root or its parents during review.

## File map

| File or directory | Responsibility |
| --- | --- |
| `lib/main.dart` | Imports, six part files, Flutter/Firebase/store initialization, app launch |
| `lib/app/app_core.dart` | MaterialApp, bootstrap, video splash/network gate, custom page routes |
| `lib/app/auth_flow.dart` | Google-only sign-in page, validation/error messages, login/splash routes |
| `lib/app/home_shell.dart` | Five-tab shell, Discover feed, ticket model/list/search/count/image actions, favorites/sell/account screens |
| `lib/app/tickets_flow.dart` | Ticket detail pager, barcode view, transfer UI, metadata/price/terms, ticket cards and painters |
| `lib/app/editable_text.dart` | Custom editable Text, edit dialog, static edit store and key compatibility |
| `lib/app/local_persistence.dart` | `_TicketmasterCloudStore`, Firebase reads/writes, device lock, sessions, JSON snapshots and merge logic |
| `lib/ticket_image_cropper.dart` | Image selection model, normalized crop geometry, drag/corner controls, preview/viewport painters |
| `lib/ticket_image_picker_service.dart` | Dart image-picker method-channel wrapper |
| `lib/device_identity_service.dart` | Native device identity/storage-directory wrapper and fallback |
| `lib/startup/connection_probe*.dart` | Interface, conditional factory, IO/web/stub connectivity probes |
| `lib/theme/tm_tokens.dart` | Colors, Metropolis typography, spacing/radii/durations, runtime asset paths |
| `lib/color_compat.dart` | Compatibility extension for `Color.withValues(alpha:)` using `withOpacity` |
| `lib/screens/screen_registry.dart` | Descriptive screen/reference-asset list; not the runtime router, some notes are stale |
| `lib/firebase_options.dart`, `firebase.json` | FlutterFire platform options/configuration |
| `android/app/src/main/kotlin/com/ticketmaster/mobile/android/MainActivity.kt` | Android gallery/camera and device identity channels |
| `ios/Runner/AppDelegate.swift` | iOS gallery/camera, resizing and device identity channels |
| `test/widget_test.dart` | One bottom-navigation rendering widget test |
| `setup_dev_env.ps1` | Broad Windows toolchain installer/configuration script |
| `assets/` | App images, navigation icons, fonts and splash video |
| `tools/` | Reference APK and extracted resources, not application source |
| `android/`, `ios/`, `macos/`, `windows/`, `linux/`, `web/` | Platform hosts and build scaffolding |

## Architecture and startup

`main.dart` imports the app dependencies and includes all six `lib/app/*.dart` files as parts of `package:ticketmaster/main.dart`. They share private names and imports. They are not independent libraries; moving a class to an ordinary imported file changes visibility and Text behavior.

State uses StatefulWidget/setState, a singleton cloud store, and a static editable-text map. There is no Provider, Riverpod, Bloc, or declarative routing package. Navigation uses Navigator and PageRouteBuilder fade/slide transitions.

Startup sequence:

1. Initialize Flutter bindings, enable edge-to-edge system UI, keep white status/navigation icons visible, and disable Android contrast frames so time, network, Wi-Fi and battery remain visible without an outline around the screen.
2. Await `Firebase.initializeApp(DefaultFirebaseOptions.currentPlatform)`.
3. Await `_TicketmasterCloudStore.initialize()` before `runApp`.
4. `TicketmasterBootstrap` checks current authentication against the `authorized_users` allowlist, then device access and a 14-day session expiry. It resolves to login or splash; revoked or expired users are signed out.
5. Successful login authenticates with Google (`google_sign_in` + `GoogleAuthProvider`), then verifies the email is in the `authorized_users` allowlist (fails closed), transactionally claims the device, loads state, persists profile state, and replaces login with splash.
6. Splash plays `assets/splash_screen.mp4` muted, with a five-second fallback timer, and waits for connectivity before fading to the home shell. Resume triggers another connection check.

IO connectivity polls DNS for `example.com` every three seconds with a two-second timeout. This is a DNS signal, not a Firebase reachability test. Web uses browser online/offline events; stub always returns true.

The root app disables system text scaling through MediaQuery and uses Metropolis with brand blue `#026CDF`.

## Screen behavior and editing gestures

- Home tabs: Home/Discover, Watchlist (`ForYouScreen`), My Tickets, Account. A Stack with animated opacity/slide and IgnorePointer keeps all four pages mounted, including inactive pages. The custom black bottom bar respects the phone bottom safe area; selected Watchlist uses a solid purple bookmark and My Tickets uses the exact stacked-ticket icon cropped from the reference screenshots.
- Discover renders the dark Spain reference layout: responsive location/search header, a horizontally paged three-row trending list, horizontal Top Picks and City Guides. The search pill is a real text field: tapping anywhere focuses it and opens the phone keyboard; while empty, `Search for` stays fixed and the final word alternates between `Venues` and `Events` every two seconds, with the new word sliding up from below while the old word exits upward. The visible photo regions come from `screenshot/IMG_0368.PNG` (828×1792) through `_ReferenceCropImage`; text, borders, spacing, favorites and navigation are live Flutter widgets. Location, section/card copy and artist metadata remain long-press editable. Location, View All and favorites are presentation elements.
- Watchlist matches `IMG_0370.PNG`, with working Events/Favourites segmented selection, responsive empty state and benefit rows. Its visible copy remains long-press editable; it does not yet persist actual watched events.
- Sell shows a legacy landing page and selling/sold/expired labels; actions are placeholders. It is retained in source but has no bottom-navigation entry.
- My Account matches `IMG_0374.PNG`/`IMG_0375.PNG`: profile header, editable section/row copy, local location/notification toggles and grouped menu rows. It shows the Firebase display name/email when available. Sign Out retains the prior behavior: clear the session/release the device lock, sign out, and remove prior navigation routes.
- My Events restores the same saved ticket entries, or creates one default Colorado Rockies vs. San Diego Padres card at Coors Field, dated Sep 14, 2026. Parsed dates split cards between working Upcoming/Past tabs; unknown date formats stay Upcoming. The reference default is Past on dates after Sep 14, 2026. An empty saved list is treated as absence of saved tickets.
- Double-tap or long-press Upcoming to set the number of event cards. The dialog accepts integers >= 1 and has no maximum.
- Tap Upcoming/Past to switch lists. Double-tap or long-press Past opens the existing ticket search on Past; double-tap or long-press Upcoming still opens the card-count dialog.
- Double-tap/long-press a ticket card to show camera/gallery image options. A single tap opens details.
- Double-tap/long-press the quantity badge to set the number of tickets within that card. Card count and per-card ticket quantity are separate values.
- Most text in the shared library is long-press editable. Native Material text is explicitly used where edit gestures would conflict with controls, including navigation labels, segmented controls, live Firebase email and dialogs.
- The V2 ticket UI follows `V2/Screenshot_20260918-201930.png` (list), `201357`/`201419` (expanded event), `201401`/`201422` (collapsed event), `201440` (Extras), the generated white barcode/information references, then `200612`/`200616` (selection), `200417` (recipient method), and `200425`/`200433`/`200454` (recipient forms). Existing ticket content is retained rather than replacing saved data with screenshot examples.
- My Tickets uses a charcoal header, purple event panels, 16:9 dynamic artwork, blue dividers and View Tickets footers. The date-derived next-event label is presentation only; Upcoming/Past filtering, count shortcuts, image options, quantity badge, search and editable text keys remain intact. Ticket-specific typography is scoped locally. Empty/search states remain readable on dark backgrounds.
- Ticket details has a collapsing event header, pinned Tickets/Extras tabs, per-ticket seat PageView and dots, metadata link, map and floating Transfer/Sell actions. The pinned scanner also opens View Ticket when the hero has scrolled away. Sell/Get Directions remain no-op buttons. Existing transfer landing content and its preview pager remain available before the selection sheet.
- View Ticket opens initially on the LAST ticket (`ticketCount - 1`), retains paging arrows and the animated blue line over the existing sample barcode, and uses a scrollable white ticket, purple artwork, wallet and metadata controls. Wallet remains a placeholder. Ticket information has scrollable Ticket Details/Event Information tabs. Seat defaults and existing metadata are preserved.
- Transfer selection/continue/back remain unchanged. The recipient-method sheet now opens a local manual form with name, email/mobile toggle, clear controls and optional note; fields are not persisted and sending remains disabled. Contacts remains a placeholder. Sheets scroll on short phones and expand immediately for the keyboard, with a reachable back footer. No tickets are actually sent.
- V2 reuses the existing Rockies asset for default art, with the old art widgets as its load-error fallback. Uploaded images retain their saved normalized crops. The map and barcode remain existing sample drawings, not exact copies of screenshot artwork. The quantity badge, entrance copy and other existing editable controls are retained even when absent from a reference. `_V2LegacyTextKey` preserves the original unkeyed storage identity for renamed tab/wallet labels.
- Detail metadata, order, price, terms, and map include static/sample values. Section defaults differ between views (402 vs GA) until edited.

## Text persistence contract

`main.dart` hides Flutter's Text and imports it as `material.Text`; the shared library declares its own stateful `Text`, including `Text.rich`.

- Custom Text wraps visible content in a long-press detector, opens a dialog, persists edits, and rebuilds the edited widget.
- Explicit widget keys use `widget.key.toString()` as their storage key. Unkeyed text uses `::$original`; identical unkeyed labels can share edits.
- `_EditableTextStore` supports both resolved keys and older `$key::$original` keys. Saving the original value removes the override.
- `_TicketListEntry.textKey(field)` returns `ticket-{id}-{field}`.
- `_TicketListEntry.ticketInstanceTextKey(index, field)` returns `ticket-{id}-instance-{index+1}-{field}`.
- A key detail to investigate before refactoring: ticket model getters query raw string keys, while custom Text serializes ValueKey with `toString()`. Those formats differ; do not assume model getters and edited widgets always resolve the same override.
- Editing rich text converts it to plain text when the value changes. Only the edited widget explicitly rebuilds; the store does not broadcast changes to all mounted widgets.

## Data model and persistence

`_TicketListEntry`: integer id, displayTitle, displayVenue, displayDateLabel, searchKeywords, ticketCount (default 1), optional TicketCardImageSelection. IDs are generated from list position starting at 1. The copyWith method supports image/count; null cannot clear an existing image.

Firebase project identifier is `ticketmaster-61fd5`; configuration values remain in their existing files. No backend rules, indexes, Cloud Functions, or emulator configuration were found in this workspace.

| Location | Contents |
| --- | --- |
| Firestore `ticketmaster_user_state/{uid}` | editedTexts map, sessionStartedAt, updatedAt, activeDeviceKey, activeDeviceLabel |
| Firestore `ticketmaster_user_state/{uid}/tickets/{id}` | Ticket fields, imagePath/image dimensions, normalized cropRect, updatedAt |
| Storage `ticketmaster_user_state/{uid}/tickets/ticket_{id}.bin` | Image bytes with application/octet-stream metadata |
| Native app storage `ticketmaster_state/{safeUid}.json` | editedTexts, sessionStartedAt, updatedAt, upcomingTickets with base64 image bytes and crop metadata |

Loading applies the local snapshot first, then merges cloud state. Timestamps choose the preferred values; text maps and ticket IDs are unioned. Preferred ticket metadata wins, with secondary image fallback. A remote empty state does not clear meaningful local data. The merged result is written locally but not automatically reconciled back to cloud by the load operation.

Saving text/tickets writes local state first, then queues cloud writes on `_pendingWrite`. Profile and ticket writes share that queue. Ticket persistence reads existing document IDs, uploads all current images, writes all current ticket docs, and deletes removed docs/images. Downloads are capped at 6 MiB; Android uploads have no equivalent source-level cap.

Many persistence exceptions are swallowed. Local/cloud writes are not an atomic transaction together, and there is no visible retry queue/status UI. Device claim is a Firestore transaction. Access checks allow access if the lookup throws; enforcement in deployed Firebase rules cannot be assessed here.

Potential consistency issues to consider for future persistence work:

- Union-based merging can restore deleted tickets from an older snapshot; no deletion tombstones exist.
- Snapshot timestamps are global, with local DateTime.now and remote server timestamps rather than per-field conflict resolution.
- Queued callbacks read mutable current store/auth state when executing; user transitions and rapid saves deserve focused tests.
- Local writes can overlap and are not written via an atomic temporary-file rename.
- Reused positional IDs may reuse old text overrides after shrinking and growing the list.
- Session expiry/device validation is checked during startup/login; there is no ongoing global auth/device watcher in the home shell.

These are source-review concerns, not reproduced runtime failures.

## Image and native integrations

Both Android and iOS implement:

- Channel `ticketmaster/ticket_image_picker`, method `pickTicketImage`, argument `source: gallery|camera`; returns bytes, null on cancel, or a platform error.
- Channel `ticketmaster/device_identity`, method `getDeviceIdentity`; returns deviceKey, deviceLabel and storageDirectoryPath.

Android uses ACTION_GET_CONTENT, runtime media/storage permissions, camera permission and ACTION_IMAGE_CAPTURE via FileProvider. Camera files live temporarily under cache `ticket_uploads/` and are deleted after consumption/cancel. Gallery/camera return original file bytes. Identity uses Android ID (fallback fingerprint/package), manufacturer/model, and filesDir.

iOS uses UIImagePickerController, Photos and AVFoundation permission checks, then a UIGraphicsImageRenderer/JPEG conversion (0.88 quality; target logical longest dimension 1600). Identity uses identifierForVendor (fallback device name), model/name and the Documents directory. Info.plist includes camera/photo explanations. Native renderer scale can affect final pixel dimensions.

Unsupported identity channels return the shared `fallback-device` key and empty storage path, disabling file snapshots. Web image picking throws UnsupportedError. Desktop custom channels were not found.

Cropping stores original selected bytes plus original dimensions and a rectangle normalized to 0..1; it does not create a cropped file. Users move or corner-resize an aspect-locked rectangle. The list chooses ratio `(screenWidth - 28)/180` clamped to 1.6..2.4; default crop ratio is 2.0. TicketCardImageViewport scales/translates the original image within ClipRect. Preserve normalized geometry during serialization changes.

## Assets and reference material

- Runtime asset groups: `assets/apk/images/` including legacy bottom/bottom_click, `assets/tm/`, `assets/tm_nav/`, `assets/tm_nav_norm/`, `screenshot/IMG_0368.PNG`, `screenshot/IMG_0372.PNG`, root images/video and five Metropolis OTF weights (100/400/500/600/700).
- Current navigation is a four-item Flutter widget using the transparent Ticketmaster `t` glyph plus Material outline icons. The old five-item bottom image sets remain bundled for legacy/reference screens but are not used by the home shell.
- `screenshot/IMG_0368.PNG` is the user-provided 828×1792 Discover reference. Keep its dimensions or update `_ReferenceCropImage` and the source rectangles together; responsive widgets crop only its photo regions at runtime. `IMG_0370.PNG`, `IMG_0372.PNG`, `IMG_0373.PNG`, `IMG_0374.PNG` and `IMG_0375.PNG` are visual references for Watchlist, Upcoming empty, Past card and Account scroll states.
- `tools/Ticketmaster_clean.apk`, extracted drawable resources, resource tables and metadata are reference artifacts; do not confuse the extracted manifest with the app's Android manifest.
- Binary assets were inventoried, not individually visually inspected or decompiled. Build outputs, package caches and historical logs were not exhaustively reviewed as source.

## Build configuration and platform limits

- pubspec Dart constraint: `>=3.5.4 <4.0.0`; lockfile Flutter constraint `>=3.24.0`.
- Direct dependencies: cloud_firestore ^6.0.2, firebase_auth ^6.0.2, firebase_core ^4.0.2, firebase_storage ^13.0.2, google_sign_in ^7.2.0, video_player ^2.9.2, cupertino_icons ^1.0.8. Dev: flutter_test, flutter_lints ^5.0.0, flutter_launcher_icons ^0.13.0.
- Android applicationId/namespace: `com.ticketmaster.mobile.android`; minSdk 23; Java/Kotlin JVM target 17; NDK 29.0.14206865; AGP 8.11.1; Kotlin plugin 2.2.20; Gradle 8.14; Google Services plugin 4.3.10. Compile/target SDK follow Flutter. Release and debug both sign with `android/app/ticketmaster-signing.jks` (alias `ticketmaster`, store/key password read from `android/key.properties`).
- Android checks the public GitHub repository's latest Release API on startup. A release tag in exact `vMAJOR.MINOR.PATCH+BUILD` form (for example `v2.0.1+3`) and at least one `.apk` Release asset show the dialog when BUILD exceeds the installed build. The GitHub Release description becomes What's New; including `[force-update]` anywhere in it removes Later/back dismissal and the marker itself is hidden. Update first requests Android's one-time unknown-app-source grant when needed, then downloads the APK into the app cache with progress and opens the Android package installer through FileProvider; Android still requires the user to confirm installation. Each APK must use the same signing key and an increased pubspec build number. The check fails open when offline/malformed and is not background push messaging. The releases repo must be public; never embed a private-repo token in the app.
- The login page keeps the existing background with a dark edge vignette that removes the light tint around the screen, a centered Ticketmaster logo at the top, a circular blue-and-white `t` mark between it and centered "Welcome Back", the only "Sign in with Google" action directly below the welcome text, and a small Moonx.dev copyright at the bottom. It uses `google_sign_in` (7.x `GoogleSignIn.instance.authenticate()`) plus Firebase `GoogleAuthProvider.credential(idToken:)`. Android needs the Google provider enabled in Firebase and the SHA-1/SHA-256 fingerprints registered. The web client id (the google-services.json `oauth_client` entry with `client_type: 3`) is passed explicitly as `GoogleSignIn.instance.initialize(serverClientId: ...)` in `main.dart`.
- Access control: an `authorized_users` Firestore collection (doc id = lowercase email, optional `active: false`) gates sign-in and launch. Sign-in fails closed; launch denies only a confirmed removal so a transient error does not lock users out. `firestore.rules` enforces the same check server-side; deploy with `firebase deploy --only firestore:rules`. Add/revoke users by creating/deleting the doc in the Firebase console → Firestore Database → `authorized_users`.
- Firebase CLI on this Windows machine must be invoked as `firebase.cmd` when PowerShell execution policy blocks `firebase.ps1`. `.firebaserc` pins commands to `ticketmaster-61fd5`.
- Android local.properties points at `C:\Android` and `C:\flutter`. Main manifest does not explicitly list INTERNET; debug/profile manifests do. Inspect the merged release manifest before concluding whether dependency manifests supply it.
- iOS bundle ID `com.example.ticketmaster`, Swift 5, Xcode project deployment target 13.0. Native Photos code uses APIs requiring newer availability; compatibility needs an actual iOS build review. No iOS build was performed on this Windows machine.
- macOS/Linux/Windows are mostly standard Flutter runners. Their presence does not imply supported Firebase startup. Web also has unconditional dart:io usage in the shared main library to resolve before porting.
- setup_dev_env.ps1 has base/android/flutter/vscode/verify phases and defaults to base. It targets C:\Dev, installs numerous tools, alters user environment/PATH, and can replace installation directories. It was read, not executed; it differs from the current C:\flutter/C:\Android paths.

## Verification baseline from this review

Installed command-line SDK: Flutter 3.44.8 stable, Dart 3.12.2, found at `C:\flutter\bin`. These are observed local versions, not a project pin.

- V2 validation on 2026-09-19: `flutter test --no-pub` passes all 9 tests. Firebase host calls are mocked; tests do not use live accounts or write user data. Coverage includes current bottom navigation, list/detail/barcode/information routes at 320×568, 360×640, 412×915, 430×932 and 640×360; hidden card-count/quantity/image gestures, text-edit dialog, search, transfer selection/back, manual email/mobile form, keyboard insets and 1.5× list text.
- Scoped `dart analyze lib/app/home_shell.dart lib/app/tickets_flow.dart test/my_tickets_test.dart test/widget_test.dart` reports no errors and the same five pre-existing unused Discover declarations. Full-project `flutter analyze --no-pub` also discovers unrelated temporary Dart files under `build/app/intermediates/sdk_dependency_data/tmp/` and reports errors there; do not treat those generated-file errors as V2 source errors.
- The first V2 pass compiled via hot reload and was visually checked on the connected Android phone; subsequent refinements were compiled and checked with widget tests and rendered snapshots. Native camera/gallery, live cloud sync, release APK and iOS builds were not revalidated. Persistence, IDs and normalized crop serialization were not changed.
- Existing packages were usable; no restoration, new dependency, SDK/native configuration or package-version changes were needed. Restore dependencies only if the current package setup actually requires it.
- iOS/macOS RunnerTests remain empty templates. UI tests do not establish end-to-end authentication, persistence or native-image-picker correctness.

Use `flutter devices` / `flutter run -d <device-id>` for mobile verification when needed. Do not interpret historical APK/build folders as proof that current source builds successfully.

## Where to start for common changes

| Requested work | Start here |
| --- | --- |
| Ticket layout, metadata, pager, barcode presentation, transfer UI | `lib/app/tickets_flow.dart` |
| Ticket creation/count/search, tab UI and Discover | `lib/app/home_shell.dart` |
| Edit gestures, label persistence or key migration | `lib/app/editable_text.dart` plus model getters in home_shell |
| Cloud sync, deletion, sessions or device locking | `lib/app/local_persistence.dart` |
| Login/logout or startup routing | auth_flow, app_core, account screen in home_shell |
| Crop rendering or geometry | `lib/ticket_image_cropper.dart` |
| Gallery/camera/permissions or stable identity | Dart service plus BOTH native mobile implementations |
| Palette, fonts and runtime image mapping | tm_tokens and pubspec |
| Additional platforms | Firebase options, dart:io separation, native channels and plugin availability |

Keep this guide current after meaningful changes. Preserve the distinction between verified behavior, source observations, and unresolved concerns.
