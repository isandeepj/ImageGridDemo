# Image Grid Demo

This application is designed to load and display images in a scrollable grid. It leverages asynchronous image loading without relying on third-party image loading libraries.

## Key Features
- **Image Grid:** Display a 3-column square image grid where images are center-cropped for uniformity.
- **Asynchronous Image Loading:** Implement efficient asynchronous image loading to ensure smooth user experience.
- **Display:** Users can seamlessly scroll through a collection of at least 100 images.
- **Caching Mechanism:** Utilize a caching mechanism to store images fetched from the API, optimizing retrieval by maintaining both memory and disk caches.
- **Error Handling:** Gracefully handle network errors and image loading failures by providing informative error messages or placeholders for unsuccessful image loads.

## Requirements
- iOS 13.0 or later
- Xcode 15.3 or later
- Swift 5.3 or later

## Installation

1. Clone the repository:
```bash
 git clone https://github.com/isandeepj/ImageGridDemo.git
```
2. Navigate to the project directory
```bash
 cd ImageGridDemo
```
3. Open the project in Xcode
```bash
 open ImageGridDemo.xcodeproj
```  
4. Select a compatible iOS simulator as the target device in Xcode.
5. Build and run the project by clicking the "Run" button in Xcode.
