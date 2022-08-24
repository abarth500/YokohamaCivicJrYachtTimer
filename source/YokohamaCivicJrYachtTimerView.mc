import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Timer;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Math;
import Toybox.Position;
import Toybox.Application;
import Toybox.Application.Storage;
import Toybox.ActivityRecording;
import Toybox.FitContributor;
import Toybox.Attention;

class YokohamaCivicJrYachtTimerView extends WatchUi.View {
    private var session = null;
    private var adjuster = -1;
    private var mainTimer, adjusterTimer;
    private var nowTime;
    private var startTime;
    //private var current_precount;
    private var headingBin = CONSTANT.DEGREE_BIN_WIDTH;
    private var myTime;
    private var vibeProfiles;
    private var fieldID = 0;
    private var preStartVibeAlert = {
        "Long" => [],
        "Short" => [],
        "Last" => [],
    };
    function initialize() {
        System.println("Init View");
        View.initialize();
        //current_precount = 300;
        //Application.Properties.getValue("appPreStartSeconds");
        mainTimer = new Timer.Timer();
        adjusterTimer = new Timer.Timer();
        Storage.clearValues();
        Application.Properties.setValue("progressCircleDegree", 0);
        Application.Properties.setValue("progressCircleStr", "D");
        Application.Properties.setValue("timerMinMin", 0);
        Application.Properties.setValue("timerStatus", 0);
        Application.Properties.setValue("GPSLastLatitude", 0.0);
        Application.Properties.setValue("GPSLastLongitude", 0.0);
        Application.Properties.setValue("GPSLastHeading", 0.0);
        Application.Properties.setValue("GPSLastSpeed", 0.0);
        Application.Properties.setValue("GPSLastAccuracy", 0);
        Application.Properties.setValue("TimeRecordBEST", 0);
        Application.Properties.setValue("TimeRecordLAST", 0);
        if (Attention has :vibrate) {
            //バイブ機能があれば
            var _appPreStartVibeAlertLong = Application.Properties.getValue("appPreStartVibeAlertLong");
            var mae = 0;
            for (var ushiro = _appPreStartVibeAlertLong.find(","); ushiro != null; ushiro = _appPreStartVibeAlertLong.find(",")) {
                var val = _appPreStartVibeAlertLong.substring(mae, ushiro);
                //System.println(mae + " > " + ushiro + " : " + val + " (" + val.toNumber() + ")");
                _appPreStartVibeAlertLong = _appPreStartVibeAlertLong.substring(ushiro + 1, _appPreStartVibeAlertLong.length());
                preStartVibeAlert["Long"].add(val.toNumber());
            }
            preStartVibeAlert["Long"].add(_appPreStartVibeAlertLong.toNumber());
            var _appPreStartVibeAlertShort = Application.Properties.getValue("appPreStartVibeAlertShort");
            mae = 0;
            for (var ushiro = _appPreStartVibeAlertShort.find(","); ushiro != null; ushiro = _appPreStartVibeAlertShort.find(",")) {
                var val = _appPreStartVibeAlertShort.substring(mae, ushiro);
                //System.println(mae + " > " + ushiro + " : " + val + " (" + val.toNumber() + ")");
                _appPreStartVibeAlertShort = _appPreStartVibeAlertShort.substring(ushiro + 1, _appPreStartVibeAlertShort.length());
                preStartVibeAlert["Short"].add(val.toNumber());
            }
            preStartVibeAlert["Short"].add(_appPreStartVibeAlertShort.toNumber());
            var _appPreStartVibeAlertLast = Application.Properties.getValue("appPreStartVibeAlertLast");
            mae = 0;
            for (var ushiro = _appPreStartVibeAlertLast.find(","); ushiro != null; ushiro = _appPreStartVibeAlertLast.find(",")) {
                var val = _appPreStartVibeAlertLast.substring(mae, ushiro);
                //System.println(mae + " > " + ushiro + " : " + val + " (" + val.toNumber() + ")");
                _appPreStartVibeAlertLast = _appPreStartVibeAlertLast.substring(ushiro + 1, _appPreStartVibeAlertLast.length());
                preStartVibeAlert["Last"].add(val.toNumber());
            }
            preStartVibeAlert["Last"].add(_appPreStartVibeAlertLast.toNumber());
            vibeProfiles = {
                "Long" => [new Attention.VibeProfile(50, 500), new Attention.VibeProfile(0, 500), new Attention.VibeProfile(50, 500)],
                "Short" => [new Attention.VibeProfile(100, 1000)],
                "Last" => [new Attention.VibeProfile(100, 250)],
                "start" => [new Attention.VibeProfile(100, 1500)],
                "goal" => [new Attention.VibeProfile(50, 250), new Attention.VibeProfile(0, 250), new Attention.VibeProfile(50, 250)],
                "goalBest" => [new Attention.VibeProfile(50, 250), new Attention.VibeProfile(0, 250), new Attention.VibeProfile(50, 250), new Attention.VibeProfile(0, 250), new Attention.VibeProfile(100, 1000)],
            }; //Attention.vibrate(vibeProfiles["minminutely | 1minute | lastSeconds | start | goal | goalBest"]);
        }
        var _maxSpeedHeading = [];
        for (var i = 0; i < 360 / headingBin; i += 1) {
            _maxSpeedHeading.add(0.0);
        }
        Storage.setValue("maxSpeedHeading", _maxSpeedHeading);
    }

