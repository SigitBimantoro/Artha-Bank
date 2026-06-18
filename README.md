````markdown
# Artha Bank - Digital Wallet Application

Artha Bank is a modern digital wallet application designed to simplify daily financial transactions, help users manage their expenses, and achieve their financial goals. This repository contains both the backend (Go) and frontend (Flutter) components of the application.

## Table of Contents

- Features
- Technologies Used
- Project Structure
- Getting Started
  - Prerequisites
  - Backend Setup
  - Frontend Setup
- API Endpoints (Examples)
- Testing
- Contributing
- License

## Features

Artha Bank offers a comprehensive set of features for personal finance management:

- **User Authentication**: Secure registration, login, OTP verification, password reset, and PIN management.
- **Wallet Management**: Top-up internal balance.
- **Transactions**:
  - Internal transfers to other Artha Bank users.
  - Purchase mobile credit (pulsa).
  - Purchase electricity tokens (PLN).
  - QRIS payments.
- **Transaction History**: View detailed transaction history, filterable by various criteria.
- **Financial Tracking**: Graphical representation and categorization of income and expenses (weekly, monthly, yearly).
- **PDF Export**: Export financial tracking reports to PDF.
- **Profile Management**: Update user profile information, including name and profile picture.
- **Favorite Accounts**: Manage a list of favorite recipient accounts for quick transfers.
- **Session Management**: Secure JWT-based authentication with session revocation and expiration handling.

## Technologies Used

### Backend (Go)

- **Framework**: Gin Gonic (Web Framework)
- **ORM**: GORM (Database ORM)
- **Database**: SQLite (for development/testing, easily swappable with PostgreSQL/MySQL)
- **Authentication**: golang-jwt/jwt (JWT implementation), golang.org/x/crypto/bcrypt (Password Hashing)
- **Validation**: go-playground/validator
- **Email Service**: `net/smtp` (for sending OTP emails)
- **PDF Generation**: jung-kurt/gofpdf
- **Utilities**: `math/rand`, `time`, `strings`, `regexp`

### Frontend (Flutter)

- **Framework**: Flutter SDK (UI Toolkit)
- **Language**: Dart
- **State Management**: (Implicit, likely Provider/Bloc/Riverpod or simple `setState`)
- **HTTP Client**: (Implicit, likely `http` package)
- **Image Handling**: image_picker

## Project Structure

The repository is divided into two main parts:

- `Artha_Backend/`: Contains the Go backend application.
  - `controllers/`: Handles HTTP requests and business logic.
  - `models/`: Defines database models and data structures.
  - `middlewares/`: Custom Gin middleware for authentication and authorization.
  - `repositories/`: Data access layer for interacting with the database.
  - `services/`: External service integrations (e.g., email, cleanup tasks).
  - `main.go`: Entry point of the backend application.
- `Artha_Frontend/`: Contains the Flutter mobile application.
  - `lib/`: Source code for the Flutter app.
    - `auth/`: Authentication-related pages and logic.
    - `dashboard/`: Main application screens (e.g., profile, home).
    - `pages/`: General UI pages.
    - `services/`: API integration and other utility services.

## Getting Started

Follow these instructions to set up and run the Artha Bank application on your local machine.

### Prerequisites

- Git: For cloning the repository.
- Go: Version 1.18 or higher.
- Flutter SDK: Latest stable version.
- A code editor (e.g., VS Code).
- A web browser for testing backend APIs (e.g., Postman, Insomnia, or curl).
- An Android/iOS emulator or a physical device for running the Flutter app.

### Backend Setup

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/your-username/Artha-Bank.git
    cd Artha-Bank/Artha_Backend
    ```

2.  **Install Go dependencies:**

    ```bash
    go mod tidy
    ```

3.  **Configure Environment Variables:**
    The application uses environment variables for sensitive information like JWT keys and email service credentials.
    You might need to create a `.env` file or set these directly in your environment.
    - `JWT_SECRET_KEY`: A strong, random string for JWT signing (e.g., `artha_secret_key_2026`).
    - `SMTP_HOST`, `SMTP_PORT`, `SENDER_EMAIL`, `SENDER_PASS`: For the email service (e.g., Gmail SMTP details).
      - For Gmail, you'll need to generate an App Password if you have 2-Factor Authentication enabled.

    _Example `services/email_service.go` configuration:_

    ```go
    const (
        smtpHost    = "smtp.gmail.com"
        smtpPort    = "587"
        senderEmail = "your_email@gmail.com" // Replace with your Gmail
        senderPass  = "your_16_digit_app_password" // Replace with your generated App Password
    )
    ```

4.  **Run the backend application:**
    ```bash
    go run main.go
    ```
    The backend server should start, typically on `http://localhost:8080`.

### Frontend Setup

1.  **Navigate to the frontend directory:**

    ```bash
    cd ../Artha_Frontend
    ```

2.  **Install Flutter dependencies:**

    ```bash
    flutter pub get
    ```

3.  **Run the Flutter application:**
    Ensure you have an emulator running or a physical device connected.
    ```bash
    flutter run
    ```

## API Endpoints (Examples)

Here are some example API endpoints provided by the backend:

- `POST /register`: User registration.
- `POST /login`: User login.
- `POST /verify-otp`: Verify user OTP.
- `POST /topup`: Top up wallet balance.
- `POST /transfer`: Transfer money to another user.
- `GET /profile`: Get user profile details.
- `GET /history`: Get transaction history.
- `GET /tracking`: Get financial tracking data.
- `GET /tracking/pdf`: Export financial tracking data as PDF.

## Testing

The backend includes unit and integration tests. To run them:

```bash
cd Artha_Backend
go test ./...
```
````

## Contributing

Contributions are welcome! Please feel free to fork the repository, create a new branch, and submit a pull request with your improvements.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

```

```

```

```
