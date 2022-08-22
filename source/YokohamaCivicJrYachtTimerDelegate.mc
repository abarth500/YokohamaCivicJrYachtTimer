import Toybox.Lang;
import Toybox.WatchUi;

class YokohamaCivicJrYachtTimerDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new YokohamaCivicJrYachtTimerMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

}