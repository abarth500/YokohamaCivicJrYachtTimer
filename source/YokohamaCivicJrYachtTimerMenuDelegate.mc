import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class YokohamaCivicJrYachtTimerMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        /*
        var _item = Menu2.findItemById(:extraInfo);
        System.println(_item);
        _item = _item as ToggleMenuItem;
        _item.setEnabled(Application.Properties.getValue("menuExtraInfoClock"));
        */
        Menu2InputDelegate.initialize();
        System.println("Menu initialize");
    }

    function onMenuItem(item as Symbol) as Void {
        System.println("Menu onMenuItem");
        if (item == :extraInfo) {
            System.println("Menu extraInfo");
        }
    }
    public function onBack() as Void {
        System.println("Menu onBack");
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    public function onSelect(item as MenuItem) as Void {
        System.println("Menu onSelect");
        if (item.getId().toString().equals("extraInfo")) {
            System.println("Menu extraInfo");
            item = item as ToggleMenuItem;
            Application.Properties.setValue("menuExtraInfoClock", item.isEnabled());
        }else if (item.getId().toString().equals("modeRace")) {
            System.println("Menu modeRace");
            item = item as ToggleMenuItem;
            Application.Properties.setValue("menuModeRace", item.isEnabled());
        }
    }
}
