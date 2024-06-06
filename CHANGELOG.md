#### 5.0.0 · 6/06/2024
- Implemented Pinput.builder to build custom Pinput fields
- Migrated deprecated imperative apply of Flutter's Gradle plugins example app
- Removed smart_auth dependency which was responsible for SMS autofill (Not everyone might need it and it was causing some issues)
- [Migration guide](MIGRATION.md)

#### 4.0.0 · 10/02/2024
- Fixed RECEIVER_EXPORTED exception in android SDK 34 PR
- Fix "Namespace not specified" error when upgrading to AGP 8.0 PR
- Updated readme

#### 3.0.1 · 25/08/2023

- Fixed contextMenuBuilder

#### 3.0.0 · 03/08/2023

- Replaced `separator` and `separatorPositions` with `separatorBuilder`

  | Property | Meaning/Default |
  |--------------------------|:---------------:|
  | separatorBuilder | (_) => const SizedBox(width: 8)|

#### 2.3.0 · 24/07/2023

- Fixed AGP 4.2<= compatibility in smart_auth
- Updated SDK constraints
- Updated default SMS code matcher regex length to 8 digits


#### 2.2.31 · 22/02/2023

### Added:
| Property                 | Meaning/Default |
|--------------------------|:---------------:|
| enableIMEPersonalizedLearning |      false      |

Whether to enable that the IME update personalized data such as typing history and user dictionary data.
This flag only affects Android. On iOS, there is no equivalent flag.

#### 2.2.30 · 15/02/2023
- Fixed "TapDownDetails not match the corresponding type" on Flutter's master channel - [issue](https://github.com/Tkko/Flutter_Pinput/issues/124)


#### 2.2.30 · 15/02/2023
- Fixed "TapDownDetails not match the corresponding type" on Flutter's master channel - [issue](https://github.com/Tkko/Flutter_Pinput/issues/124)

#### 2.2.23 · 25/01/2023

- Added correct SDK constraints
- Improved readme


#### 2.2.22 · 25/01/2023

- Removed FocusTrapArea
- Removed ToolbarOptions
- Added contextMenuBuilder, which is replacement of ToolbarOptions
- Added onTapOutside callback, which is invoked when a tap is detected outside of the Pinput
- Fixed text selection behavior

#### 2.2.21 · 29/12/2022

- Fixed the case where app was crashing while reading the OTP

#### 2.2.19 · 19/12/2022

- Improved changelog
- Added better demo screenshots

#### 2.2.18 · 19/12/2022

