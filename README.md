# Campus Buddy 📚  
**Student Utility Management — iOS App built with SwiftUI & SQLite**

Campus Buddy is a full-stack student utility iOS application designed for colleges and universities.  
Built using **SwiftUI** for the UI layer and **SQLite** for local data persistence, the app provides a clean separation between **Admin** and **Student** roles while ensuring secure, user-specific data storage.

The goal of this project is to demonstrate a **real-world DBMS + mobile application workflow** with authentication, role-based access, CRUD operations, and soft-delete recovery mechanisms.

---

## 📌 About the Project

Campus Buddy brings essential campus utilities into one unified mobile application.

### 👤 Admin & Student Roles
- **Admin**
  - Register and manage student accounts
  - Manage global notes, tasks, and schedules
  - View and control all student data
- **Student**
  - Access only their own profile and data
  - View admin-posted shared content (read-only)

### 🗂️ User-Specific Local Storage
- Each student has an **individual SQLite database**
- Data is isolated per user to prevent leakage
- Admin has elevated access for management

### 📝 Notes, Tasks & Class Schedule
- Full CRUD operations
- Per-user ownership
- Soft delete support using Trash system
- Timestamped records

### 🧮 Attendance Management
- Subject-wise attendance tracking
- Present / Absent marking
- Color-coded UI:
  - 🟢 Green → Present
  - 🔴 Red → Absent

### ♻️ Trash & Restore System
- Soft deletion using `isDeleted` flags
- Deleted items moved to Trash table
- Restore or permanently delete items

⭐ This project showcases **SwiftUI architecture**, **SQLite integration**, and **real-world permission handling** between admin and students.

---

## ✨ Features

### 🔐 Authentication
- Separate login for Admin and Students
- Session persistence
- Restore soft-deleted accounts

### 🎓 Student Management (Admin)
- Add / Edit / Delete student profiles
- Per-student SQLite database files
- Soft delete with Trash recovery

### 🗒️ Notes / Tasks / Schedule
- Create and manage personal notes and tasks
- Admin-posted entries visible to all students (read-only)
- Soft delete and restore
- User-specific data isolation

### 📊 Attendance Module
- Add subjects per student
- Mark attendance per subject
- Dynamic color-coded UI

### 🎨 UI & UX Highlights
- SwiftUI navigation & bindings
- Adaptive layout (iPhone & iPad)
- MVVM-oriented structure

---

## 🛠️ Installation & Setup (Development Flow)

This section takes you from **clone → running app in Xcode**.

### ✅ Requirements
- macOS **12+** (Ventura recommended)
- **Xcode 14+**
- iOS Simulator **15+** or physical iPhone

---

### 🚀 Step-by-Step Setup

#### 1️⃣ Clone the Repository
```bash
git clone https://github.com/chethan143chiru/Campus-Buddy.git
cd Campus-Buddy
