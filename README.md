# SBDrive

Educational project from Skillbox with the main aim of implementing a custom client for Yandex Disk service.
Functionality of the app is available only after authorization process (you should have a Yandex account).

Project is based on MVP programming pattern, consist of three main Views:
- recents,
- published,
- all files.

No internet statement is handled.
Supported file formats: doc, docx, jpg, png, pdf. Appropriate warning is shown when try to open any unsupported file format.
All data is stored in CoreData, if possible. All images are cahed with NSCache.
You can share, rename and delete each file with appropriate format.

The app is localized for two languages: russian and english.

![SBDrive](https://user-images.githubusercontent.com/60647627/215700436-79a7c425-0835-4600-8246-6f1746017ef0.jpg)
