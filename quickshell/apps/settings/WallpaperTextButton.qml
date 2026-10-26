import Sber.Controls as Sber

Sber.Button {
    property string label: ""
    property bool emphasized: false

    text: label
    type: emphasized ? Sber.Widget.Accient : Sber.Widget.Secondary
    backgroundType: emphasized ? Sber.Widget.Solid : Sber.Widget.Clear
    lineHeight: 34
    radius: 12
}