- Added warning for [FocusTrapArea issue](https://github.com/Tkko/Flutter_Pinput/issues/98)
- Improved changelog

#### 2.2.17 · 19/12/2022

- Added demo screenshot for pub
- Added funding URLs

#### 2.2.16 · 06/10/2022

- Improved Docs

#### 2.2.15 · 06/10/2022

- Improved Docs

#### 2.2.14 · 06/10/2022

- Improved Example

#### 2.2.13 · 03/10/2022

- Bumped minimum Flutter SDK version to 2.0.0
- Added

| Property                 | Meaning/Default |
|--------------------------|:---------------:|
| isCursorAnimationEnabled |      true       |

#### 2.2.12 · 05/08/2022

- Added

| Property          |                      Meaning/Default                       |
|-------------------|:----------------------------------------------------------:|
| senderPhoneNumber | null / Optional parameter for Android SMS User Consent API |

#### 2.2.11 · 14/06/2022

- Fixed `smsCodeMatcher` ([PR](https://github.com/Tkko/Flutter_Pinput/pull/94))

#### 2.2.10 · 31/05/2022

- When this widget receives focus and is not completely visible (for example scrolled partially off
  the screen or overlapped by the keyboard)
  then it will attempt to make itself visible by scrolling a surrounding [Scrollable], if one is
  present. This value controls how far from the edges of a [Scrollable] the TextField will be
  positioned after the scroll.

| Property      |  Meaning/Default   |
|---------------|:------------------:|
| scrollPadding | EdgeInsets.all(20) |

#### 2.2.9 · 16/05/2022

- onCompleted mot called
- Added tests

#### 2.2.8 · 13/05/2022

- Fixed dart 2.17 hints

#### 2.2.7 · 04/04/2022

- Option to listen for multiple sms on android

| Property                      | Meaning/Default |
|-------------------------------|:---------------:|
| listenForMultipleSmsOnAndroid |      false      |

#### 2.2.6 · 02/04/2022

- Updated smart_auth
- Updated readme

#### 2.2.5 · 28/03/2022

Added

| Property           |     Meaning/Default      |
|--------------------|:------------------------:|
| crossAxisAlignment | CrossAxisAlignment.start |

#### 2.2.4 · 21/03/2022

- Fixed onClipboardFound

#### 2.2.3 · 19/03/2022

Added Android SMS Autofill support

| Property                 |                                       Meaning/Default                                       |
|--------------------------|:-------------------------------------------------------------------------------------------:|
| androidSmsAutofillMethod |                          Options to enable SMS autofill on Android                          |
| smsCodeMatcher           | Used to extract code from SMS for Android Autofill if [androidSmsAutofillMethod] is enabled |

#### 2.1.4 · 06/03/2022

Updated docs

Added

| Property               |                                          Meaning/Default                                           |
|------------------------|:--------------------------------------------------------------------------------------------------:|
| Validator              |                              To validate Pinput with or without Form                               |
| pinputAutovalidateMode |                                  PinputAutovalidateMode.onSubmit                                   |
| errorBuilder           |                           To build custom error widget under the Pinput                            |
| errorTextStyle         |                       Standard error text style, displayed under the Pinput                        |
| toolbarEnabled         |               If true, paste button will appear on longPress, doubleTap event / true               |
| forceErrorState        | If true [errorPinTheme] will be applied and [errorText] will be displayed under the Pinput / false |
| errorText              |                        Text displayed under the Pinput if Pinput is invalid                        |

#### 2.0.4 · 03/03/2022

- Updated docs
- Added onLongPress

#### 2.0.3 · 02/03/2022

- Updated readme.

#### 2.0.2 · 25/02/2022

Sorry guys this version will break your code 💙 Introduced PinTheme class to control state of the
individual pin easily, see readme's Getting Started section for examples.

- Refactored, renamed some properties.
- Added new Pinput examples
- With long press user can paste from clipboard

##### Changes

| Old                      |            New             |
|--------------------------|:--------------------------:|
| onSubmit                 |        onCompleted         |
| fieldsCount              |           length           |
| obscureText              |     obscuringCharacter     |
| obscureText              |     obscuringCharacter     |
| eachFieldHeight          |      PinTheme.height       |
| eachFieldWidth           |       PinTheme.width       |
| eachFieldConstraints     |    PinTheme.constraints    |
| disabledDecoration       | PinTheme.disabledPinTheme  |
| followingFieldDecoration | PinTheme.followingPinTheme |
| selectedFieldDecoration  |  PinTheme.focusedPinTheme  |
| submittedFieldDecoration | PinTheme.submittedPinTheme |
| eachFieldMargin          |      PinTheme.margin       |
| eachFieldPadding         |      PinTheme.padding      |

#### 1.2.1 · 10/09/2021

🔥🚀 Merged PRs and Fixed common issues

#### 1.2.0 · 03/13/2021

🔥🚀 Now PinPut supports custom numpad.(See demos)
Added `checkClipboard` property

#### 1.1.0 · 03/02/2021

🔥🚀 Migrated to Null safety

#### 1.0.0 · 01/14/2021

🔥🚀 Updated Example, Increased package version to `1.0.0` in order to make it more trustful

#### 0.2.6 · 10/09/2020

🔥🚀 Added `cursor`, `preFilledWidget`, `mainAxisSize` and `autovalidateMode` properties.

#### 0.2.5 · 08/30/2020

🔥🚀 Added fake `cursor`, `separatorPositions`, `separator` and optimized project with the help of
community. credits to @[furaiev](https://github.com/furaiev), @[Holofox](https://github.com/Holofox)
,

#### 0.2.4 · 05/19/2020

🔥🚀 Fixed Focus problems. Updated readme.

#### 0.2.3 · 04/12/2020

🔥🚀 Fixed Focus on click after back button click

#### 0.2.2 · 04/09/2020

🔥🚀 Fixed Demo urls

#### 0.2.1 · 04/09/2020

🔥🚀 Minor fixes and demos

#### 0.2.0 · 04/07/2020

🔥🚀 Added some useful Documentation

#### 0.2.0-dev.1 · 04/07/2020

🔥🚀 Breaking changes, changed widget building logic so now it supports:

- Backspace on keyboard
- Every pixel customization
- Nice animations
- Form validation
- Ios auto fill · testing needed

#### 0.1.10 -02/08/2019

👍 With the help of community: @xportation

* Added Set autofocus on the first field when the attribute is defined|

#### 0.1.9 · 07/02/2019

* Added

| Property | Default/Meaning       |
|----------|-----------------------|
| onClear  | Clear button callback |

#### 0.1.8 · 06/14/2019

👍 With the help of community: @datvo0110, @almeynman

* Fixed minor bugs
* Added

| Property        | Default/Meaning |
|-----------------|-----------------|
| containerHeight | 100.0           |

#### 0.1.7 · 05/12/2019

👍 With the help of community: @datvo0110, @mwgriffiths88, @inromualdo

* Fixed minor bugs, check clipboard when app is resumed...
* Added Properties ability to hide keyboard & custumize more

| Property           | Default/Meaning         |
|--------------------|-------------------------|
| textCapitalization | TextCapitalization.none |

#### 0.1.6 · 01/17/2019

* Added Properties ability to hide keyboard & custumize more

| Property        | Default/Meaning                                 |
|-----------------|-------------------------------------------------|
| clearButtonIcon | Icon(Icons.backspace, size: 30)                 |
| pasteButtonIcon | Icon(Icons.content_paste, size: 30)             |
| unFocusWhen     | Default is False, True to hide keyboard         |
| textStyle       | TextStyle(fontSize: 30)                         |
| spaceBetween    | space between fields Default: 10.0              |
| inputDecoration | Ability to style field's border, padding etc... |

#### 0.1.5 · 12/17/2018

* Added Copy From Clipboard functionality if copied text length is equal to fields count

| Property        | Default             |
|-----------------|---------------------|
| pasteButtonIcon | Icons.content_paste |

*Note that

clearButtonEnabled will change with actionButtonEnabled in next release, right now if it is true
both clear and paste functionality works

#### 0.1.4 · 10/31/2018

* Added

| Property  | Default |
|-----------|---------|
| autoFocus | true    |

#### 0.1.3+1 · 11026/2018

* Minor fixes

#### 0.1.3 · 10/26/2018

* Transformed plugin to MVVM pattern
* Fixed onSubmit call when all fields aren't filled
* Updated Demo
* Added

| Property           | Default         |
|--------------------|-----------------|
| clearButtonIcon    | Icons.backspace |
| clearButtonEnabled | true            |
| clearButtonColor   | 0xFF66BB6A      |

#### 0.1.2 · 10/24/2018

* Added

| Property       | Default |
|----------------|:-------:|
| borderRadius   |   5.0   |
| keybaordType   | number  |
| keyboardAction |  next   |

#### 0.1.1 · 10/24/2018

* Added

| Property      | Default  |
|---------------|:--------:|
| onSubmit      | Function |
| fieldsCount   |    4     |
| isTextObscure |  false   |
| fontSize      |   40.0   |

#### 0.0.1 · 10/24/2018

* Initial release, working base functionality