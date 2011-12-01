/**
 * User: dima
 * Date: 28/11/2011
 * Time: 22:12
 */
package trees{
import com.adobe.serialization.json.JSON;

import flare.util.Shapes;
import flare.vis.Visualization;
import flare.vis.controls.ExpandControl;
import flare.vis.controls.HoverControl;
import flare.vis.controls.IControl;
import flare.vis.data.DataSprite;
import flare.vis.data.NodeSprite;
import flare.vis.data.Tree;
import flare.vis.events.SelectionEvent;
import flare.vis.operator.encoder.PropertyEncoder;
import flare.vis.operator.layout.NodeLinkTreeLayout;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.utils.Timer;

[SWF(width="800", height="600", backgroundColor="#ffffff", frameRate="30")]
public class TreeFromJson extends Sprite {
    private static const NODE_SIZE:int = 3;

    private var tree:Tree = new Tree();
    private var visualization:Visualization;

    public function TreeFromJson() {
        var timer:Timer = new Timer(1000, 0);
        timer.addEventListener(TimerEvent.TIMER, onTimer)
        timer.start()
    }

    public function initVisualization():Visualization {
        if (visualization == null) {
            var nodes:Object = {
                shape: Shapes.CIRCLE,
                fillColor: 0x88aaaaaa,
                lineColor: 0xdddddddd,
                lineWidth: 1,
                size: NODE_SIZE,
                alpha: 1,
                visible: true
            }
            var edges:Object = {
                lineColor: 0xffcccccc,
                lineWidth: 1,
                alpha: 1,
                visible: true
            }
            var ctrl:IControl = new ExpandControl(NodeSprite,
                    function():void {
                        visualization.update(1, "nodes", "main").play();
                    });

            visualization = new Visualization(tree);
//        vis.bounds = new Rectangle(0, 0, 800, 800);
//        vis.operators.add(new IndentedTreeLayout(20));
            visualization.operators.add(new NodeLinkTreeLayout("topToBottom", 20, 5, 10));
            visualization.setOperator("nodes", new PropertyEncoder(nodes, "nodes"));
            visualization.setOperator("edges", new PropertyEncoder(edges, "edges"));
            visualization.controls.add(new HoverControl(NodeSprite, HoverControl.MOVE_AND_RETURN,
                    function(e:SelectionEvent):void {
                        e.node.lineWidth = 2;
                        e.node.lineColor = 0x88ff0000;
                    },
                    function(e:SelectionEvent):void {
                        e.node.lineWidth = 1;
                        e.node.lineColor = 0xdddddddd;
                    }
            ));
            visualization.controls.add(ctrl);

            addChild(visualization);

        }
        return visualization;
    }

    private function onTimer(event:TimerEvent):void {
        loadData();
    }

    private function loadData():void {
        var loader:URLLoader = new URLLoader();
        loader.dataFormat = URLLoaderDataFormat.BINARY;
        loader.addEventListener(Event.COMPLETE, function(evt:Event):void {
            var jsonObject:Object = JSON.decode(loader.data);

            tree.clear();
            addToTree(jsonObject, null, tree);

            initVisualization();
            visualization.update();
        });
        loader.load(new URLRequest("http://localhost:8787/Users/dima/IdeaProjects/flare_try/tree.json"));
    }

    private static function addToTree(jsonObject:Object, parent:NodeSprite, tree:Tree):Tree {
        if (jsonObject == null) return null;

        var node:NodeSprite = newNode(jsonObject.value);
        if (parent == null) {
            tree.root = node;
        } else {
            tree.addChild(parent, node);
        }
        if (jsonObject.left != null) addToTree(jsonObject.left, node, tree);
        if (jsonObject.right != null) addToTree(jsonObject.right, node, tree);

        trace(jsonObject.value);

        return tree;
    }

    private static function newNode(value:Object):NodeSprite {
        var node:NodeSprite = new NodeSprite();
        node.size = NODE_SIZE;
        node.data = {value: value};
        addText(node);
        return node;
    }

    private static function addText(sprite:DataSprite):void {
        var text:TextField = new TextField();
        text.text = sprite.data.value != null ? sprite.data.value : "";
//        text.border = true;
        text.height = 15;
        text.width = text.length * 10;
        text.mouseEnabled = false;
        text.selectable = false;
        text.antiAliasType = AntiAliasType.ADVANCED;
        text.x -= 5
        text.y -= 5
        sprite.addChildAt(text, 0);
    }

}
}
