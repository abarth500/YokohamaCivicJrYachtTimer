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
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
        System.println("Start");
        return true;
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        Application.Properties.setValue("progressCircleStr", "D");
        Application.Properties.setValue("timerSecRace", 0);
        Application.Properties.setValue("timerSecPractice", 0);
        Application.Properties.setValue("timerStatus", 0);
        Application.Properties.setValue("GPSLastLatitude", 0.0);
        Application.Properties.setValue("GPSLastLongitude", 0.0);
        Application.Properties.setValue("GPSLastHeading", 0.0);
        Application.Properties.setValue("GPSLastSpeed", 0.0);
        Application.Properties.setValue("GPSLastAccuracy", 0);
        Application.Properties.setValue("TimeRecordRaceBEST", 0);
        Application.Properties.setValue("TimeRecordRaceLAST", 0);
        Application.Properties.setValue("TimeRecordPracticeBEST", 0);
        Application.Properties.setValue("TimeRecordPracticeLAST", 0);
        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
        mTimerView.onStop();
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
        return [new YokohamaCivicJrYachtTimerView(), new YokohamaCivicJrYachtTimerDelegate()] as Array<Views or InputDelegates>;
    }
}

function getApp() as YokohamaCivicJrYachtTimerApp {
    return Application.getApp() as YokohamaCivicJrYachtTimerApp;
}
