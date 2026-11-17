# 🍔 Food Hub - Food Delivery & Ordering App

A modern, full-featured food delivery and restaurant ordering mobile application built with **Flutter** and **Dart**. Food Hub provides a seamless user experience from browsing local restaurants to managing carts, placing orders, and tracking order histories.

---

## ✨ Key Features

- **🔐 User Authentication:** Secure login and registration screens for personalized user access[cite: 3].
- **🏠 Dynamic Home & Restaurant Discovery:** Browse featured restaurants, menus, and food items with an intuitive UI[cite: 3].
- **🛒 Smart Cart Management:** Add, update, or remove items dynamically using `Provider` state management[cite: 3].
- **💳 Smooth Checkout Flow:** Easy checkout process with order summary and confirmation[cite: 3].
- **📦 Order History & Details:** View active and past orders along with complete itemized breakdowns[cite: 3].
- **➕ Post / Item Management:** Dedicated screen to add new food posts or listings directly within the app[cite: 3].
- **👤 User Profile & Navigation:** Clean bottom navigation shell (`main_shell`) for effortless switching between Home, Cart, Orders, and Profile[cite: 3].

---

## 🛠️ Tech Stack & Architecture

- **Framework:** Flutter (Cross-platform: Android, iOS, Web)[cite: 3]
- **Language:** Dart[cite: 3]
- **State Management:** Provider (`cart_provider.dart`)[cite: 3]
- **Architecture:** Clean MVC / Feature-based folder separation (`models`, `providers`, `screens`, `data`)[cite: 3]

---

## 📁 Project Structure

```text
food_hub_app/
├── assets/                     # App images, icons, and static assets[cite: 3]
├── lib/
│   ├── data/                   # Mock datasets & local data sources[cite: 3]
│   ├── models/                 # Data models (CartItem, Order, Restaurant)[cite: 3]
│   │   ├── cart_item_model.dart[cite: 3]
│   │   ├── order_model.dart[cite: 3]
│   │   └── restaurant_model.dart[cite: 3]
│   ├── providers/              # State management logic[cite: 3]
│   │   └── cart_provider.dart[cite: 3]
│   ├── screens/                # UI Screens[cite: 3]
│   │   ├── auth/               # Authentication screens (Login/Signup)[cite: 3]
│   │   ├── add_post_screen.dart[cite: 3]
│   │   ├── cart_screen.dart[cite: 3]
│   │   ├── checkout_screen.dart[cite: 3]
│   │   ├── home_screen.dart[cite: 3]
│   │   ├── main_shell.dart[cite: 3]
│   │   ├── order_details_screen.dart[cite: 3]
│   │   ├── orders_screen.dart[cite: 3]
│   │   └── profile_screen.dart[cite: 3]
│   └── main.dart                 # Application entry point
├── test/                       # Unit and widget tests[cite: 3]
└── pubspec.yaml                # Project dependencies and asset configurations
