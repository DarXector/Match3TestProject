package 
{
    import flash.system.System;
    import flash.utils.getDefinitionByName;

    import starling.core.Starling;
    import starling.display.Image;
    import starling.display.Sprite;
import starling.text.BitmapFont;
import starling.text.TextField;
import starling.textures.Texture;
    import starling.utils.AssetManager;
import com.reesta.match3.view.Game;
    
    import utils.ProgressBar;

    public class Main extends Sprite
    {
        private var _loadingProgress:ProgressBar;
        private var _currentScene:Sprite;
        private var _bg:Image;

        private static var sAssets:AssetManager;
        
        public function Main()
        {
            Game; // in order to be able to use getDefinitionByName for dynamic screen switching
        }
        
        public function start(background:Texture, assets:AssetManager):void
        {
            sAssets = assets;
            
            // The background is passed into this method for two reasons:
            // 
            // 1) we need it right away, otherwise we have an empty frame
            // 2) the Startup class can decide on the right image, depending on the device.
            _bg = new Image(background)
            addChild(_bg);
            
            // The AssetManager contains all the raw asset data, but has not created the textures
            // yet. This takes some time (the assets might be loaded from disk or even via the
            // network), during which we display a progress indicator. 
            
            _loadingProgress = new ProgressBar(200, 20);
            _loadingProgress.x = (background.width  - _loadingProgress.width) / 2;
            _loadingProgress.y = background.height * 0.6;
            addChild(_loadingProgress);
            
            assets.loadQueue(function(ratio:Number):void
            {
                _loadingProgress.ratio = ratio;

                // a progress bar should always show the 100% for a while,
                // so we show the main menu only after a short delay. 
                
                if (ratio == 1)
                    Starling.juggler.delayCall(function():void
                    {
                        _loadingProgress.removeFromParent(true);
                        _loadingProgress = null;
                        _onLoaded();
                    }, 0.15);
            });
        }

        /**
         * Assets load complete
         */

        private function _onLoaded():void
        {
            trace('_onLoaded');
            // now would be a good time for a clean-up 
            System.pauseForGCIfCollectionImminent(0);
            System.gc();

           /* var texture:Texture = Texture.fromBitmap(new EmbeddedAssets.rumpelstiltskin());
            var xml:XML = XML(new EmbeddedAssets.rumpelstiltskin_fnt());
            TextField.registerBitmapFont(new BitmapFont(texture, xml));*/

            // removing the startup image and showing
            removeChild(_bg);
            showScene('com.reesta.match3.view.Game');
        }

        /**
         * Closing current scene
         *
         */

        private function closeScene():void
        {
            _currentScene.removeFromParent(true);
            _currentScene = null;
        }

        /**
         * Showing a new scene
         * @param	name Name of thew new scene
         */

        private function showScene(name:String):void
        {
            trace('showScene', name);
            if (_currentScene) return;
            
            var sceneClass:Class = getDefinitionByName(name) as Class;
            _currentScene = new sceneClass() as Sprite;
            addChild(_currentScene);
        }

        /**
         * Get Assets Manager
         *
         * @return AssetsManager instance
         */

        public static function get assets():AssetManager { return sAssets; }
    }
}