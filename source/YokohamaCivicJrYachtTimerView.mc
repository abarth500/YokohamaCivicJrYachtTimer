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
    private var initPoint = {
        "lat" => null,
        "lon" => null,
    };
    private var startLine = null;
    private var beforeStartlineLeft = null;
    private var nowStartlineLeft = null;
    private var lapStartTime = null;
    function initialize() {
        System.println("Init View");
        View.initialize();
        //current_precount = 300;
        //Application.Properties.getValue("appPreStartSecondsRace");
        mainTimer = new Timer.Timer();
        adjusterTimer = new Timer.Timer();
        Storage.clearValues();
        Application.Properties.setValue("progressCircleDegree", 0);
        Application.Properties.setValue("progressCircleStr", "D");
        Application.Properties.setValue("timerSecRace", 0);
        Application.Properties.setValue("timerStatus", -1);
        Application.Properties.setValue("GPSLastLatitude", 0.0);
        Application.Properties.setValue("GPSLastLongitude", 0.0);
        Application.Properties.setValue("GPSLastHeading", 0.0);
        Application.Properties.setValue("GPSLastSpeed", 0.0);
        Application.Properties.setValue("GPSLastAccuracy", 0);
        Application.Properties.setValue("TimeRecordRaceBEST", 0);
        Application.Properties.setValue("TimeRecordRaceLAST", 0);
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
        if (Application.Properties.getValue("timerStatus") == CONSTANT.STATUS_STARTED) {
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
        if (Application.Properties.getValue("menuModeRace")) {
            Application.Properties.setValue("timerSecRace", min);
        } else {
            Application.Properties.setValue("timerSecPractice", min);
        }
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
    function startLineLeft(p) {
        //p >= 0なら左
        // 準備の計算
        var vx1 = startLine[1]["lon"] - startLine[0]["lon"];
        var vy1 = startLine[1]["lat"] - startLine[0]["lat"];
        var vx2 = p["lon"] - startLine[0]["lon"];
        var vy2 = p["lat"] - startLine[0]["lat"];
        // 判断用の値
        var ans = vx1 * vy2 - vy1 * vx2;
        //System.println(ans);
        return ans >= 0;
    }
    function yachtTimer() {
        var circleDegree, circleStr, timerMin, myTime_secounds, myTime_minutes;
        if (startTime == null) {
            //セッティング
            Application.Properties.setValue("timerStatus", CONSTANT.STATUS_CONFIG);
            circleDegree = Gregorian.info(nowTime, Time.FORMAT_MEDIUM).sec * 6;
            circleStr = "D";
            if (Application.Properties.getValue("menuModeRace")) {
                timerMin = Application.Properties.getValue("appPreStartSecondsRace") / 60;
            } else {
                timerMin = Application.Properties.getValue("appPreStartSecondsPractice");
                initPoint["lat"] = Application.Properties.getValue("GPSLastLatitude");
                initPoint["lon"] = Application.Properties.getValue("GPSLastLongitude");
            }
        } else {
            myTime = nowTime.subtract(startTime).value();
            if (Application.Properties.getValue("menuModeRace")) {
                if (myTime >= Application.Properties.getValue("appPreStartSecondsRace")) {
                    //レース中
                    if (Application.Properties.getValue("timerStatus") == CONSTANT.STATUS_PRESTART) {
                        //レーススタート
                        if (Attention has :vibrate) {
                            Attention.vibrate(vibeProfiles["start"]);
                        }
                        session.addLap();
                        fieldID += 1;
                        var msg = session.createField("status", fieldID, FitContributor.DATA_TYPE_STRING, { :mesgType => FitContributor.MESG_TYPE_LAP, :count => 10 });
                        msg.setData("Started");
                    }
                    Application.Properties.setValue("timerStatus", CONSTANT.STATUS_STARTED);
                    //dc.drawBitmap(5, 20, iconStarted);
                    myTime_secounds = (myTime - Application.Properties.getValue("appPreStartSecondsRace")) % 60;
                    myTime_minutes = (myTime - Application.Properties.getValue("appPreStartSecondsRace")) / 60;
                    circleDegree = myTime_secounds * 6;
                    circleStr = myTime_secounds;
                    timerMin = myTime_minutes;
                } else {
                    //Pre-Start
                    Application.Properties.setValue("timerStatus", CONSTANT.STATUS_PRESTART);
                    //dc.drawBitmap(5, 20, iconPrestart);
                    var untilStart = Application.Properties.getValue("appPreStartSecondsRace") - myTime;
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
            } else {
                //Practice
                if (myTime >= Application.Properties.getValue("appPreStartSecondsPractice")) {
                    //Practice - STARERD
                    if (Application.Properties.getValue("timerStatus") == CONSTANT.STATUS_PRESTART) {
                        //START NOW
                        System.println("started:" + initPoint["lat"]);
                        if (initPoint["lat"] != null) {
                            var nowPoint = {
                                "lat" => Application.Properties.getValue("GPSLastLatitude"),
                                "lon" => Application.Properties.getValue("GPSLastLongitude"),
                            };
                            // a = (y1-y2)/(x1-x2), b = y1 - ax1
                            var a = (initPoint["lat"] - nowPoint["lat"]) / (initPoint["lon"] - nowPoint["lon"]);
                            var b = nowPoint["lat"] - a * nowPoint["lon"];
                            // _b = y - _a x
                            var _a = -1 / a;
                            var _b = nowPoint["lat"] - _a * nowPoint["lon"];
                            var orgPoint = {
                                "lat" => 0,
                                "lon" => _b,
                            };
                            startLine = [orgPoint, nowPoint];
                            System.println("startline = [[" + orgPoint["lat"] +","+ orgPoint["lon"] + "] , [" + nowPoint["lat"] + "," + nowPoint["lon"] + "]]");
                            beforeStartlineLeft = startLineLeft(initPoint);
                            nowStartlineLeft = !beforeStartlineLeft;
                            session.addLap();
                            lapStartTime = myTime;
                            Application.Properties.setValue("timerStatus", CONSTANT.STATUS_STARTED);
                            myTime_secounds = 0;
                            myTime_minutes = 0;
                            circleDegree = myTime_secounds * 6;
                            circleStr = myTime_secounds;
                            timerMin = myTime_minutes;
                        } else {
                            //GPSを補足していないので現在時刻をスタートタイムに設定し、また計測する
                            startTime = Time.now();
                            myTime_secounds = 0;
                            myTime_minutes = 0;
                            circleDegree = myTime_secounds * 6;
                            circleStr = myTime_secounds;
                            timerMin = myTime_minutes;
                        }
                    } else {
                        //レース
                        //スタートライン交差チェック(交差していたらラップ追加)
                        // lapStart
                        var nowPoint = {
                            "lat" => Application.Properties.getValue("GPSLastLatitude"),
                            "lon" => Application.Properties.getValue("GPSLastLongitude"),
                        };
                        var startlineLeft = startLineLeft(nowPoint);
                        //System.println("b:" + (beforeStartlineLeft ? "left" : "right"));
                        //System.println("0:" + (nowStartlineLeft ? "left" : "right"));
                        //System.println("1:" + (startlineLeft ? "left" : "right"));
                        //System.println((startlineLeft ? "left" : "right") + " <-> " + (beforeStartlineLeft ? "left" : "right") + " = " + (nowStartlineLeft ? "left" : "right"));
                        if (startlineLeft != beforeStartlineLeft and nowStartlineLeft == beforeStartlineLeft) {
                            //スタートライン越えなら！
                            System.println("New LAP");
                            //タイム記録(ラスト、ベスト)
                            var lapTime = myTime - lapStartTime;
                            Application.Properties.setValue("TimeRecordPracticeLAST", lapTime);
                            var lapBest = Application.Properties.getValue("TimeRecordParcticeBEST");
                            Application.Properties.setValue("TimeRecordPracticeBEST", lapBest > lapTime or lapBest == 0 ? lapTime : lapBest);
                            //バイブ
                            if (Attention has :vibrate) {
                                Attention.vibrate(vibeProfiles[lapBest > lapTime ? "goalBest" : "goal"]);
                            }
                            //ラップ追加
                            lapStartTime = myTime;
                            session.addLap();
                            fieldID += 1;
                            var msg = session.createField("status", fieldID, FitContributor.DATA_TYPE_STRING, { :mesgType => FitContributor.MESG_TYPE_LAP, :count => 10 });
                            msg.setData("New-Lap");
                        }
                        nowStartlineLeft = startLineLeft;
                        myTime_secounds = (myTime - lapStartTime) % 60;
                        myTime_minutes = (myTime - lapStartTime) / 60;
                        circleDegree = myTime_secounds * 6;
                        circleStr = myTime_secounds;
                        timerMin = myTime_minutes;
                    }
                } else {
                    //Practice - PRESTART
                    //TODO:　一秒毎バイブ
                    var untilStart = Application.Properties.getValue("appPreStartSecondsPractice") - myTime;
                    myTime_secounds = untilStart % 60;
                    myTime_minutes = untilStart / 60;
                    circleDegree = myTime_secounds * -6;
                    circleStr = myTime_secounds;
                    timerMin = myTime_minutes;
                    Application.Properties.setValue("timerStatus", CONSTANT.STATUS_PRESTART);
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
            if (Application.Properties.getValue("timerStatus") == CONSTANT.STATUS_STARTED) {
                //ゴール！
                if (Application.Properties.getValue("menuModeRace")) {
                    var lapTime = myTime - Application.Properties.getValue("appPreStartSecondsRace");
                    Application.Properties.setValue("TimeRecordRaceLAST", lapTime);
                    var lapBest = Application.Properties.getValue("TimeRecordRaceBEST");
                    Application.Properties.setValue("TimeRecordRaceBEST", lapBest > lapTime or lapBest == 0 ? lapTime : lapBest);
                    if (Attention has :vibrate) {
                        Attention.vibrate(vibeProfiles[lapBest > lapTime ? "goalBest" : "goal"]);
                    }
                } else {
                    //なにもない
                }
                session.addLap();
                fieldID += 1;
                var msg = session.createField("status", fieldID, FitContributor.DATA_TYPE_STRING, { :mesgType => FitContributor.MESG_TYPE_LAP, :count => 10 });
                msg.setData("Config");
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
            if (Application.Properties.getValue("menuModeRace")) {
                Application.Properties.setValue("appPreStartSecondsRace", Application.Properties.getValue("appPreStartSecondsRace") + 60);
            } else {
                Application.Properties.setValue("appPreStartSecondsPractice", Application.Properties.getValue("appPreStartSecondsPractice") + 1);
            }
            WatchUi.requestUpdate();
        }
    }
    function down() {
        if (Application.Properties.getValue("timerStatus") == CONSTANT.STATUS_CONFIG) {
            //current_precount -= 60;
            if (Application.Properties.getValue("menuModeRace")) {
                Application.Properties.setValue("appPreStartSecondsRace", Application.Properties.getValue("appPreStartSecondsRace") - 60);
            } else {
                Application.Properties.setValue("appPreStartSecondsPractice", Application.Properties.getValue("appPreStartSecondsPractice") - 1);
            }
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
