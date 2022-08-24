import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.System;
import Toybox.Application;
/*
    <drawable id="speedIndicator" class="DrawSpeedIndicator">
        <param name="speedX">70</param>
        <param name="speedY">60</param>
        <param name="speedFont">Graphics.FONT_SYSTEM_NUMBER_THAI_HOT</param>
        <param name="speedAlign">Graphics.TEXT_JUSTIFY_RIGHT</param>
        <param name="xGap">3</param>
        <param name="unitStr">"kt"</param>
        <param name="unitFont">Graphics.FONT_MEDIUM</param>
        <param name="unitAlign">Graphics.TEXT_JUSTIFY_LEFT</param>
        <param name="foreground">Graphics.COLOR_WHITE</param>
        <param name="background">Graphics.COLOR_TRANSPARENT</param>
    </drawable>
    <properties>
        <property id="GPSLastHeading" type="float">0.0</property>
        <property id="GPSLastSpeed" type="float">0.0</property>
    </properties>
*/

class DrawSpeedIndicator extends WatchUi.Drawable {
    private var _x, _y, _speedFont, _speedAlign, _xGap, _unitStr, _unitFont, _unitAlign, _foreground, _background;

    public function initialize(params as Dictionary) {
        Drawable.initialize(params);
        //System.println(params.keys()[]);
        _x = params.get(:speedX);
        _y = params.get(:speedY);
        _speedFont = params.get(:speedFont);
        _speedAlign = params.get(:speedAlign);
        _xGap = params.get(:xGap);
        _unitStr = params.get(:unitStr);
        _unitFont = params.get(:unitFont);
        _unitAlign = params.get(:unitAlign);
        _foreground = params.get(:foreground);
        _background = params.get(:background);
    }
    function draw(dc as Dc) as Void {
        //System.println("draw");
        var speed = Application.Properties.getValue("GPSLastSpeed").format("%2.2f");
        //var heading = Application.Properties.getValue("GPSLastHeading").format("%2.2f");
        var fontHeightGap = dc.getFontHeight(_speedFont) - dc.getFontHeight(_unitFont);
        var unitLong = dc.getTextWidthInPixels(_unitStr, _unitFont);
        dc.setColor(_foreground, _background);
        dc.drawText(_x, _y, _speedFont, speed, _speedAlign);
        dc.drawText(_x + _xGap, _y + fontHeightGap, _unitFont, _unitStr, _unitAlign);
        //dc.drawText(_x + _xGap, _y + fontHeightGap + fontHeightGap, _unitFont, heading, _unitAlign);
    }
}
