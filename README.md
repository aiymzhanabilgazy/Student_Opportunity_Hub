# Student Opportunity Hub

Native iOS Application (SwiftUI)

Astana IT University  
Native Mobile Development (iOS)  
Endterm + Final Capstone

---

## 📌 Description

Student Opportunity Hub is an offline-first job and opportunity discovery app built with SwiftUI.  
It integrates:

- External REST API (Arbeitnow Job Board API)
- Core Data local caching
- Firebase Realtime Database (comments feature)
- Firebase Authentication
- Pagination and debounced search
- Image loading via Kingfisher

The application is designed with MVVM + Repository architecture.

---

## 🏗 Architecture

UI (SwiftUI Views)  
→ ViewModels  
→ Repository Layer  
→ API / Core Data / Firebase  

See /docs/ARCHITECTURE.md

---

## 🔐 Authentication

- Firebase Authentication (Email/Password)
- Session persists after restart
- User-scoped comments (Firebase)

---

## 🌐 External API

Arbeitnow Job Board API  
Endpoint:
https://www.arbeitnow.com/api/job-board-api

Features implemented:
- Pagination
- Debounced search
- Error handling
- Retry strategy

---

## 💾 Offline Support

- Core Data local caching
- Cache shown when offline
- Sync strategy documented in report
- Stale data detection (24h rule)

---

## 🔄 Realtime Feature

- Firebase Realtime Database
- Comments per opportunity
- CRUD support
- Live UI updates

---

## 🖼 Images

- Loaded via Kingfisher
- Downsampling for performance
- Fallback avatars if logo unavailable

---

## 🚀 Release Build

- Version: 1.0.0
- Build: 1
- Release configuration enabled
- Debug logs disabled in Release

See /docs/RELEASE_NOTES.md

---

## 🧪 Testing

- 10+ unit tests
- Manual test checklist
- QA log with fixed issues

See /docs/QA_LOG.md

---

## 🔧 Setup Instructions

1. Clone repository
2. Open .xcworkspace
3. Add your own GoogleService-Info.plist
4. Select simulator or device
5. Run

---

## 🤖 AI Usage Disclosure

ChatGPT was used to:
- Generate architectural guidance
- Improve error handling
- Refactor retry strategy
- Improve validation logic

All generated code was reviewed, modified, and fully understood by the developer.

---

## 👤 Authors

Yerassyl Yerkin 
Aiymzhan Abilgazy
SE-2423
AITU – 2026
