<div align="center">
  <h1>🏦 Artha Bank</h1>
  <p><strong>Modern Digital Wallet & Personal Finance Management Application</strong></p>

  <p>
    <img src="https://img.shields.io/badge/Go-1.18+-00ADD8?style=for-the-badge&logo=go&logoColor=white" alt="Go" />
    <img src="https://img.shields.io/badge/Gin-Web%20Framework-008ECF?style=for-the-badge&logo=go&logoColor=white" alt="Gin" />
    <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
    <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
    <img src="https://img.shields.io/badge/SQLite-003B57?style=for-the-badge&logo=sqlite&logoColor=white" alt="SQLite" />
  </p>
</div>

---

**Artha Bank** is a full-stack digital wallet application built to simplify daily financial transactions, track spending habits, and help users achieve their financial goals. This monorepo houses both the **Go (Gin)** backend API and the **Flutter** mobile frontend.

## 📑 Table of Contents

- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
  - [Prerequisites](#prerequisites)
  - [Backend Setup](#backend-setup)
  - [Frontend Setup](#frontend-setup)
- [API Reference](#-api-reference)
- [Testing](#-testing)
- [Contributing](#-contributing)
- [License](#-license)

---

## ✨ Features

- **🔐 Secure Authentication & Session Management**: User registration, login, email OTP verification, password reset, transaction PIN management, and JWT-based sessions with revocation and expiration handling.
- **💳 Wallet & Payments**:
  - Top-up internal wallet balance.
  - Instant peer-to-peer transfers to other Artha Bank users.
  - Purchase mobile credit (*Pulsa*) and electricity tokens (*PLN*).
  - QRIS payment support.
- **📊 Financial Tracking & Reporting**:
  - Categorized income and expense analytics (weekly, monthly, yearly).
  - Filterable transaction history.
  - One-click **PDF export** for financial reports.
- **👤 User Experience**:
  - Profile management (update display name and profile picture).
  - Favorite accounts list for faster repeat transfers.

---

## 🛠️ Tech Stack

| Layer | Technology |
| :--- | :--- |
| **Backend** | Go, Gin Gonic, GORM |
| **Database** | SQLite (dev/test, easily swappable to PostgreSQL/MySQL) |
| **Security & Auth** | `golang-jwt/jwt`, `bcrypt`, `go-playground/validator` |
| **Services** | `net/smtp` (OTP Email), `jung-kurt/gofpdf` (PDF Reports) |
| **Frontend** | Flutter, Dart, `http`, `image_picker` |

---

## 📂 Project Structure

```text
Artha-Bank/
├── Artha_Backend/          # Go REST API
│   ├── controllers/        # HTTP handlers & business logic
│   ├── middlewares/        # JWT authentication & authorization
│   ├── models/             # GORM database models & DTOs
│   ├── repositories/       # Database access layer
│   ├── services/           # Email (SMTP) & background cleanup tasks
│   └── main.go             # Application entry point
│
└── Artha_Frontend/         # Flutter Mobile App
    └── lib/
        ├── auth/           # Login, register, OTP & PIN screens
        ├── dashboard/      # Home, wallet & profile screens
        ├── pages/          # Transactions, history & tracking UI
        └── services/       # API clients & utility services
