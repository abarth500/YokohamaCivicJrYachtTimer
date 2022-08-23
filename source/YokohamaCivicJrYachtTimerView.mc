import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Timer;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Math;
import Toybox.Position;
import Toybox.Application;

var mainTimer, adjusterTimer;

var nowTime;
var startTime;

var indicatorSecounds_centerX;
var indicatorSecounds_centerY;
var indicatorSecounds_radius;
var indicatorSecounds_bold;
//const STATUS_CONFIG = -1;
//const STATUS_WAIT = 0;
//const STATUS_RACE = 1;

var current_precount;

class YokohamaCivicJrYachtTimerView extends WatchUi.View {
    private var adjuster = -1;
    function initialize() {
        System.println("Init View");
        View.initialize();
        current_precount = 300;

        mainTimer = new Timer.Timer();
        adjusterTimer = new Timer.Timer();
    }

    function timerTick() {
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
        Application.Properties.setValue("GPSLastLatitude", info.position.toDegrees()[0]);
        Application.Properties.setValue("GPSLastLongitude", info.position.toDegrees()[1]);
        Application.Properties.setValue("GPSLastHeading", info.heading);
        Application.Properties.setValue("GPSLastSpeed", (info.speed * 3600) / 1852);
        Application.Properties.setValue("GPSLastAccuracy", info.accuracy);
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        System.println("Layout View");
        System.println(System.getDeviceSettings().partNumber);
        setLayout(Rez.Layouts.MainLayout(dc));
        indicatorSecounds_centerX = dc.getWidth() - 27;
        indicatorSecounds_centerY = 27;
        indicatorSecounds_radius = 20;
        indicatorSecounds_bold = 15;
        startTime = null;
        //mainTimer.start(method(:timerTick), 250, true);
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
        nowTime = Time.now();
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        yochtTimer(dc);
        View.onUpdate(dc);
    }
    function yochtTimer(dc) {
        var circleDegree, circleStr, timerMin;
        if (startTime == null) {
            //セッティング
            Application.Properties.setValue("timerStatus", CONSTANT.STATUS_CONFIG);
            circleDegree = Gregorian.info(nowTime, Time.FORMAT_MEDIUM).sec * 6;
            circleStr = "D";
            timerMin = current_precount / 60;
        } else {
            var myTime = nowTime.subtract(startTime).value();
            var myTime_secounds;
            var myTime_minutes;
            if (myTime >= current_precount) {
                //レーススタート
                Application.Properties.setValue("timerStatus", CONSTANT.STATUS_RACE);
                //dc.drawBitmap(5, 20, iconRace);
                myTime_secounds = (myTime - current_precount) % 60;
                myTime_minutes = (myTime - current_precount) / 60;
                circleDegree = myTime_secounds * 6;
                circleStr = myTime_secounds;
                timerMin = myTime_minutes;
            } else {
                //レース前
                Application.Properties.setValue("timerStatus", CONSTANT.STATUS_WAIT);
                //dc.drawBitmap(5, 20, iconWait);
                myTime_secounds = (current_precount - myTime) % 60;
                myTime_minutes = (current_precount - myTime) / 60;
                circleDegree = myTime_secounds * -6;
                circleStr = myTime_secounds;
                timerMin = myTime_minutes;
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
                //スコア記録
            }
            startTime = null;
        }
    }

    function up() {
        if (Application.Properties.getValue("timerStatus") == CONSTANT.STATUS_CONFIG) {
            current_precount += 60;
        }
    }
    function down() {
        if (Application.Properties.getValue("timerStatus") == CONSTANT.STATUS_CONFIG) {
            current_precount -= 60;
        }
    }
    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {}

    function rad(deg) {
        return (deg * Math.PI) / 180;
    }
    function hubeny(lat1, lng1, lat2, lng2) {
        //degree to radian
        lat1 = rad(lat1);
        lng1 = rad(lng1);
        lat2 = rad(lat2);
        lng2 = rad(lng2);

        // 緯度差
        var latDiff = lat1 - lat2;
        // 経度差算
        var lngDiff = lng1 - lng2;
        // 平均緯度
        var latAvg = (lat1 + lat2) / 2.0;
        // 赤道半径
        var a = 6378137.0;
        // 極半径
        var b = 6356752.314140356;
        // 第一離心率^2
        var e2 = 0.00669438002301188;
        // 赤道上の子午線曲率半径
        var a1e2 = 6335439.32708317;
        var sinLat = Math.sin(latAvg);
        var W2 = 1.0 - e2 * (sinLat * sinLat);
        // 子午線曲率半径M
        var M = a1e2 / (Math.sqrt(W2) * W2);
        // 卯酉線曲率半径
        var N = a / Math.sqrt(W2);
        var t1 = M * latDiff;
        var t2 = N * Math.cos(latAvg) * lngDiff;
        return Math.sqrt(t1 * t1 + t2 * t2);
    }
    function sphericalTrigonometry(lat1, lng1, lat2, lng2) {
        // 赤道半径
        var R = 6378137.0;
        return R * Math.acos(Math.cos(rad(lat1)) * Math.cos(rad(lat2)) * Math.cos(rad(lng2) - rad(lng1)) + Math.sin(rad(lat1)) * Math.sin(rad(lat2)));
    }
}
