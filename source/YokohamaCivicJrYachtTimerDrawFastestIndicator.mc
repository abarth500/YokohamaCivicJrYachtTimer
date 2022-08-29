import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.System;
import Toybox.Application;
import Toybox.Application.Storage;
/*
    <drawable id="speedIndicator" class="DrawSpeedIndicator">
        <param name="speedX">70</param>
        <param name="speedY">100</param>
        <param name="speedFont">Graphics.FONT_XTINY</param>
        <param name="speedAlign">Graphics.TEXT_JUSTIFY_RIGHT</param>
        <param name="xGap">3</param>
        <param name="unitStr">"kt"</param>
        <param name="unitFont">Graphics.FONT_SYSTEM_XTINY</param>
        <param name="unitAlign">Graphics.TEXT_JUSTIFY_LEFT</param>
        <param name="foreground">Graphics.COLOR_WHITE</param>
        <param name="background">Graphics.COLOR_TRANSPARENT</param>
    </drawable>
    <properties>
        <property id="GPSLastHeading" type="float">0.0</property>
        <property id="GPSLastSpeed" type="float">0.0</property>
    </properties>
*/

class DrawFastestIndicator extends WatchUi.Drawable {
    private var _x, _y, _speedFont, _speedAlign, _xGap, _unitStr, _unitFont, _unitAlign, _foreground, _background, _foregroundFastest, _backgroundFastest;

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
        _foregroundFastest = params.get(:foregroundFastest);
        _backgroundFastest = params.get(:backgroundFastest);
    }
    function draw(dc as Dc) as Void {
        //System.println("draw");
        var _speed = Application.Properties.getValue("GPSLastSpeed");
        var _heading = Application.Properties.getValue("GPSLastHeading");
        var fontHeightGap = dc.getFontHeight(_speedFont) - dc.getFontHeight(_unitFont);
        var unitLong = dc.getTextWidthInPixels(_unitStr, _unitFont);
        var _maxSpeedHeading = Storage.getValue("maxSpeedHeading");
        _heading = _heading < 0 ? _heading + 360 : _heading;
        _heading = _heading == 360 ? 0 : _heading;
        var bin = Math.floor(_heading / CONSTANT.DEGREE_BIN_WIDTH).toNumber();
        var binm = bin - 1 < 0 ? _maxSpeedHeading.size() - 1 : bin - 1;
        var binp = bin + 1 >= _maxSpeedHeading.size() ? 0 : bin + 1;
        var fastest = _maxSpeedHeading[bin] < _maxSpeedHeading[binm] ? _maxSpeedHeading[binm] : _maxSpeedHeading[bin];
        fastest = fastest < _maxSpeedHeading[binp] ? _maxSpeedHeading[binp] : fastest;
        var delta = _speed == fastest ? "FASTEST" : (_speed - fastest).format("%2.2f");
        if (Application.Properties.getValue("timerStatus") != CONSTANT.STATUS_STARTED) {
            delta = "PAUSE";
        }
        if (_speed == fastest) {
            dc.setColor(_foregroundFastest, _backgroundFastest);
        } else {
            dc.setColor(_foreground, _background);
        }
        dc.drawText(_x, _y, _speedFont, "F=" + fastest.format("%2.2f"), _speedAlign);
        dc.drawText(_x + _xGap, _y + fontHeightGap, _unitFont, _unitStr + " (" + delta + ")", _unitAlign);
        //dc.drawText(_x + _xGap, _y + fontHeightGap + fontHeightGap, _unitFont, heading, _unitAlign);
    }
}
