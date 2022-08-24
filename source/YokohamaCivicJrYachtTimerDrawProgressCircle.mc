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

class DrawProgressCircle extends WatchUi.Drawable {
    private var _centerX = -27,
        _centerY = 27,
        _radius = 20,
        _bold = 15,
        _clock = Graphics.ARC_COUNTER_CLOCKWISE,
        _start = 90,
        _font = Graphics.FONT_SMALL,
        _foreground = Graphics.COLOR_WHITE,
        _background = Graphics.COLOR_TRANSPARENT;

    public function initialize(params as Dictionary) {
        Drawable.initialize(params);
        //System.println(params.keys()[]);
        _centerX = params.get(:centerX);
        _centerY = params.get(:centerY);
        _radius = params.get(:radius);
        _bold = params.get(:bold);
        _clock = params.get(:clock);
        _start = params.get(:start);
        _font = params.get(:font);
        _foreground = params.get(:foreground);
        _background = params.get(:background);
        
    }
    function draw(dc as Dc) as Void {
        //System.println("draw");
        var degree = Application.Properties.getValue("progressCircleDegree");
        var str = Application.Properties.getValue("progressCircleStr");
        dc.setColor(_foreground, _background);
        dc.setPenWidth(_bold);
        dc.drawArc(_centerX, _centerY, _radius, _clock, _start, -1 * degree + _start);
        //秒表示
        dc.drawText(_centerX, _centerY, _font, str, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}
