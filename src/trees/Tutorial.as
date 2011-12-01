package trees {
import flare.animate.Transitioner;
import flare.data.DataSet;
import flare.data.DataSource;
import flare.display.TextSprite;
import flare.scale.ScaleType;
import flare.util.palette.ColorPalette;
import flare.vis.Visualization;
import flare.vis.data.Data;
import flare.vis.operator.encoder.ColorEncoder;
import flare.vis.operator.encoder.ShapeEncoder;
import flare.vis.operator.layout.AxisLayout;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.net.URLLoader;

[SWF(width="800", height="600", backgroundColor="#ffffff", frameRate="30")]
public class Tutorial extends Sprite {

    private var vis:Visualization;

    public function Tutorial() {
        var button:TextSprite = new TextSprite("Color by Gender");
        addChild(button);
        button.x = 710;
        button.y = 50;
        button.buttonMode = true;
        button.addEventListener(MouseEvent.CLICK,
                function(evt:MouseEvent):void {
                    colorByGender();
                }
        );

        loadData();
    }

    private function loadData():void {
//        var ds:DataSource = new DataSource("file:///path/to/homicides.tab.txt", "tab");
        var ds:DataSource = new DataSource("http://flare.prefuse.org/data/homicides.tab.txt", "tab");
        var loader:URLLoader = ds.load();
        loader.addEventListener(Event.COMPLETE, function(evt:Event):void {
            var ds:DataSet = loader.data as DataSet;
            visualize(Data.fromDataSet(ds));
        });
    }

    private function visualize(data:Data):void {
        vis = new Visualization(data);
        vis.bounds = new Rectangle(0, 0, 600, 500);
        vis.x = 100;
        vis.y = 50;
        addChild(vis);

        vis.operators.add(new AxisLayout("data.date", "data.age"));
        vis.operators.add(new ColorEncoder("data.cause", Data.NODES, "lineColor", ScaleType.CATEGORIES));
        vis.operators.add(new ShapeEncoder("data.race"));
        vis.data.nodes.setProperties({fillColor:0, lineWidth:2});
        vis.update();
    }

    private function colorByGender():void {
        var color:ColorEncoder = ColorEncoder(vis.operators[1]);
        color.source = "data.sex";
        color.palette = new ColorPalette([0xffff5555, 0xff8888ff]);
        vis.update(new Transitioner(2)).play();
    }
}
}