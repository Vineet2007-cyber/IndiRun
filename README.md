# 🇮🇳 IndiRun

**A free, lightweight running tracker built for runners in India.**

IndiRun is an Android-first running app designed around one simple idea:

> **Reliable run tracking should be accessible to everyone.**

IndiRun focuses on accurate GPS tracking, a clean running experience, offline-first reliability, run history, and polished shareable run visuals — with a product experience designed for budget and mid-range Android phones.

The project is initially focused on runners in **tier 2 and tier 3 Indian cities**, with English, Hindi, and Gujarati planned as the launch languages.

---

## ✨ Why IndiRun?

Many running apps offer powerful features, but important functionality can be locked behind subscriptions or may not be optimized for the devices, connectivity, and local communities common in India.

IndiRun takes a different approach:

* 🏃 **Core run tracking is free**
* 📍 **Reliable GPS tracking**
* 📱 **Designed for budget Android phones**
* 🔋 **Battery-conscious tracking**
* 📴 **Offline-first run recording**
* 🗺️ **Route and GPS visualization**
* ⏱️ **Distance, pace, duration and splits**
* 🔊 **Optional voice cues**
* 📊 **Run history and detailed statistics**
* 🎨 **Polished shareable run cards**
* 🌐 **English, Hindi and Gujarati**
* 🔐 **Privacy-focused by design**
* 🤝 **Built around local running communities**

The finished run is treated as an important product surface — not just a data screen. IndiRun's V1 includes four share formats designed for everyday posts, route-focused sharing, statistics, and vertical social content.

---

## 🚀 V1

The first version of IndiRun focuses on the essential running loop:

**Start → Track → Finish → Review → Share → History**

### Authentication & Profile

* Google sign-in
* IndiRun username and password
* Custom username selection
* Profile
* Session persistence
* Account deletion

New users can authenticate with Google and then choose their own IndiRun username and password. The Google account name is not used as the public IndiRun identity.

### Run Tracking

* Start / pause / resume / finish
* GPS route recording
* Distance
* Duration
* Moving time
* Current pace
* Average pace
* Per-kilometre splits
* Optional voice cues
* Background tracking
* Screen-locked tracking
* GPS readiness states
* Recovery from interrupted runs

The tracking engine is designed to filter inaccurate GPS samples and persist run data locally so a network or server failure cannot destroy an active run.

### Run History

* Completed runs
* Run detail
* Route
* Distance
* Duration
* Pace
* Splits
* Offline history
* Delete runs
* Sync status

### Shareable Run Visuals

IndiRun V1 includes four share formats:

1. **Classic Summary**
2. **Route Focus**
3. **Stats Focus**
4. **Story / Social**

The renderer uses deterministic Flutter layouts so the same run produces consistent visuals across devices.

Share cards support privacy controls for hiding the beginning and end of a route and are designed for platforms such as WhatsApp and Instagram.

---

## 🛠️ Tech Stack

| Layer              | Technology                  |
| ------------------ | --------------------------- |
| Framework          | Flutter                     |
| Language           | Dart                        |
| State Management   | Riverpod                    |
| Navigation         | go_router                   |
| Local Database     | Drift / SQLite              |
| Backend            | Supabase                    |
| Database           | PostgreSQL                  |
| Authentication     | Supabase Auth               |
| Location           | Geolocator                  |
| Android Tracking   | Android Foreground Service  |
| Maps               | Provider-agnostic interface |
| Sharing            | share_plus                  |
| Voice              | Text-to-speech              |
| Crash Reporting    | Firebase Crashlytics        |
| Analytics          | Firebase Analytics          |
| Push Notifications | Firebase Cloud Messaging    |
| Localization       | Flutter intl / ARB          |
| CI/CD              | GitHub Actions              |

The architecture intentionally keeps Android-specific tracking behind interfaces so the product can evolve toward iOS without rewriting the core running logic.

---

## 🏗️ Architecture

IndiRun follows a **feature-first architecture**.

```text
lib/
├── core/
│   ├── theme/
│   ├── routing/
│   ├── errors/
│   ├── config/
│   ├── localization/
│   └── utilities/
│
├── features/
│   ├── auth/
│   ├── home/
│   ├── run/
│   ├── history/
│   ├── share/
│   └── profile/
│
└── data/
    ├── local/
    ├── remote/
    ├── repositories/
    └── dto/
```

The intended dependency direction is:

```text
UI
 ↓
Application / State
 ↓
Domain / Repository Interfaces
 ↓
Data Sources
```

Business logic such as tracking, pace calculation, splits and synchronization is kept in pure Dart wherever possible so it can be unit tested without a physical device.

---

## 📍 Local-First Tracking

Run recording does **not depend on an internet connection**.

During a run:

```text
GPS
 ↓
Location Filter
 ↓
Tracking Engine
 ↓
Drift / SQLite
 ↓
Run Completed
 ↓
Sync Queue
 ↓
Supabase
```

The local database is the source of truth during and after a run. The backend acts as the synchronized copy.

This means temporary network loss should not interrupt tracking or cause a run to be lost.

---

## 🔐 Privacy

IndiRun is designed with privacy as a core product principle.

The V1 design includes:

