<div align="center">
  <h1 align="center" style="font-size: 70px;">Flutter PinPut From <a href="https://www.linkedin.com/in/thornike/" target="_blank">Tornike</a> </h1>
  
<a href="https://www.buymeacoffee.com/fman" target="_blank"><img src="https://img.buymeacoffee.com/button-api/?text=Thank me with a coffee&emoji=&slug=fman&button_colour=40DCA5&font_colour=ffffff&font_family=Poppins&outline_colour=000000&coffee_colour=FFDD00"></a>
  
</div>


Flutter package to create Pin code input (OTP) text field.
### [**Live Demo**](https://rebrand.ly/6390b8)



## Features:
-    Builtin animations
-    Animated Decortion Switching
-    Form validation
-    Standard Cursor
-    Custom Cursor
-    Cursor Animation
-    Beautiful Examples
-    Copy From Clipboard
-    Ready For Custom Keyboard
-    Standard Paste option
-    Obscuring Character
-    Obscuring Widget
-    Haptic Feedback
-    Close Keyboard After Submittion


## Support
PRs Welcome
Discord [Channel](https://discord.gg/ssE8eh)
Example app on github has multiple tempates to choose from
Don't forget to give it a star ⭐



## Demo
<img src="https://user-images.githubusercontent.com/26390946/155599527-fe934f2c-5124-4754-bbf6-bb97d55a77c0.gif" width="300em" /><img src="https://user-images.githubusercontent.com/26390946/155599870-03387689-7be2-4a30-8e6f-90136a0515be.gif" width="300em" /><img src="https://user-images.githubusercontent.com/26390946/155600099-d0a02f55-09e6-4142-92de-066cd71cf211.gif" width="300em" /><img src="https://user-images.githubusercontent.com/26390946/155600276-0380b3b4-3d9c-4ea8-87d0-4f7ebd86e460.gif" width="300em" />
<img src="https://user-images.githubusercontent.com/26390946/155600427-901c1eae-e565-4cf8-a338-8ac40eb1149c.gif" width="300em" />


## Overview

Pin has 6 state `default` `focused`, `submitted`, `following`, `disabled`, `error`, you can customize each state by spefying theme parameter
From one state to another pin smoothly animates automatically.

```dart
  const PinTheme({
    this.width,
    this.height,
    this.margin,
    this.padding,
    this.textStyle,
    this.decoration,
    this.constraints,
  });
```
Start creating `defaultPinTheme` first.
```dart
    final defaultPinTheme = PinTheme(
      width: 60,
      height: 64,
      textStyle: TextStyle(fontSize: 20, color: Colors.white),
      decoration: BoxDecoration(color: Color.fromRGBO(159, 132, 193, 0.8)),
    );
```
if you want all pins to be the same don't pass other theme parameters,
If not, create `focusedPinTheme`, `submittedPinTheme`, `followingPinTheme`, `errorPinTheme` from `defaultPinTheme`
```dart
    final focusedTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(color: Colors.greenAccent),
    );
    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(color: Colors.greenAccent),
    );
```
Put everuthing togather
```dart
    final defaultPinTheme = PinTheme(
      width: 60,
      height: 64,
      textStyle: GoogleFonts.poppins(fontSize: 20, color: Colors.white),
      decoration: BoxDecoration(color: Color.fromRGBO(159, 132, 193, 0.8)),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(color: Colors.greenAccent),
    );
    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(color: Colors.redAccent),
    );


    return PinPut(
      defaultTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      submittedPinTheme: submittedPinTheme,
    );
```


## Installation


### 1. Depend on it
Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  pinput: ^1.2.0
```

### 2. Install it

You can install packages from the command line:

with `pub`:

```css
$ pub get
```

with `Flutter`:

```css
$ flutter packages get
```

### 3. Import it

Now in your `Dart` code, you can use:

```dart
import 'package:pinput/pin_put/pin_put.dart';
```


## Properties


```dart
  final PinTheme? defaultTheme;
  final PinTheme? focusedPinTheme;
  final PinTheme? submittedPinTheme;
  final PinTheme? followingPinTheme;
  final PinTheme? disabledPinTheme;
  final PinTheme? errorPinTheme;

  final bool closeKeyboardWhenCompleted;

  final TextDirection? textDirection;

  /// Displayed fields count. PIN code length.
  final int length;

  /// Same as FormField onFieldSubmitted, called when PinPut submitted.
  final ValueChanged<String>? onCompleted;

  /// Signature for being notified when a form field changes value.
  final FormFieldSetter<String>? onSaved;

  /// Called every time input value changes.
  final ValueChanged<String>? onChanged;

  /// Called when user clicks on PinPut
  final VoidCallback? onTap;

  /// Used to get, modify PinPut value and more.
  final TextEditingController? controller;

  /// Defines the keyboard focus for this
  /// To give the keyboard focus to this widget, provide a [focusNode] and then
  /// use the current [FocusScope] to request the focus:
  final FocusNode? focusNode;

  /// Widget that is displayed before field submitted.
  final Widget? preFilledWidget;

  /// Sets the positions where the separator should be shown
  final List<int>? separatorPositions;

  /// Builds a PinPut separator
  final Widget? separator;

  /// Defines how [PinPut] fields are being placed inside [Row]
  final MainAxisAlignment mainAxisAlignment;

  /// Defines how each [PinPut] field are being placed within the container
  final AlignmentGeometry pinContentAlignment;

  /// curve of every [PinPut] Animation
  final Curve animationCurve;

  /// Duration of every [PinPut] Animation
  final Duration animationDuration;

  /// Animation Type of each [PinPut] field
  /// options:
  /// none, scale, fade, slide, rotation
  final PinAnimationType pinAnimationType;

  /// Begin Offset of ever [PinPut] field when [pinAnimationType] is slide
  final Offset? slideTransitionBeginOffset;

  /// Defines [PinPut] state
  final bool enabled;

  /// {@macro flutter.widgets.editableText.autofocus}
  final bool autofocus;

  /// Whether we use Native keyboard or custom `Numpad`
  /// when flag is set to false [PinPut] wont be focusable anymore
  /// so you should set value of [PinPut]'s [TextEditingController] programmatically
  final bool useNativeKeyboard;

  final bool enableInteractiveSelection;

  /// If true the focused field includes fake cursor
  final bool showCursor;

  /// If [showCursor] true the focused field includes cursor widget or '|'
  final Widget? cursor;

  /// The appearance of the keyboard.
  /// This setting is only honored on iOS devices.
  /// If unset, defaults to [ThemeData.brightness].
  final Brightness? keyboardAppearance;

  /// {@macro flutter.widgets.editableText.inputFormatters}
  final List<TextInputFormatter>? inputFormatters;

  /// {@macro flutter.widgets.editableText.keyboardType}
  final TextInputType keyboardType;

  /// Provide any symbol to obscure each [PinPut] field
  /// Recommended ●
  final String obscuringCharacter;

  final Widget? obscuringWidget;

  final bool obscureText;

  /// {@macro flutter.widgets.editableText.textCapitalization}
  final TextCapitalization textCapitalization;

  /// The type of action button to use for the keyboard.
  ///
  /// Defaults to [TextInputAction.newline] if [keyboardType] is
  /// [TextInputType.multiline] and [TextInputAction.done] otherwise.
  final TextInputAction? textInputAction;

  /// Configuration of toolbar options.
  ///
  /// If not set, select all and paste will default to be enabled. Copy and cut
  /// will be disabled if [obscureText] is true. If [readOnly] is true,
  /// paste and cut will be disabled regardless.
  final ToolbarOptions? toolbarOptions;

  /// lists of auto fill hints
  final Iterable<String>? autofillHints;

  final bool enableSuggestions;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final TextSelectionControls? selectionControls;
  final String? restorationId;
  final bool enableIMEPersonalizedLearning;
  final ValueChanged<String>? onClipboardFound;

  /// Use haptic feedback everytime user types on keyboard
  /// See more details in [HapticFeedback]
  final HapticFeedbackType hapticFeedbackType;


```
## Example

#### Standard
```dart
  Widget buildPinPut() {
    return PinPut();
  }
```


#### Rounded With Shadow
```dart
    final defaultPinTheme = PinTheme(
      width: 60,
      height: 64,
      textStyle: TextStyle(fontSize: 20, color: Color.fromRGBO(70, 69, 66, 1)),
      decoration: BoxDecoration(
        color: Color.fromRGBO(232, 235, 241, 0.37),
        borderRadius: BorderRadius.circular(24),
      ),
    );

    final cursor = Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: 21,
        height: 1,
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Color.fromRGBO(137, 146, 160, 1),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );

    return PinPut(
      length: 4,
      defaultTheme: defaultPinTheme,
      separator: SizedBox(width: 16),
      focusedPinTheme: defaultPinTheme.copyWith(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05999999865889549),
              offset: Offset(0, 3),
              blurRadius: 16,
            )
          ],
        ),
      ),
      showCursor: true,
      cursor: cursor,
    );
  }
```

#### Filled
```dart
  Widget buildPinPut() {
      final defaultPinTheme = PinTheme(
      width: 60,
      height: 64,
      textStyle: TextStyle(fontSize: 20, color: Colors.white),
      decoration: BoxDecoration(
        color: Color.fromRGBO(159, 132, 193, 0.8),
      ),
    );

    return Container(
      width: 243,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: PinPut(
        length: 4,
        separator: Container(
          height: 64,
          width: 1,
          color: Colors.white,
        ),
        defaultTheme: defaultPinTheme,
        showCursor: true,
        focusedPinTheme: defaultPinTheme.copyWith(
          decoration: BoxDecoration(color: Color.fromRGBO(124, 102, 152, 1)),
        ),
      ),
    );
  }
```


