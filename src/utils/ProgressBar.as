package utils
{
    import flash.display.BitmapData;
    import flash.display.Shape;
    
    import starling.core.Starling;
    import starling.display.Image;
    import starling.display.Quad;
    import starling.display.Sprite;
    import starling.textures.Texture;

    public class ProgressBar extends Sprite
    {
        private var _bar:Quad;
        private var _background:Image;
        
        public function ProgressBar(width:int, height:int)
        {
            init(width, height);
        }
        
        private function init(width:int, height:int):void
        {
            var scale:Number = Starling.contentScaleFactor;
            var padding:Number = height * 0.2;
            var cornerRadius:Number = padding * scale * 2;
            
            // create black rounded box for background
            
            var bgShape:Shape = new Shape();
            bgShape.graphics.beginFill(0x0072ff, 0.5);
            bgShape.graphics.drawRoundRect(0, 0, width*scale, height*scale, cornerRadius, cornerRadius);
            bgShape.graphics.endFill();
            
            var bgBitmapData:BitmapData = new BitmapData(width*scale, height*scale, true, 0x0072ff);
            bgBitmapData.draw(bgShape);
            var bgTexture:Texture = Texture.fromBitmapData(bgBitmapData, false, false, scale);
            
            _background = new Image(bgTexture);
            addChild(_background);
            
            // create progress bar quad
            
            _bar = new Quad(width - 2*padding, height - 2*padding, 0xae003d);
            _bar.setVertexColor(2, 0xff005a);
            _bar.setVertexColor(3, 0xff005a);
            _bar.x = padding;
            _bar.y = padding;
            _bar.scaleX = 0;
            addChild(_bar);
        }
        
        public function get ratio():Number { return _bar.scaleX; }
        public function set ratio(value:Number):void 
        { 
            _bar.scaleX = Math.max(0.0, Math.min(1.0, value));
        }
    }
}