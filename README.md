# Mobile Grammar for iPhone

Native SwiftUI version of [Mobile Grammar](https://github.com/white-collar/mobile-grammar-web):
130 lessons of English grammar with explanations in Ukrainian. Works fully offline.

## Features

- **Lessons**: all 130 units with search by title; lessons are shown as in the web app
  (Ukrainian explanations, English examples)
- **Categories**: lessons by level (A1–Higher) and by topic, with a "Go to" menu
- **Your groups**: create, edit and remove your own lists of lessons (stored on the device)
- **Reminders**: a notification to study a lesson or group at a chosen time
- **About** page
- Interface in English and Ukrainian: follows the iPhone's language, or
  Settings → Mobile Grammar → Language. Text size follows the iPhone's text size setting.

Requires iOS 17.

## Build

The Xcode project is generated from `project.yml` with [XcodeGen](https://github.com/yonaskolb/XcodeGen):

```sh
brew install xcodegen
xcodegen generate
open MobileGrammar.xcodeproj
```

To run on your own iPhone, choose your team under Signing & Capabilities in Xcode.

## Tests

Unit tests (content, search, groups, reminders) and UI tests run in Xcode (⌘U) or:

```sh
xcodebuild test -project MobileGrammar.xcodeproj -scheme MobileGrammar \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

GitHub Actions runs them on every push (`.github/workflows/ci.yml`).

## Content

`MobileGrammar/Resources/Content` is copied from the web app, so both show the same lessons:

```sh
tools/sync_content.sh ../mobile-grammar-web
```

Lessons and translations are edited in the web app's repository (see its README), then synced here.

## License

The code is MIT-licensed, see [LICENSE](LICENSE). The lessons are based on materials of a Cambridge textbook
(see the About page); the MIT license covers the code only, not those materials.
