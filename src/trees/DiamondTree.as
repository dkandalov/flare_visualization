/**
 * User: dima
 * Date: 28/11/2011
 * Time: 22:12
 */
package trees{
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
import flash.text.AntiAliasType;
import flash.text.TextField;

[SWF(width="800", height="600", backgroundColor="#ffffff", frameRate="30")]
public class DiamondTree extends Sprite {
    private static const NODE_SIZE:int = 3;

    private var tree:Tree = new Tree();
    private var visualization:Visualization;
    private var nodeCounter:Number = -1;

    public function DiamondTree() {
        loadData();
        initVisualization();
        visualization.update();
    }

    private function loadData():void {
        tree = diamondTree(2, 3, 4);
    }

    private function initVisualization():Visualization {
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

    public function diamondTree(b:int, d1:int, d2:int):Tree {
        var tree:Tree = new Tree();
        tree.root = newNodeWithCounter();
        var n:NodeSprite = tree.root;
        var l:NodeSprite = tree.addChild(n, newNodeWithCounter());
        var r:NodeSprite = tree.addChild(n, newNodeWithCounter());

        deepHelper(tree, l, b, d1 - 2, true);
        deepHelper(tree, r, b, d1 - 2, false);

        while (l.firstChildNode != null)
            l = l.firstChildNode;
        while (r.lastChildNode != null)
            r = r.lastChildNode;

        deepHelper(tree, l, b, d2 - 1, false);
        deepHelper(tree, r, b, d2 - 1, true);

        return tree;
    }

    private function deepHelper(t:Tree, n:NodeSprite, breadth:int, depth:int, left:Boolean):void {
        var c:NodeSprite = t.addChild(n, newNodeWithCounter());
        if (left && depth > 0)
            deepHelper(t, c, breadth, depth - 1, left);

        for (var i:uint = 1; i < breadth; ++i) {
            c = t.addChild(n, newNodeWithCounter());
        }

        if (!left && depth > 0)
            deepHelper(t, c, breadth, depth - 1, left);
    }

    private function newNodeWithCounter():NodeSprite {
        nodeCounter++;
        return newNode(nodeCounter);
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
