import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.System;
import Toybox.Application;
/*
    <drawable id="ProgressCircle" class="DrawProgressCircle">
        <param name="centerX">-27</param>
        <param name="centerY">27</param>
        <param name="radius">20</param>
        <param name="bold">15</param>
        <param name="clock">Graphics.ARC_COUNTER_CLOCKWISE</param>
        <param name="start">90</param>
        <param name="font">Graphics.FONT_SMALL</param>
        <param name="foreground">Graphics.COLOR_WHITE</param>
        <param name="background">Graphics.COLOR_TRANSPARENT</param>
    </drawable>
*/

class DrawStatusIcon extends WatchUi.Drawable {
    private var _iconX, _iconY, iconConfig_race, iconPrestart_race, iconStarted_race, iconConfig_practice, iconPrestart_practice, iconStarted_practice;

    public function initialize(params as Dictionary) {
        Drawable.initialize(params);
        //System.println(params.keys()[]);
        _iconX = params.get(:iconX);
        _iconY = params.get(:iconY);
        iconConfig_race = WatchUi.loadResource(Rez.Drawables.iconConfig_race);
        iconPrestart_race = WatchUi.loadResource(Rez.Drawables.iconPrestart_race);
        iconStarted_race = WatchUi.loadResource(Rez.Drawables.iconStarted_race);
        iconConfig_practice = WatchUi.loadResource(Rez.Drawables.iconConfig_practice);
        iconPrestart_practice = WatchUi.loadResource(Rez.Drawables.iconPrestart_practice);
        iconStarted_practice = WatchUi.loadResource(Rez.Drawables.iconStarted_practice);
    }
    function draw(dc as Dc) as Void {
        //System.println("draw StatusIcon");
        switch (Application.Properties.getValue("timerStatus")) {
            case CONSTANT.STATUS_CONFIG:
                dc.drawBitmap(_iconX, _iconY, Application.Properties.getValue("menuModeRace") ? iconConfig_race : iconConfig_practice);
                break;
            case CONSTANT.STATUS_PRESTART:
                dc.drawBitmap(_iconX, _iconY, Application.Properties.getValue("menuModeRace") ? iconPrestart_race : iconPrestart_practice);
                break;
            case CONSTANT.STATUS_STARTED:
                dc.drawBitmap(_iconX, _iconY, Application.Properties.getValue("menuModeRace") ? iconStarted_race : iconStarted_practice);
                break;
        }
    }
}
