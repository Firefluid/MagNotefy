# GitHub Project structure

## Flutter App

MagNotes is a Flutter App, meaning that it has all the usual Flutter folders and files, meaning all dart code is stored under the `lib` folder.

The code in this project is split into two parts: UI and handling data

### UI

All dart code that mainly generates the UI (widget composition) of the app is stored under `lib/ui/`.

### Handling data

Any dart code that provides or handles data for the UI (business logic) is stored under `lib/data/`. This project mainly uses the package "[`provider`](https://pub.dev/packages/provider)" to handle state management (other than `setState()`).

## App-Icons

The App-Icons are stored under `assets/appicon` and should not be included into the assets of the Flutter App.  
A SVG (project-file) is stored under `assets/appicon/svg/`.

To actually generate the icons for the final app, a package called "[`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons)" is used. Invoke it by calling

```shell
flutter pub run flutter_launcher_icons:main
```

## Developer documentation

Documentation of the folder or file structure or other technical details of the app is stored under `doc` as Markdown files.