pragma Singleton
import QtQuick

QtObject {
    function dateInRange(date, left, right) {
        if (!isValid(left) || !isValid(right) || !isValid(date))
            return false;
        var l = min(left, right);
        var r = max(left, right);
        return (dateIsLess(l, date) || dateIsEqual(date, l)) && (dateIsLess(date, r) || dateIsEqual(date, r));
    }
    function dateIsLess(left, right) {
        return left.getFullYear() < right.getFullYear() || left.getFullYear() === right.getFullYear() && left.getMonth() < right.getMonth() || left.getFullYear() === right.getFullYear() && left.getMonth() === right.getMonth() && left.getDate() < right.getDate();
    }
    function dateIsEqual(left, right) {
        if (!isValid(left) || !isValid(right))
            return false;
        return left.getDate() === right.getDate() && left.getMonth() === right.getMonth() && left.getFullYear() === right.getFullYear();
    }

    function monthInRange(date, left, right) {
        if (!isValid(left) || !isValid(right) || !isValid(date))
            return false;
        var l = min(left, right);
        var r = max(left, right);
        return (monthIsLess(l, date) || monthIsEqual(date, l)) && (monthIsLess(date, r) || monthIsEqual(date, r));
    }
    function monthIsLess(left, right) {
        return left.getFullYear() < right.getFullYear() || left.getFullYear() === right.getFullYear() && left.getMonth() < right.getMonth();
    }
    function monthIsEqual(left, right) {
        if (!isValid(left) || !isValid(right))
            return false;
        return left.getMonth() === right.getMonth() && left.getFullYear() === right.getFullYear();
    }

    function yearInRange(date, left, right) {
        if (!isValid(left) || !isValid(right) || !isValid(date))
            return false;
        var l = min(left, right);
        var r = max(left, right);
        return (yearIsLess(l, date) || yearIsEqual(date, l)) && (yearIsLess(date, r) || yearIsEqual(date, r));
    }
    function yearIsLess(left, right) {
        return left.getFullYear() < right.getFullYear();
    }
    function yearIsEqual(left, right) {
        if (!isValid(left) || !isValid(right))
            return false;
        return left.getFullYear() === right.getFullYear();
    }

    function min(left, right) {
        return left <= right ? left : right;
    }
    function max(left, right) {
        return left >= right ? left : right;
    }
    function isValid(date) {
        return date && !isNaN(date);
    }

    function upperFirst(str) {
        return str.charAt(0).toUpperCase() + str.slice(1);
    }
    function getMonthName(month, locale) {
        return upperFirst(locale.standaloneMonthName(month, Locale.LongFormat));
    }
    function dateToText(date, locale) {
        if (isValid(date))
            return date.toLocaleString(locale, "dd.MM.yyyy");
        return "";
    }
    function textToDate(text, locale) {
        return Date.fromLocaleDateString(locale, text.replace(/\,|\-|\\/g, '.'), "d.M.yyyy");
    }

    function textToTime(timeAsString) {
        const timeSplit = timeAsString.split(':');
        const now = new Date();
        return new Date(now.getFullYear(), now.getMonth(), now.getDate(), ...timeSplit);
    }
    function timeIsEqual(left, right) {
        if (!isValid(left) || !isValid(right))
            return false;
        return left.getHours() === right.getHours() && left.getMinutes() === right.getMinutes() && left.getSeconds() === right.getSeconds();
    }
    function isHourValid(value) {
        return value >= 0 && value < 24;
    }

    function isMinuteValid(value) {
        return value >= 0 && value < 60;
    }

    function isSecondsValid(value) {
        return value >= 0 && value < 60;
    }
}
