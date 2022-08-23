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
    private var _iconX, _iconY, iconConfig, iconWait, iconRace;

    public function initialize(params as Dictionary) {
        Drawable.initialize(params);
        //System.println(params.keys()[]);
        _iconX = params.get(:iconX);
        _iconY = params.get(:iconY);
        iconConfig = WatchUi.loadResource(Rez.Drawables.iconConfig);
        iconWait = WatchUi.loadResource(Rez.Drawables.iconWait);
        iconRace = WatchUi.loadResource(Rez.Drawables.iconRace);
    }
    function draw(dc as Dc) as Void {
        //System.println("draw StatusIcon");
        switch (Application.Properties.getValue("timerStatus")) {
            case CONSTANT.STATUS_CONFIG:
                dc.drawBitmap(_iconX, _iconY, iconConfig);
                break;
            case CONSTANT.STATUS_WAIT:
                dc.drawBitmap(_iconX, _iconY, iconWait);
                break;
            case CONSTANT.STATUS_RACE:
                dc.drawBitmap(_iconX, _iconY, iconRace);
                break;
        }
    }
}
