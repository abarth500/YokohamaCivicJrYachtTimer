import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

class YokohamaCivicJrYachtTimerApp extends Application.AppBase {
  var mTimerView;
  function initialize() {
    AppBase.initialize();
  }

  // onStart() is called on application start up
  function onStart(state as Dictionary?) as Void {
    Position.enableLocationEvents(
      Position.LOCATION_CONTINUOUS,
      method(:onPosition)
    );
    System.println("Start");
    return true;
  }

  // onStop() is called when your application is exiting
  function onStop(state as Dictionary?) as Void {
    Position.enableLocationEvents(
      Position.LOCATION_DISABLE,
      method(:onPosition)
    );
    System.println("Stop");
    return true;
  }
  public function onPosition(info as Toybox.Position.Info) as Void {
    mTimerView.onPosition(info);
  }
  // Return the initial view of your application here
  function getInitialView() as Array<Views or InputDelegates>? {
    mTimerView = new YokohamaCivicJrYachtTimerView();
    return [mTimerView, new YokohamaCivicJrYachtTimerDelegate(mTimerView)];
    return (
      [
        new YokohamaCivicJrYachtTimerView(),
        new YokohamaCivicJrYachtTimerDelegate(),
      ] as Array<Views or InputDelegates>
    );
  }
}

function getApp() as YokohamaCivicJrYachtTimerApp {
  return Application.getApp() as YokohamaCivicJrYachtTimerApp;
}
