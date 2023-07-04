<p align="center">
  <span>A simple way to get the user location in the background.</span>
</p>

<p align="center">
  <a href="https://github.com/invertase/melos#readme-badge"><img src="https://img.shields.io/badge/maintained%20with-melos-f700ff.svg?style=flat-square" alt="Melos" /></a>
</p>

### About Flutter Back Location

This library aims at providing you a simple way to get the user location in the background

It currently supports Android, and iOS.

## Features

- 👨‍💻️ Easy to use
- 🔋 Highly configurable so you get the best performance / battery ratio for your use case
- 🔍 Supports both with and without Google Play Services for Android phones without them
- 🏃‍♂️ Supports background location updates

## How to use?

```dart
final location = await getLocation();
print("Location: ${location.latitude}, ${location.longitude}");
```