    function timerTick() {
        nowTime = Time.now();
        yachtTimer();
        WatchUi.requestUpdate();
    }

    function timerTickAdjuster() {
        var nowSec = Time.now().value();
        if (adjuster < 0) {
            adjuster = nowSec;
        } else if (adjuster != nowSec) {
            adjusterTimer.stop();
            mainTimer.start(method(:timerTick), 1000, true);
        }
    }

    function onPosition(info as Position.Info) as Void {
        //System.println("Position " + info.position.toGeoString(Position.GEO_DM));
        var _speed = (info.speed * 3600) / 1852;
        var _heading = Math.toDegrees(info.heading);
        Application.Properties.setValue("GPSLastLatitude", info.position.toDegrees()[0]);
        Application.Properties.setValue("GPSLastLongitude", info.position.toDegrees()[1]);
        Application.Properties.setValue("GPSLastHeading", _heading);
        Application.Properties.setValue("GPSLastSpeed", _speed);
        Application.Properties.setValue("GPSLastAccuracy", info.accuracy);
        if (Application.Properties.getValue("timerStatus") == CONSTANT.STATUS_RACE) {
            //レース時のみ
            var _maxSpeedHeading = Storage.getValue("maxSpeedHeading");
            _heading = _heading < 0 ? _heading + 360 : _heading;
            _heading = _heading == 360 ? 0 : _heading;
            var bin = Math.floor(_heading / headingBin).toNumber();
            _maxSpeedHeading[bin] = _maxSpeedHeading[bin] < _speed ? _speed : _maxSpeedHeading[bin];
            Storage.setValue("maxSpeedHeading", _maxSpeedHeading);
        }
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        System.println("Layout View");
        if (Toybox has :ActivityRecording) {
            if (session != null && session.isRecording()) {
                session.stop();
                session.save();
                session = null;
            }
            session = ActivityRecording.createSession({
                :name => "Yacht Race",
                :sport => ActivityRecording.SPORT_SAILING,
                :subSport => ActivityRecording.SUB_SPORT_GENERIC,
            });
            session.start();
        }
        System.println(System.getDeviceSettings().partNumber);
        setLayout(Rez.Layouts.MainLayout(dc));
        startTime = null;
        adjusterTimer.start(method(:timerTickAdjuster), 50, true);
    }

    function onShow() as Void {}

