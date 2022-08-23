import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.System;
import Toybox.Application;
import Toybox.Position;
/*
    <drawable id="positionIndicator" class="DrawPositionIndicator">
        <param name="posX">5</param>
        <param name="posY">20</param>
        <param name="font">Graphics.FONT_SYSTEM_XTINY</param>
        <param name="align">Graphics.TEXT_JUSTIFY_LEFT</param>
        <param name="foreground">Graphics.COLOR_WHITE</param>
        <param name="background">Graphics.COLOR_TRANSPARENT</param>
    </drawable>
*/

class DrawPositionIndicator extends WatchUi.Drawable {
    private var _posX, _posY, _font, _align, _foreground, _background;

    public function initialize(params as Dictionary) {
        Drawable.initialize(params);
        //System.println(params.keys()[]);
        _posX = params.get(:posX);
        _posY = params.get(:posY);
        _font = params.get(:font);
        _align = params.get(:align);
        _foreground = params.get(:foreground);
        _background = params.get(:background);
    }
    function draw(dc as Dc) as Void {
        //System.println("draw StatusIcon");
        dc.setColor(_foreground, _background);
        var str;
        switch (Application.Properties.getValue("timerStatus")) {
            case Position.QUALITY_NOT_AVAILABLE:
            case Position.QUALITY_LAST_KNOWN:
                str = Rez.Strings.PositionIndicatorDefault;
                break;
            default:
                str = Application.Properties.getValue("GPSLastLatitude").format("%+3.5f") +"/"+Application.Properties.getValue("GPSLastLongitude").format("%+3.5f");
        }
        dc.drawText(_posX, _posY, _font, str, _align);
    }
}
