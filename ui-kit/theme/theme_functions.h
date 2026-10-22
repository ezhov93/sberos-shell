#pragma once

#include <QColor>
#include <QDirIterator>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>


namespace ThemeFunctions {
void ReplaceTagToColor(QJsonValueRef val, const QJsonObject& colors) {
  if (val.isObject()) {
    auto obj = val.toObject();
    if (obj.contains("xml") && obj["xml"].toObject().value("kind").toString() == "gradient") {
      auto gradientObj = obj["xml"].toObject();
      auto gradientArr = gradientObj.value("colors").toArray();
      for (int i = 0; i < gradientArr.size(); ++i) {
        ReplaceTagToColor(gradientArr[i], colors);
      }
      gradientObj["colors"] = gradientArr;
      QJsonDocument doc(gradientObj);
      val = QString(doc.toJson(QJsonDocument::Compact));
    } else {
      for (auto it = obj.begin(); it != obj.end(); ++it) {
        ReplaceTagToColor(it.value(), colors);
      }
      val = obj;
    }
  } else if (val.isString()) {
    static const QRegularExpression colorRegExp("\\[(?<color>\\w+\\.\\w+\\.\\d+)\\]");
    const auto match = colorRegExp.match(val.toString());
    if (match.hasMatch()) {
      const QString colorTag = match.captured("color");
      auto colorPath = colorTag.split('.', Qt::SkipEmptyParts);
      if (colorPath.size() != 3) {
        qDebug() << "Error: incorrect color key: " + colorTag;
        return;
      }

      QJsonValue colorValue = colors;
      for (int i = 0; i < colorPath.size(); ++i) {
        if (colorValue.isObject()) {
          QString altKey = colorPath[i];
          altKey[0] = altKey[0].toUpper();
          QJsonObject colorObj = colorValue.toObject();
          colorValue = colorObj.contains(colorPath[i]) ?
                           colorObj.value(colorPath[i]) :
                           colorObj.value(altKey);
        } else {
          qDebug() << "Error: can not find tag '" + colorTag + "' in color map";
        }
      }
      if (colorValue.isString()) {
        val = colorValue;
      } else {
        qDebug() << "Error: color with tag '" + colorTag + "' is not a string";
      }
    }

    // convert colors to hex argb
    auto valStr = val.toString();
    if (valStr.size() == 9 && valStr[0] == '#') {
      valStr = valStr.insert(1, QString(valStr[7]) + valStr[8]);
      valStr.resize(9);
      val = valStr;
    } else if (valStr.startsWith("rgba")) {
      static const QRegularExpression colorRegExp(
          "rgba\\((?<r>\\d+),\\s*(?<g>\\d+),\\s*(?<b>\\d+),\\s*(?<a>\\d+\\.\\d+)\\)");
      const auto match = colorRegExp.match(val.toString());
      if (match.hasMatch()) {
        QColor c(match.captured("r").toInt(), match.captured("g").toInt(),
                 match.captured("b").toInt(), qRound(match.captured("a").toDouble() * 255));
        val = c.name(QColor::HexArgb);
      }
    } else if (valStr.startsWith("rgb")) {
      static const QRegularExpression colorRegExp(
          "rgb\\((?<r>\\d+),\\s*(?<g>\\d+),\\s*(?<b>\\d+)\\)");
      const auto match = colorRegExp.match(val.toString());
      if (match.hasMatch()) {
        QColor c(match.captured("r").toInt(), match.captured("g").toInt(),
                 match.captured("b").toInt());
        val = c.name(QColor::HexArgb);
      }
    }
  }
}

QJsonObject UploadTheme(const QString& colorsDir, const QString& themeFile) {
  QJsonObject colorsMap;

  auto toCamelCase = [](const QString& text) {
    auto parts = text.split('_', Qt::SkipEmptyParts);
    for (int i = 1; i < parts.size(); ++i)
      parts[i][0] = parts[i][0].toUpper();
    return parts.join("");
  };

  QDirIterator it(colorsDir);
  while (it.hasNext()) {
    it.next();
    if (it.fileInfo().isDir()) {
      QDirIterator colorIt(it.filePath());
      const QString colorFolder = it.fileName();
      QJsonObject colorFolderObj;
      while (colorIt.hasNext()) {
        colorIt.next();
        if (colorIt.fileInfo().isFile()) {
          QFile f(colorIt.filePath());
          if (f.open(QIODevice::ReadOnly)) {
            const QString colorName = toCamelCase(colorIt.fileName().split('.', Qt::SkipEmptyParts).value(0));
            const auto json = QJsonDocument::fromJson(f.readAll());
            if (json.isObject()) {
              colorFolderObj[colorName] = json.object();
            }
          } else {
            qDebug() << "Components: Failed to open config " + it.fileName();
          }
        }
      }
      colorsMap[colorFolder] = colorFolderObj;
    }
  }
  if (colorsMap.isEmpty()) {
    qDebug() << "Components: Failed to generate theme config";
  }

  auto mergeJson = [](QJsonValueRef l, const QJsonObject& r) {
    auto lObj = l.toObject();
    for (auto it = r.constBegin(); it != r.constEnd(); ++it) {
      lObj.insert(it.key(), it.value());
    }
    return lObj;
  };

  QFile f(themeFile);
  if (f.open(QIODevice::ReadOnly)) {
    auto json = QJsonDocument::fromJson(f.readAll());
    if (json.isObject()) {
      auto obj = json.object();
      if (!obj.empty()) {
        ReplaceTagToColor(obj["Dark"], colorsMap);
        obj["Dark"] = mergeJson(obj["Dark"], colorsMap);
        ReplaceTagToColor(obj["Light"], colorsMap);
        obj["Light"] = mergeJson(obj["Light"], colorsMap);
        return obj;
      }
    }
  }
  qDebug() << "Components: Failed to upload theme config " + themeFile;
  return QJsonObject();
}
} // namespace ColorFunctions
