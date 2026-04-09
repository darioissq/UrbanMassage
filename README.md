# UrbanMap

An iOS app that tracks the device's location and periodically uploads it to a remote API. Built as a technical test for an Urban Massage iOS Engineer role.

## Brief

> Implement an app that contains location tracking. The only UI necessary will be a single view, containing the current location, authorisation status, and the last upload time. The app should upload the location to a remote API via HTTP. Locations should be uploaded at 10–15 minute intervals.

## Features

- **Background location tracking** — uses `CLLocationManager` with `Always` authorization and `allowsBackgroundLocationUpdates = true` to track position even when the app is not in the foreground
- **Scheduled uploads** — posts coordinates to a remote endpoint every 15 minutes using a smart timer that accounts for elapsed time since the last upload
- **Offline retry** — automatically retries failed upload requests
- **Persistent last-upload timestamp** — stores the last successful upload date in `UserDefaults` and restores it on relaunch
- **Single-screen UI** — displays the live map, current authorization status, and the last upload timestamp

## Architecture

The app follows a lightweight MVC structure:

```
UrbanMap/
├── Application/
│   └── AppDelegate.swift
├── Controller/
│   └── MapViewController.swift      # Main screen: map, scheduler, networking
├── Networking/
│   ├── APIRequester.swift           # Location POST request
│   └── Networking.swift             # Alamofire session wrapper
├── Configuration/
│   └── Constants.swift              # Base URL, endpoint, timeouts, error strings
└── Shared/
    ├── PermissionManager.swift      # CLLocationManager authorization helpers
    ├── CLLocationCoordinate2D+Extension.swift
    ├── Date+Extension.swift
    └── String+Extension.swift       # Localization helper
```

## How the scheduler works

1. On first launch (no prior upload), the app waits for the first valid location fix and uploads immediately.
2. After a successful upload the timestamp is saved and a `Timer` is set to fire in `900 - (minutesSinceLastUpload × 60)` seconds — i.e., exactly when 15 minutes have elapsed.
3. When the app returns to the foreground the scheduler is reset using the stored timestamp, so the interval is always measured from the last real upload rather than from app-launch.

## Tech Stack

| Layer | Technology |
|---|---|
| Language | Swift 4 |
| Minimum deployment | iOS 11.0 |
| Location | CoreLocation |
| Maps | MapKit |
| HTTP | Alamofire 4 (via CocoaPods) |

## Requirements

- Xcode 9+
- CocoaPods

## Setup

```bash
cd UrbanMap
pod install
open UrbanMap.xcworkspace
```

The app targets a [RequestBin](https://requestbin.com/) endpoint configured in `Constants.swift`. To use your own endpoint, update `Constants.App.BaseURL` and `Constants.APIEndPoint.SendLocation`.

## Background tracking note

iOS restricts background execution heavily. This app requests `Always` location authorization and enables `allowsBackgroundLocationUpdates`, which is the most reliable way to receive periodic location updates while backgrounded. The timer is re-scheduled each time the app enters the foreground to compensate for any drift introduced by system suspension.

## Author

Dario Langella — July 2018
