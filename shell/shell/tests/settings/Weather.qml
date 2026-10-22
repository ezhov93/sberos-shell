pragma Singleton
import QtQuick
QtObject {
    property string locationName: ""
    signal placesFound(var list)
    function searchPlace(text) { placesFound([{name: text, region: "Test", country: "RU", lat: 55.75, lon: 37.62}]) }
}
