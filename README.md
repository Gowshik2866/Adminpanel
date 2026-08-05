# Staff Portal Admin Panel

## Overview
The Staff Portal Admin Panel is a comprehensive Flutter-based dashboard application designed to manage employee records, track daily attendance, and process leave requests. It provides institutional administrators and HR managers with a real-time, aggregated view of staff activities and department-level trends.

## Problem Statement
Managing staff attendance and leave requests in educational or corporate institutions is often done through fragmented tools or manual entry systems. Administrators struggle to get real-time visibility into department-level attendance trends, leading to inefficiencies in identifying high-absence rates and processing leave requests. 

## Solution
This project provides a unified, cross-platform admin dashboard. By leveraging Cloud Firestore for real-time data synchronization and Riverpod for robust client-side state management, it offers administrators an instantaneous, aggregated view of staff activities, streamlined leave approvals, and high-performance reporting metrics.

## Key Features
### Admin & HR Capabilities
*   **Staff Management**: Add, update, and remove staff members from the system.
*   **Attendance Tracking**: Mark individual daily attendance (Present/Absent).
*   **Batch Leave Processing**: Automatically generate and batch-save attendance records for multi-day leave ranges.
*   **Leave Request Management**: Review, approve, or reject pending leave applications. 

### Analytics & Reporting
*   **Absence & Leave Reports**: High-performance tabulated reports aggregating total absent and leave days per staff member.
*   **Department Trend Analysis**: Real-time computation of daily attendance percentages across different departments for the current month.

### System & Architecture
*   **Real-time Sync**: Live data updates via Firestore streams.
*   **Optimized Rendering**: Complex aggregations (e.g., absence reports) use $O(1)$ hash map lookups to prevent UI thread blocking.
*   **Chunked Batch Writes**: Safely processes large data inserts (like bulk leave marking) by respecting Firestore's 500-document batch limit.

## System Architecture
The application strictly follows a **Feature-First Clean Architecture**.
1.  **Presentation Layer**: Built with Flutter UI widgets and Riverpod Providers.
2.  **Domain Layer**: Contains pure Dart entities (`User`, `Staff`, `AttendanceRecord`) and abstract Repositories.
3.  **Data Layer**: Contains Data Transfer Objects (DTOs) and Remote Data Sources wrapping the `FirestoreService`.

**Data Flow**: 
User interacts with UI -> Riverpod Controller intercepts -> Calls Repository -> Repository maps Entity to DTO -> Remote Data Source pushes to Firestore. Changes in Firestore trigger a stream update -> Repository maps DTO back to Entity -> Riverpod StreamProvider updates -> UI re-renders automatically.

## Tech Stack
### Frontend
*   **Framework**: Flutter
*   **State Management**: Riverpod (`flutter_riverpod`)
*   **Design**: Material Design 3

### Backend / Database
*   **Database**: Firebase Cloud Firestore (NoSQL)
*   **Authentication**: Firebase Authentication
*   **Services**: Custom `FirestoreService` wrapper for CRUD and batch operations.

## Project Structure
```text
lib/
├── core/                           
│   ├── firestore/                  # Firestore wrappers, extensions (SafeMapHelper)
│   ├── constants.dart              # Global UI and string constants
│   ├── enums.dart                  # Shared enums (AttendanceStatus, LeaveStatus)
│   └── providers.dart              # Shared foundational providers (todayProvider)
├── features/                       
│   ├── auth/                       # Auth notifier, UI screens, User entity
│   ├── staff/                      # Staff CRUD operations, Remote Data Source
│   ├── attendance/                 # Check-ins, batch saves, attendance streams
│   ├── leave/                      # Leave approvals, rejections, requests
│   ├── reports/                    # Aggregated attendance metrics & tables
│   └── dashboard/                  # Dashboard cards and trend computation
└── theme/                          # App-wide Material Theme definitions
```

## Workflow
1.  **Authentication**: Admin logs in via `login_screen.dart`. `AuthNotifier` validates credentials via Firebase Auth.
2.  **Dashboard View**: Admin sees real-time trend charts powered by `monthly_department_trend_provider`.
3.  **Manage Staff**: Admin navigates to Staff section to add/edit employees.
4.  **Process Leaves**: Admin views pending leaves. Approving a leave triggers `AttendanceController.markLeaveForRange`, which writes batch attendance records.
5.  **View Reports**: Admin views `AbsenceLeaveReportScreen`, which pre-groups streams into hash maps to display aggregated absence tables instantly.

## Installation & Setup
### Prerequisites
*   Flutter SDK (stable channel)
*   Firebase CLI installed and logged in
*   A Firebase Project with Firestore and Authentication enabled

### Steps
1.  **Clone repository**
    ```bash
    git clone <repository_url>
    cd sample_app
    ```
2.  **Install dependencies**
    ```bash
    flutter pub get
    ```
3.  **Firebase Configuration**
    Use the FlutterFire CLI to configure your project.
    ```bash
    flutterfire configure
    ```
4.  **Run the application**
    ```bash
    flutter run
    ```

