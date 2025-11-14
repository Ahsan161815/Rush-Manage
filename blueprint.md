# Project Management App

## Overview

A Flutter application for project management. The current focus is on building out the user interface and visual design for the authentication flow (Welcome, Login, Registration, Forgot Password).

## Features Implemented (UI)

- **Welcome Screen:**
    - Gradient background.
    - App logo and a welcoming illustration (using placeholder SVGs).
    - "Create New Account" and "Login Now" buttons.
- **Login Screen:**
    - "Login Now" title and subtitle.
    - Email and Password text fields with custom icons (using `CustomTextField` widget).
    - "Forgot Password?" link that navigates to the forgot password flow.
    - "Log in" button.
    - Social login buttons for Google and Apple.
    - Link to navigate to the Registration screen.
- **Registration Screen:**
    - "Create Your Account" title and subtitle.
    - Name, Email, and Password text fields (using `CustomTextField` widget).
    - "Save & Next" button.
    - Social login buttons for Google and Apple.
    - Link to navigate to the Login screen.
- **Forgot Password Flow:**
    - **Forgot Password Screen:** Prompts the user to enter their email address.
    - **Verify Email Screen:**
        - Prompts the user to enter a 6-digit OTP using a `PinCodeTextField`.
        - Includes a "Resend Code" option with a countdown timer.
    - **Reset New Password Screen:**
        - Displays the user's email in a read-only field.
        - Provides fields for "New Password" and "Confirm Password".
- **Custom Widgets:**
    - `CustomTextField`: A reusable text field with icon and password visibility toggle.
- **Theming & Styling:**
    - Centralized color and text styles in `app_theme.dart`.
    - Custom fonts and SVGs integrated.
- **Routing:**
    - `go_router` setup for navigation between all authentication screens.

## Current Plan

- The authentication UI is complete.
- Awaiting user input on the next screen or component to design.
