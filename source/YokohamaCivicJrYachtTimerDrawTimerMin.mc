import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.System;
import Toybox.Application;
/*
    <drawable id="TimerMin" class="DrawTimerMin">
        <param name="x">60</param>
        <param name="y">30</param>
        <param name="minFont">Graphics.FONT_SYSTEM_NUMBER_THAI_HOT</param>
        <param name="minAlign">Graphics.TEXT_JUSTIFY_LEFT</param>
        <param name="xGap">5</param>
        <param name="unitStr">min.</param>
        <param name="unitS">m</param>
        <param name="unitFont">Graphics.FONT_MEDIUM</param>
        <param name="unitAlign">Graphics.TEXT_JUSTIFY_LEFT</param>
        <param name="foreground">Graphics.COLOR_WHITE</param>
        <param name="background">Graphics.COLOR_TRANSPARENT</param>
    </drawable>
    <properties>
        <property id="timerSecRace" type="number">0</property>
    </properties>
*/

class DrawTimerMin extends WatchUi.Drawable {
    private var _x, _y, _minFont, _minAlign, _xGap, _unitStr_Race, _unitS_Race, _unitStr_Practice, _unitS_Practice, _unitFont, _unitAlign, _foreground, _background;

    public function initialize(params as Dictionary) {
        Drawable.initialize(params);
        //System.println(params.keys()[]);
        _x = params.get(:baseX);
        _y = params.get(:baseY);
        _minFont = params.get(:minFont);
        _minAlign = params.get(:minAlign);
        _xGap = params.get(:xGap);
        _unitStr_Race = params.get(:unitStr);
        _unitS_Race = params.get(:unitS);
        _unitStr_Practice = params.get(:unitStr_Practice);
        _unitS_Practice = params.get(:unitS_Practice);
        _unitFont = params.get(:unitFont);
        _unitAlign = params.get(:unitAlign);
        _foreground = params.get(:foreground);
        _background = params.get(:background);
    }
    function draw(dc as Dc) as Void {
        //System.println("draw");
        var _unitStr, _unitS;
        var min = Application.Properties.getValue("timerSec" + (Application.Properties.getValue("menuModeRace") ? "Race" : "Practice"));
        if (!Application.Properties.getValue("menuModeRace") and Application.Properties.getValue("timerStatus") == CONSTANT.STATUS_CONFIG) {
            _unitStr = _unitStr_Practice;
            _unitS = _unitS_Practice;
        } else {
            _unitStr = _unitStr_Race;
            _unitS = _unitS_Race;
        }
        var fontHeightGap = dc.getFontHeight(_minFont) - dc.getFontHeight(_unitFont);
        var unitLong = dc.getTextWidthInPixels(_unitStr, _unitFont);
        var unitShort = dc.getTextWidthInPixels(_unitS, _unitFont);
        var unit = _unitStr;
        var x = _x;
        if (min > 999) {
            min = "M";
            unit = "AX";
        } else if (min > 99) {
            unit = _unitS;
            x += unitLong - unitShort;
        } else if (min > 9) {
            x += _xGap - 1;
            _xGap = 1;
        }
        dc.setColor(_foreground, _background);
        dc.drawText(x, _y, _minFont, min, _minAlign);
        dc.drawText(x + _xGap, _y + fontHeightGap, _unitFont, unit, _unitAlign);
    }
}
