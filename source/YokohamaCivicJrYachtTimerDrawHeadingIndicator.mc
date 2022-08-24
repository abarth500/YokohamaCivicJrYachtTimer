import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.System;
import Toybox.Application;
/*
    <drawable id="headingIndicator" class="DrawHeadingIndicator">
        <param name="headX">-40</param>
        <param name="headY">70</param>
        <param name="radius">20</param>
        <param name="bold">20</param>
        <param name="font">Graphics.FONT_SYSTEM_XTINY</param>
    </drawable>
*/

class DrawHeadingIndicator extends WatchUi.Drawable {
    private var _x, _y, _radius, _bold, _font, _foregroundStr, _foregroundArc, _background;

    public function initialize(params as Dictionary) {
        Drawable.initialize(params);
        //System.println(params.keys()[]);
        _x = params.get(:headX);
        _y = params.get(:headY);
        _radius = params.get(:radius);
        _bold = params.get(:bold);
        _font = params.get(:font);
        _foregroundStr = params.get(:foregroundStr);
        _foregroundArc = params.get(:foregroundArc);
        _background = params.get(:background);
    }
    function draw(dc as Dc) as Void {
        //System.println("draw");
        _x = _x < 0 ? dc.getWidth() + _x : _x;
        _y = _y < 0 ? dc.getHeight() + _y : _y;
        var heading = Application.Properties.getValue("GPSLastHeading");
        var degree = [0, 22.5, 45, 67.5, 90, 112.5, 135, 157.5, 180, -22.5, -45, -67.5, -90, -112.5, -135, -157.5, -180];
        var labels = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "NNW", "NW", "WNW", "W", "WSW", "SW", "SSW", "S"];
        var min = 181;
        var label = "O";
        for (var i = 0; i < degree.size(); i += 1) {
            if ((degree[i] - heading).abs() < min) {
                label = labels[i];
                min = (degree[i] - heading).abs();
            }
        }
        dc.setColor(_foregroundArc, _background);
        dc.setPenWidth(_bold);
        dc.drawArc(_x, _y, _radius, Graphics.ARC_CLOCKWISE, heading + 100, heading + 80);
        dc.setPenWidth(1);
        dc.drawArc(_x, _y, _radius, Graphics.ARC_COUNTER_CLOCKWISE, heading + 100, heading + 80);
        dc.setColor(_foregroundStr, _background);
        dc.drawText(_x, _y, _font, label, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}
