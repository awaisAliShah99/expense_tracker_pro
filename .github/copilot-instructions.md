# Expense Tracker Pro

## Stack
Flutter, provider (state), sqflite (storage), fl_chart (charts), pdf + printing (export)

## Architecture
- lib/models: sirf data classes, koi UI ya DB code nahi
- lib/db: sirf DatabaseHelper, SQL yahin hoga
- lib/providers: state aur business logic, DB isi se call hoga
- lib/screens: pages, logic nahi, provider se data lega
- lib/widgets: chhote reusable UI hisse

## Rules
- Screen se seedha DB call kabhi nahi, hamesha provider ke through
- amount double, type enum (income/expense)
- Model ka naam TransactionModel (Transaction sqflite se takrata hai)
- Ek task mein sirf wohi files badlo jo zaroori hon
- Bina poochay naya package mat lagao
- Har kaam ke baad flutter analyze saaf ho


## Design
- Material 3, colors from ColorScheme.fromSeed (teal/green seed), light and dark mode both supported
- Define the theme once in lib/theme/app_theme.dart, no hardcoded colors in screens
- Rounded cards (radius 16), consistent 16px padding, income green and expense red from the theme
- Every list screen has an empty state (icon + short text)
- Category icons for each category