    function updateTimerMin(min) {
        Application.Properties.setValue("timerMinMin", min);
    }
    function updateCircle(degree, str) {
        Application.Properties.setValue("progressCircleDegree", degree);
        Application.Properties.setValue("progressCircleStr", str);
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        View.onUpdate(dc);
    }
    function yachtTimer() {
        var circleDegree, circleStr, timerMin, myTime_secounds, myTime_minutes;
        if (startTime == null) {
            //セッティング
            Application.Properties.setValue("timerStatus", CONSTANT.STATUS_CONFIG);
            circleDegree = Gregorian.info(nowTime, Time.FORMAT_MEDIUM).sec * 6;
            circleStr = "D";
            timerMin = Application.Properties.getValue("appPreStartSeconds") / 60;
        } else {
            myTime = nowTime.subtract(startTime).value();
            if (myTime >= Application.Properties.getValue("appPreStartSeconds")) {
                //レース中
                if (Application.Properties.getValue("timerStatus") == CONSTANT.STATUS_WAIT) {
                    //レーススタート
                    if (Attention has :vibrate) {
                        Attention.vibrate(vibeProfiles["start"]);
                    }
                    session.addLap();
                    fieldID += 1;
                    var msg = session.createField("status", fieldID, FitContributor.DATA_TYPE_STRING, { :mesgType => FitContributor.MESG_TYPE_LAP, :count => 10 });
                    msg.setData("Start");
                }
                Application.Properties.setValue("timerStatus", CONSTANT.STATUS_RACE);
                //dc.drawBitmap(5, 20, iconRace);
                myTime_secounds = (myTime - Application.Properties.getValue("appPreStartSeconds")) % 60;
                myTime_minutes = (myTime - Application.Properties.getValue("appPreStartSeconds")) / 60;
                circleDegree = myTime_secounds * 6;
                circleStr = myTime_secounds;
                timerMin = myTime_minutes;
            } else {
                //Pre-Start
                Application.Properties.setValue("timerStatus", CONSTANT.STATUS_WAIT);
                //dc.drawBitmap(5, 20, iconWait);
                var untilStart = Application.Properties.getValue("appPreStartSeconds") - myTime;
                myTime_secounds = untilStart % 60;
                myTime_minutes = untilStart / 60;
                circleDegree = myTime_secounds * -6;
                circleStr = myTime_secounds;
                timerMin = myTime_minutes;
                var alertTypes = preStartVibeAlert.keys();
                var vibeProfile = null;
                for (var c = 0; c < alertTypes.size(); c += 1) {
                    for (var cc = 0; cc < preStartVibeAlert[alertTypes[c]].size(); cc += 1) {
                        if (preStartVibeAlert[alertTypes[c]][cc] == untilStart) {
                            vibeProfile = vibeProfiles[alertTypes[c]];
                        }
                    }
                }
                if (vibeProfile != null) {
                    Attention.vibrate(vibeProfile);
                }
            }
        }
        updateCircle(circleDegree, circleStr);
        updateTimerMin(timerMin);
    }

    function toggleTimer() {
        if (startTime == null) {
            startTime = Time.now();
        } else {
            if (Application.Properties.getValue("timerStatus") == CONSTANT.STATUS_RACE) {
                //ゴール！
                var lapTime = myTime - Application.Properties.getValue("appPreStartSeconds");
                Application.Properties.setValue("TimeRecordLAST", lapTime);
                var lapBest = Application.Properties.getValue("TimeRecordBEST");
                Application.Properties.setValue("TimeRecordBEST", lapBest > lapTime or lapBest == 0 ? lapTime : lapBest);
                if (Attention has :vibrate) {
                    Attention.vibrate(vibeProfiles[lapBest > lapTime ? "goalBest" : "goal"]);
                }
                session.addLap();
                fieldID += 1;
                var msg = session.createField("status", fieldID, FitContributor.DATA_TYPE_STRING, { :mesgType => FitContributor.MESG_TYPE_LAP, :count => 10 });
                msg.setData("Break");
            } else if (Application.Properties.getValue("timerStatus") == CONSTANT.STATUS_CONFIG) {
                //Pre Start開始
                session.addLap();
                fieldID += 1;
                var msg = session.createField("status", fieldID, FitContributor.DATA_TYPE_STRING, { :mesgType => FitContributor.MESG_TYPE_LAP, :count => 10 });
                msg.setData("Pre-Start");
            }
            startTime = null;
        }
    }

    function up() {
        if (Application.Properties.getValue("timerStatus") == CONSTANT.STATUS_CONFIG) {
            //current_precount += 60;
            Application.Properties.setValue("appPreStartSeconds", Application.Properties.getValue("appPreStartSeconds") + 60);
            WatchUi.requestUpdate();
        }
    }
    function down() {
        if (Application.Properties.getValue("timerStatus") == CONSTANT.STATUS_CONFIG) {
            //current_precount -= 60;
            Application.Properties.setValue("appPreStartSeconds", Application.Properties.getValue("appPreStartSeconds") - 60);
            WatchUi.requestUpdate();
        }
    }
    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {}
    function onStop() as Void {
        System.println("Stop Activity");
        if (Toybox has :ActivityRecording && session != null && session.isRecording()) {
            session.stop();
            session.save();
            session = null;
        }
    }
}
