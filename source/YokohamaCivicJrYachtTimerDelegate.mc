import Toybox.System;
import Toybox.Lang;
import Toybox.WatchUi;

class YokohamaCivicJrYachtTimerDelegate extends WatchUi.BehaviorDelegate {
    var mParentView;
    function initialize(view) {
        BehaviorDelegate.initialize();
        mParentView = view;
    }

    function onMenu() as Boolean {
        System.println("Push");
        //var _menu = new Rez.Menus.MainMenu();
        var _menu = new WatchUi.Menu2({ :title => Rez.Strings.ToggleMenuTitle });
        _menu.addItem(
            new WatchUi.ToggleMenuItem(Rez.Strings.Toggle_2_Label, { :enabled => Rez.Strings.Toggle_2_OnSubLabel, :disabled => Rez.Strings.Toggle_2_OffSubLabel }, "modeRace", Application.Properties.getValue("menuModeRace"), {
                :alignment => WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT,
            })
        );
        _menu.addItem(
            new WatchUi.ToggleMenuItem(Rez.Strings.Toggle_1_Label, { :enabled => Rez.Strings.Toggle_1_OnSubLabel, :disabled => Rez.Strings.Toggle_1_OffSubLabel }, "extraInfo", Application.Properties.getValue("menuExtraInfoClock"), {
                :alignment => WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT,
            })
        );
        WatchUi.pushView(_menu, new YokohamaCivicJrYachtTimerMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }
    function onSelect() {
        System.println("Select");
        mParentView.toggleTimer();
    }
    function onNextPage() {
        System.println("Next");
        mParentView.down();
        return true;
    }
    function onPreviousPage() {
        System.println("Previous");
        mParentView.up();
        return true;
    }

    function onBack() {
        System.println("Back");
        return false;
    }
}
