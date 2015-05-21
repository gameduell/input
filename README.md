## Description

This library gives an input handling API for flash, html5, iOS and Android.
The input types it provides are touch, mouse and keyboard.

## Usage:

There are 3 singletons, one for each of the input types: MouseManager, TouchManager and KeyboardManager.
In order to any of these components, the Manager must be initialized.

### Specifics per Platform:

#### iOS
For the TouchManager to work on iOS, another library has to have initialized a view. When the TouchManager initializes it will attach itself to the current top most view.
