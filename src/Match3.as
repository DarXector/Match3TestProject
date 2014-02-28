package 
{
    import flash.display.Sprite;
    import flash.system.Capabilities;
    
    import starling.core.Starling;
    import starling.events.Event;
    import starling.textures.Texture;
    import starling.utils.AssetManager;
    
    // If you set this class as your 'default application', it will run without a preloader.
    // To use a preloader, see 'Demo_Web_Preloader.as'.
    
    [SWF(width="700", height="500", frameRate="60", backgroundColor="#000000")]
    public class Match3 extends Sprite
    {
        [Embed(source = "../system/startup.jpg")]
        private var _background:Class;
        
        private var _starling:Starling;
        
        public function Match3()
        {
            if (stage) _start();
            else addEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
        }
        
        private function _start():void
        {
            Starling.multitouchEnabled = false; // for Multitouch Scene
            Starling.handleLostContext = true; // required on Windows, needs more memory
            
            _starling = new Starling(Main, stage);
            _starling.simulateMultitouch = false;
            _starling.enableErrorChecking = Capabilities.isDebugger;
            _starling.start();
            
            // this event is dispatched when stage3D is set up
            _starling.addEventListener(Event.ROOT_CREATED, _onRootCreated);
        }
        
        private function _onAddedToStage(event:Object):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
            _start();
        }
        
        private function _onRootCreated(event:Event, game:Main):void
        {
            // set framerate to 30 in software mode
            if (_starling.context.driverInfo.toLowerCase().indexOf("software") != -1)
                _starling.nativeStage.frameRate = 30;
            
            // define which resources to load
            var assets:AssetManager = new AssetManager();
            assets.verbose = Capabilities.isDebugger;
            assets.enqueue(EmbeddedAssets);
            
            // background texture is embedded, because we need it right away!
            var bgTexture:Texture = Texture.fromEmbeddedAsset(_background, false);
            
            // game will first load resources, then start menu
            game.start(bgTexture, assets);
        }
    }
}