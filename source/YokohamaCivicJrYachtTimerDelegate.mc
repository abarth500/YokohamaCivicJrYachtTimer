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
    WatchUi.pushView(
      new Rez.Menus.MainMenu(),
      new YokohamaCivicJrYachtTimerMenuDelegate(),
      WatchUi.SLIDE_UP
    );
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
