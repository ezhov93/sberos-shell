// SPDX-License-Identifier: GPL-2.0-or-later
#include <KSvg/FrameSvg>
#include <QGuiApplication>
#include <QRegion>
#include <cmath>
#include <iostream>

int main(int argc, char **argv)
{
    QGuiApplication app(argc, argv);
    if (argc != 2 && argc != 3) return 2;
    KSvg::FrameSvg frame;
    frame.setImagePath(QString::fromLocal8Bit(argv[1]));
    frame.setEnabledBorders(KSvg::FrameSvg::NoBorder);
    if (argc == 3) {
        frame.resizeFrame(QSizeF(620, 400));
        frame.setElementPrefix(QStringLiteral("reveal-64"));
        const QRegion region = frame.mask();
        if (!region.contains(QPoint(400, 40)) || !region.contains(QPoint(100, 300))
            || region.contains(QPoint(100, 40)) || region.contains(QPoint(600, 300))) return 1;
        std::cout << "Native child-menu mask union and transparent gaps passed\n";
        return 0;
    }
    frame.resizeFrame(QSizeF(620, 168));
    for (int step = 0; step <= 64; ++step) {
        frame.setElementPrefix(QStringLiteral("reveal-%1").arg(step));
        const QRegion mask = frame.mask();
        const qreal width = 620 + (504 - 620) * step / 64.0;
        const qreal height = 72 + (168 - 72) * step / 64.0;
        const QRect bounds = mask.boundingRect();
        if (mask.isEmpty() || std::abs(bounds.width() - width) > 1.1
            || std::abs(bounds.height() - height) > 1.1
            || bounds.bottom() != 167 || bounds.left() != 0
            || !mask.contains(QPoint(qRound(width / 2), 160))
            || mask.contains(QPoint(0, bounds.top()))
            || (step < 60 && mask.contains(QPoint(qRound(width / 2), bounds.top() - 2)))) {
            std::cerr << "Incorrect native mask at step " << step << '\n';
            return 1;
        }
    }
    std::cout << "65 native KSvg masks: bounds, lower edge, rounded corners and transparent headroom passed\n";
}
