import QtQuick

import Sber.Controls
import Sber.Core
import Sber.Theme


QtObject {
    property int lineHeight: Core.Settings.LineHeight
    property int type: Widget.Default
    property int backgroundType: Widget.Solid
    property int status: Widget.None

    property color defaultColor:
        backgroundType == Widget.Solid ?
            status == Widget.Success ? Theme.Palette.Surface.Default.Positive :
            status == Widget.Warning ? Theme.Palette.Surface.Default.Warning :
            status == Widget.Error   ? Theme.Palette.Surface.Default.Negative :
            type == Widget.Default   ? Theme.Palette.Surface.Default.SolidPrimary :
            type == Widget.Accient   ? Theme.Palette.Surface.Default.Accent :
            type == Widget.Secondary ? Theme.Palette.Surface.Default.SolidSecondary :
            type == Widget.Black     ? Theme.Palette.Surface.OnLight.SolidPrimary :
                                       Theme.Palette.Surface.OnDark.SolidPrimary :
        backgroundType == Widget.Outline ?
            status == Widget.Success ? Theme.Palette.Surface.Default.Positive :
            status == Widget.Warning ? Theme.Palette.Surface.Default.Warning :
            status == Widget.Error   ? Theme.Palette.Surface.Default.Negative :
            type == Widget.Default   ? Theme.Palette.Outline.Default.SolidPrimary :
            type == Widget.Accient   ? Theme.Palette.Surface.Default.Accent :
            type == Widget.Secondary ? Theme.Palette.Outline.Default.SolidSecondary :
            type == Widget.Black     ? Theme.Palette.Outline.OnLight.SolidPrimary :
                                       Theme.Palette.Outline.OnDark.SolidPrimary :
        "transparent"

    property color hoverColor:
        backgroundType == Widget.Solid ?
            status == Widget.Success ? Theme.Palette.Surface.Default.PositiveHover :
            status == Widget.Warning ? Theme.Palette.Surface.Default.WarningHover :
            status == Widget.Error   ? Theme.Palette.Surface.Default.NegativeHover :
            type == Widget.Default   ? Theme.Palette.Surface.Default.SolidPrimaryHover :
            type == Widget.Accient   ? Theme.Palette.Surface.Default.AccentHover :
            type == Widget.Secondary ? Theme.Palette.Surface.Default.SolidSecondaryHover :
            type == Widget.Black     ? Theme.Palette.Surface.OnLight.SolidPrimaryHover :
                                       Theme.Palette.Surface.OnDark.SolidPrimaryHover :
        backgroundType == Widget.Outline ?
            status == Widget.Success ? Theme.Palette.Surface.Default.PositiveHover :
            status == Widget.Warning ? Theme.Palette.Surface.Default.WarningHover :
            status == Widget.Error   ? Theme.Palette.Surface.Default.NegativeHover :
            type == Widget.Default   ? Theme.Palette.Outline.Default.SolidPrimaryHover :
            type == Widget.Accient   ? Theme.Palette.Surface.Default.AccentHover :
            type == Widget.Secondary ? Theme.Palette.Outline.Default.SolidSecondaryHover :
            type == Widget.Black     ? Theme.Palette.Outline.OnLight.SolidPrimaryHover :
                                       Theme.Palette.Outline.OnDark.SolidPrimaryHover :
        "transparent"

    property color activeColor:
        backgroundType == Widget.Solid ?
            status == Widget.Success ? Theme.Palette.Surface.Default.PositiveActive :
            status == Widget.Warning ? Theme.Palette.Surface.Default.WarningActive :
            status == Widget.Error   ? Theme.Palette.Surface.Default.NegativeActive :
            type == Widget.Default   ? Theme.Palette.Surface.Default.SolidPrimaryActive :
            type == Widget.Accient   ? Theme.Palette.Surface.Default.AccentActive :
            type == Widget.Secondary ? Theme.Palette.Surface.Default.SolidSecondaryActive :
            type == Widget.Black     ? Theme.Palette.Surface.OnLight.SolidPrimaryActive :
                                       Theme.Palette.Surface.OnDark.SolidPrimaryActive :
        backgroundType == Widget.Outline ?
            status == Widget.Success ? Theme.Palette.Surface.Default.PositiveActive :
            status == Widget.Warning ? Theme.Palette.Surface.Default.WarningActive :
            status == Widget.Error   ? Theme.Palette.Surface.Default.NegativeActive :
            type == Widget.Default   ? Theme.Palette.Outline.Default.SolidPrimaryActive :
            type == Widget.Accient   ? Theme.Palette.Surface.Default.AccentActive :
            type == Widget.Secondary ? Theme.Palette.Outline.Default.SolidSecondaryActive :
            type == Widget.Black     ? Theme.Palette.Outline.OnLight.SolidPrimaryActive :
                                       Theme.Palette.Outline.OnDark.SolidPrimaryActive :
        "transparent"

    property int horizontalPadding:
        lineHeight <= Theme.Sizes.LineHeight.Xxs ? 10 :
        lineHeight <= Theme.Sizes.LineHeight.Xs  ? 12 :
        lineHeight <= Theme.Sizes.LineHeight.S   ? 16 :
        lineHeight <= Theme.Sizes.LineHeight.M   ? 20 :
                                                   22
    property int radius:
        lineHeight <= Theme.Sizes.LineHeight.Xxs ? Theme.Sizes.BorderRadius.Xxs :
        lineHeight <= Theme.Sizes.LineHeight.Xs  ? Theme.Sizes.BorderRadius.Xs :
        lineHeight <= Theme.Sizes.LineHeight.S   ? Theme.Sizes.BorderRadius.S :
        lineHeight <= Theme.Sizes.LineHeight.M   ? Theme.Sizes.BorderRadius.M :
                                                   Theme.Sizes.BorderRadius.L
}
