import QtQuick

ThemeTextField {
    // Application surfaces do not share the Shell launcher's always-dark
    // palette. Bind every semantic colour to AppTheme so forced light/dark and
    // live system appearance changes keep text and focus affordances legible.
    surfaceColor: AppTheme.fieldSurface
    outlineColor: AppTheme.border
    focusedOutlineColor: AppTheme.focusRing
    textColor: AppTheme.text
    mutedTextColor: AppTheme.mutedText
    cornerRadius: AppTheme.smallRadius
}
