# Changelog
## 0.1.6 -01/17/2019

* Added
 Properties ability to hide keyboard & custumize more

| Property  | Default/Meaning |
| ------------- | ------------- |
| clearButtonIcon  | Icon(Icons.backspace, size: 30) |
| pasteButtonIcon  | Icon(Icons.content_paste, size: 30) |
| unFocusWhen  | Default is False, True to hide keyboard|
| textStyle  | TextStyle(fontSize: 30) |
| spaceBetween | space between fields Default: 10.0|
| inputDecoration  | Ability to style field's border, padding etc... |


## 0.1.5 - 12/17/2018

* Added
 Copy From Clipboard fnctionality if copied text length is equal to fields count

| Property  | Default |
| ------------- | ------------- |
| pasteButtonIcon  | Icons.content_paste |

*Note that

	clearButtonEnabled will change with actionButtonEnabled in next release, right now if it is true both clear and paste functinality works

## 0.1.4 - 10/31/2018

* Added

| Property  | Default |
| ------------- | ------------- |
| autoFocus  | true |

## 0.1.3+1 - 11026/2018

* Minor fixes

## 0.1.3 - 10/26/2018

* Transformed plugin to MVVM pattern
* Fixed onSubmit call when all fieds aren't filled
* Updated Demo
* Added

| Property  | Default |
| ------------- | ------------- |
| clearButtonIcon  | Icons.backspace |
| clearButtonEnabled  | true |
| clearButtonColor  | 0xFF66BB6A |

## 0.1.2 - 10/24/2018

* Added

| Property   | Default |
|------------|:-------:|
| borderRadius  | 5.0 |
| keybaordType  | number |
| keyboardAction  | next |

## 0.1.1 - 10/24/2018

* Added

| Property   | Default |
|------------|:-------:|
| onSubmit  | Function |
| fieldsCount  | 4 |
| isTextObscure  | false |
| fontSize  | 40.0 |

## 0.0.1 - 10/24/2018

* Initial release, working base functionality