* Minimal data collection
* No sale of location data
* Route privacy controls
* Account deletion
* Run deletion
* Local-first run storage
* Row Level Security on backend tables
* No privileged backend keys inside the application
* Analytics without coordinates or usernames

Privacy-sensitive functionality is particularly important because location data is central to a running application.

---

## 🌐 Localization

The initial localization target is:

* 🇬🇧 English
* 🇮🇳 Hindi
* 🇮🇳 Gujarati

Localization is implemented using Flutter's localization system and bundled fonts so multilingual text can render consistently inside the application and generated share cards.

---

## 🎨 Design System

IndiRun's UI is designed around:

* High contrast
* Large touch targets
* Simple running controls
* Minimal elevation
* Light and dark themes
* Poppins for prominent metrics
* Inter for interface text
* 4dp spacing grid
* Accessible iconography
* Sunlight-readable active-run screens

The active-run experience intentionally minimizes controls so runners can operate the app while moving.

---

## 🧪 Testing

Testing is a major part of the V1 development strategy because **tracking reliability is more important than feature quantity**.

### Automated testing

* Unit tests
* Distance calculations
* Pace calculations
* Split calculations
* GPS filtering
* State transitions
* Auto/sync logic where applicable
* Repository tests
* Offline and retry scenarios
* Widget tests
* Share-card golden tests
* Integration tests with simulated location data

### Field testing

IndiRun is intended to be tested on:

* Budget Android phones
* Mid-range Android phones
* Multiple manufacturers
* Android 14+
* Small screens
* Open-sky routes
* Dense urban environments
* Screen-locked runs
* Network loss
* GPS disabled
* Permission changes
* Forced app termination
* Phone restart
* Long-duration runs

Measured reference routes such as stadium tracks and surveyed loops are used to validate distance accuracy.

---

## 🗺️ Maps

The map layer is intentionally provider-agnostic.

The architecture is designed so the map provider can be changed without rewriting the run-tracking engine.

The project evaluates map solutions based on:

* Cost
* Offline behavior
* Data usage
* Performance on budget phones
* Rendering quality

Share cards use vector-rendered routes rather than requiring map tiles, helping keep generated visuals deterministic and inexpensive.

---

## 📊 V1 Scope

### Included

* Authentication
* Profile
* GPS run tracking
* Distance
* Duration
* Pace
* Splits
* Pause / resume / finish
* Voice cues
* Run recovery
* Run history
* Run details
* Offline access
* Cloud synchronization
* Four share formats
* Privacy controls
* English / Hindi / Gujarati
* Light / dark themes
* Account and run deletion

### Not included in V1

IndiRun is intentionally keeping the first release focused.

The following are planned for future versions:

* Club pages
* Club leaderboards
* Group-run tagging
* Club-branded share cards
* Personal records
* Social feed
* Followers / following
* Challenges
* Training plans
* Wearable integrations
* Payments and subscriptions
* Comments and live interactions

These are part of the longer-term product direction rather than the initial V1 release.

---

## 🛣️ Roadmap

### V1 — Core Running Experience

**Start → Track → Finish → Share → History**

### V1.5 — Community

* Club pages
* Club leaderboard
* Group runs
* Club-branded share cards
* Personal records
* Additional regional languages

### Future

* Richer run analysis
* Route discovery
* Training plans
* Wearable integrations
* iOS
* Additional community features

The post-V1 direction is intentionally built on top of the core tracking experience rather than expanding the first release prematurely.

---

## 🤝 Community-First Approach

IndiRun is being designed around India's local running communities.

The initial pilot strategy centers on **endurance.amd in Ahmedabad**, with the goal of testing real runs on real devices and collecting direct feedback from runners.

The longer-term rollout is planned from:

**Ahmedabad → Gujarat → Other Tier 2/3 Indian Cities**

Local running clubs, WhatsApp groups, events, colleges and shareable run cards are expected to play an important role in growth.

---

## 📈 Development

The V1 software build is planned around milestones from foundation through closed beta and release:

```text
M0  Foundation
 ↓
M1  Authentication & Profile
 ↓
M2  GPS Foundation
 ↓
M3  Core Run
 ↓
M4  Persistence & Sync
 ↓
M5  Run Summary & Detail
 ↓
M6  Share System
 ↓
M7  Stability
 ↓
M8  Closed Beta
 ↓
M9  V1 Release
```

The current planning estimate is approximately **21–28 weeks** for a solo developer working around 15–20 hours per week, with background tracking reliability and share-card quality identified as major uncertainties.

---

## 📂 Project Documentation

The repository is supported by four main product documents:

* **Product Requirements Document** — product scope and V1 requirements
* **Software Build Plan** — architecture, technology, tracking engine, testing and release
* **Business Plan** — positioning, business model and go-to-market
* **UI Screen Specification & Database Design** — interface specifications and database structure

These documents should be treated as the source of truth for their respective areas.

---

## 🔒 Project Status

**Status: V1 Development**

IndiRun is currently being developed as an **Android-first Flutter MVP**.

The first priority is not building the largest number of features.

The priority is:

> **Build a running tracker people can trust.**

---

## 📜 License

License information will be added before public release.

---

## 🇮🇳 Built for runners in India

**IndiRun**

Run. Track. Share. Repeat.
