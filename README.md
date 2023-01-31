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

![SBDrive](https://user-images.githubusercontent.com/60647627/215716869-e28b93bb-97c2-46ff-8ac8-715d67c6b62f.jpg)
