#pragma once

#include <QObject>
#include <QtQmlIntegration>

namespace Widget {
Q_NAMESPACE
QML_ELEMENT

enum Type { Default, Accient, Secondary, Black, White, TypeLast };
Q_ENUM_NS(Type)

enum Background { Solid, Outline, Clear, BackgroundLast };
Q_ENUM_NS(Background)

enum Status {
    None,
    Success,
    Warning,
    Error,
    StatusLast,

    Online = Success,
    Afk = Warning,
    Offline = Error,
};
Q_ENUM_NS(Status)

enum Corner { Flat, Square, Circle, CornerLast };
Q_ENUM_NS(Corner)

enum Placement { Inner, Outer, Left = Inner, Right = Outer, PlacementLast };
Q_ENUM_NS(Placement)

enum Delimiter { NoDelimiter, Arrow, Minus };
Q_ENUM_NS(Delimiter)
}; // namespace Widget