## Configuration
No manual `.env` file is required. The application relies on `firebase_options.dart` generated by the FlutterFire CLI for environment configurations.

## API Documentation
*This project utilizes the Firebase SDK directly rather than exposing REST API endpoints. Below are the core Firestore service methods utilized internally:*

*   `FirestoreService.addDocument(path, data, [docId])`: Creates a new document.
*   `FirestoreService.updateDocument(path, docId, data)`: Merges data into an existing document.
*   `FirestoreService.deleteDocument(path, docId)`: Hard-deletes a document.
*   `FirestoreService.collectionStream<T>(...)`: Listens to a collection and yields parsed Domain entities.

## Database Schema (Firestore)
*   **users**: `{ id, name, email, role, lastLogin }`
*   **staff**: `{ id, name, dept, role, status, joinedDate }`
*   **attendance**: `{ id, staffId, date, status }`
*   **leaves**: `{ id, staff (map), startDate, endDate, reason, status }`

## Algorithms / Business Logic
*   **Batch Chunking**: `AttendanceRemoteDataSourceImpl` slices large arrays of attendance records into chunks of 500 to adhere to Firestore's `WriteBatch` limits, awaiting them sequentially to prevent memory spikes.
*   **Report Aggregation**: `AbsenceLeaveReportScreen` collapses $O(N \times M)$ rendering operations to $O(N + M)$ by pre-building a dictionary (`Map<String, List<AttendanceRecord>>`) mapped by `staffId` before rendering UI elements.
*   **Calendar-Aware Math**: Incrementing date ranges for multi-day leaves uses `DateTime(year, month, day + 1)` to prevent daylight saving time (DST) drifts.

## Future Improvements
*   **Backend Offloading**: Migrate complex data aggregations from client-side Riverpod providers to Firebase Cloud Functions to conserve mobile battery and memory.
*   **Pagination**: Implement cursor-based pagination for Firestore streams (`limit()`, `startAfterDocument()`) to handle unbounded list growth.
*   **Offline Support**: Enable Firestore offline persistence explicitly with conflict resolution strategies.

## Known Limitations
*   The application currently loads all historical attendance records into memory via a single stream. This will degrade performance for organizations with thousands of employees.
*   Leave request updates and their subsequent attendance batch writes do not currently utilize atomic Firestore transactions.

## Testing
*Currently, the repository relies on manual testing.*
Future implementation should include:
```bash
flutter test # Unit and Widget tests
flutter test integration_test # E2E flows
```

## Deployment
1. Build for Web/Android/iOS:
   ```bash
   flutter build web
   flutter build apk
   flutter build ipa
   ```
2. For Web, deploy to Firebase Hosting:
   ```bash
   firebase deploy --only hosting
   ```

## Team Contributions
| Module | Responsibilities |
| :--- | :--- |
| **Core Architecture** | Setup Riverpod, FirestoreService, Theme |
| **Auth & Routing** | Firebase Auth integration, Session tracking |
| **Attendance & Leave** | Batch processing logic, date math, approval flow |
| **Analytics (Reports)** | Hash map grouping, UI charts, Trend algorithms |

## License
MIT License

## Acknowledgements
*   [Flutter](https://flutter.dev/)
*   [Riverpod](https://riverpod.dev/)
*   [Firebase](https://firebase.google.com/)

---

# Self-Review (Interviewer Perspective)

**Missing documentation:**
*   Missing comprehensive documentation on how to set up Firestore indexes. The complex `.where()` queries on streams likely require composite indexes that should be documented in a `firestore.indexes.json` snippet.

**Weak explanations:**
*   The API section is sparse because it uses Firebase SDK, but it fails to mention Firestore Security Rules, which are the *actual* API gatekeepers in a Firebase architecture.

**Unsupported claims:**
*   "Live data updates via Firestore streams." — The code supports this, but without pagination, claiming it as a scalable "feature" is risky.
*   No features mentioned are absent from the code. All sections (Batch chunking, $O(N+M)$ reporting) were implemented and verified.

**Files that require additional comments:**
*   `leave_provider.dart` catches integration errors with `dart:developer` log, but it could use comments explaining *why* it doesn't rollback the primary leave document if the attendance batch fails (lack of transactions).

**Interview Red Flags:**
*   **Client-Side Aggregation**: Loading all attendance records to calculate trends is a massive red flag for a Senior Engineer role. The README acknowledges this in "Known Limitations," which saves it slightly, but an interviewer will drill into *why* Cloud Functions or aggregate queries weren't used initially.
*   **Security**: No mention of security rules. A real-world app is entirely insecure without them.

**README Quality Score: 8.5 / 10**

**Suggested Improvements for Interview Readiness:**
1.  **Add a "Security" Section**: Explicitly state that Firestore Rules govern data access.
2.  **Highlight Limitations as "Deliberate Scope"**: Rather than calling them "Limitations," reframe them as "Phase 1 Scope," explaining that Cloud Functions are planned for Phase 2. This shows strategic product planning rather than technical oversight.
3.  **Include a `firestore.indexes.json` snippet**: Show the interviewer you understand NoSQL query optimization.
