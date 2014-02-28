package com.reesta.match3.view
{

/**
 * Gaame View class.
 * @author Marko Ristic
 */

import com.reesta.match3.control.BoardController;
import com.reesta.match3.control.Controller;
import com.reesta.match3.model.GameModel;
import com.reesta.match3.model.ModelLocator;

import org.osflash.signals.Signal;

import starling.animation.Transitions;

import starling.animation.Tween;

import starling.core.Starling;

import starling.display.Button;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.text.TextField;
import starling.utils.HAlign;
import starling.utils.VAlign;

import starling.extensions.PDParticleSystem;

import flash.geom.Point;


import utils.Constants;
import utils.MathUtils;

public class Game extends Sprite
{
    private var _board:Sprite;

    private var _countDown:TextField;
    private var _score:TextField;
    private var _bestScore:TextField;
    private var _playBtn:Button;

    private var _gameModel:GameModel;
    private var _controller:Controller;
    private var _boardController:BoardController;

    private var _element1:Element;
    private var _element2:Element;

    // Signals for user interaction
    private var _onPlayButton:Signal = new Signal();
    private var _selectElement:Signal = new Signal();

    public function Game()
    {
        // Getting the instance of the GameModel
        _gameModel = ModelLocator.instance.gameModel;

        // Instantiating controller of the GameView
        _controller = new Controller(this);

        addEventListener(Event.ADDED_TO_STAGE, _init);
    }

    private function _init(evt:Event):void
    {
        removeEventListener(Event.ADDED_TO_STAGE, _init);

        addEventListener(Event.TRIGGERED, _onTrigger);

        var bg:Image = new Image(Main.assets.getTexture('bg'));
        addChild(bg);

        // Creatng and adding the timer TextField;
        _countDown = new TextField(200, 40, "00:00", 'Rumpelstiltskin', 32, 0xffcc00);
        _countDown.x = stage.stageWidth - 250;
        _countDown.y = 50;
        _countDown.hAlign = HAlign.LEFT;
        _countDown.vAlign = VAlign.CENTER;
        _countDown.visible = false;
        addChild(_countDown);

        // Creatng and adding the score TextField;
        _score = new TextField(200, 30, "0", 'Rumpelstiltskin', 24, 0xffcc00);
        _score.x = stage.stageWidth - 250;
        _score.y = _countDown.y + _countDown.height + 10;
        _score.hAlign = HAlign.LEFT;
        _score.vAlign = VAlign.CENTER;
        _score.visible = false;
        addChild(_score);

        // Creatng and adding the best score TextField;
        _bestScore = new TextField(200, 30, "0", 'Rumpelstiltskin', 24, 0xffcc00);
        _bestScore.x = stage.stageWidth - 250;
        _bestScore.y = _score.y + _score.height + 10;
        _bestScore.hAlign = HAlign.LEFT;
        _bestScore.vAlign = VAlign.CENTER;
        _bestScore.visible = false;
        addChild(_bestScore);

        // Adding the board.
        _board = new Sprite();
        _board.x = Constants.BOARD_POSITION.x;
        _board.y = Constants.BOARD_POSITION.y;
        addChild(_board);

        // Instantiating Board controller
        _boardController = new BoardController(this);

        _controller.boardController = _boardController;

        // Adding Play Button
        _playBtn = new Button(Main.assets.getTexture("play_out"), '', Main.assets.getTexture("play_over"));
        _playBtn.x = (stage.stageWidth - _playBtn.width) >> 1;
        _playBtn.y = (stage.stageHeight - _playBtn.height) >> 1;
        this.addChild(_playBtn);
    }

    /**
     * On game start hide play and show timer and score text fields
     * Add listeners for appropriate signals
     * Create A model of the board and listen for user interaction
     *
     */

    public function startGame():void
    {
        // Set up essential components for the game.
        _playBtn.visible = false;
        _bestScore.visible = true;
        _countDown.visible = true;
        _score.visible = true;
        _displayTime();
        _displayScore();
        _gameModel.gameOver.add(_stopGame);
        _gameModel.onScore.add(_onScore);
        _gameModel.elementCreated.add(_onElement);

        // Set up the board.
        _gameModel.newMap();

        addEventListener(TouchEvent.TOUCH, _onTouch);
    }

    /**
     * On element created add it to the board Sprite
     *
     */

    private function _onElement(elem:Element):void
    {
        _board.addChild(elem);
    }

    /**
     * On Game Over remove user interaction listener
     *
     */

    private function _stopGame():void
    {
        // Clean up after the game.
        _playBtn.visible = true;
        removeEventListener(TouchEvent.TOUCH, _onTouch);
    }

    /**
     * On game tick update view
     *
     */

    public function tick():void
    {
        _displayTime();
    }

    public function _displayTime():void
    {
        _countDown.text = 'TIME: ' + _gameModel.stime;
    }

    /**
     * Adding special effects for destroyed elements
     *
     * @param point Position of element iniside the board
     */

    private function _addEplosion(point:Point):void
    {
        var explosion:PDParticleSystem = new PDParticleSystem(_gameModel.explosionConfig, _gameModel.explosionTexture);
        explosion.x = 0;
        explosion.y = 0;
        explosion.addEventListener("complete", _removeParticle);
        addChild(explosion);

        // set particle emitter on position of destroyed element
        explosion.emitterX = Constants.BOARD_POSITION.x + point.x * Constants.BOARD_CELL_WIDTH + Constants.BOARD_CELL_WIDTH / 2;
        explosion.emitterY = Constants.BOARD_POSITION.y + point.y * Constants.BOARD_CELL_WIDTH + Constants.BOARD_CELL_WIDTH / 2;
        Starling.juggler.add(explosion);
        explosion.start(0.3); // Explosion lasts 0.3 seconds
    }

    /**
     * On score update view
     * Add bonus points text and animate it
     *
     * @param points Positions of all destroyed elements
     * @param inARow Number of destroyed rows in one user interactions
     * @param singleScore single row score
     */

    private function _onScore(points:Vector.<Point>, inARow:int, singleScore:int):void
    {
        for (var i:int = 0, l:int = points.length; i < l; i++)
        {
            _addEplosion(points[i]);
        }

        // Add bonus points text
        var bonusText:TextField = new TextField(200, 80, "", 'Rumpelstiltskin', 70, 0xffcc00);
        bonusText.hAlign = HAlign.CENTER;
        bonusText.vAlign = VAlign.CENTER;
        bonusText.text = inARow.toString() + 'x' + singleScore.toString();
        bonusText.x = (stage.stageWidth - bonusText.width) >> 1;
        bonusText.y = (stage.stageHeight - bonusText.height) >> 1;
        addChild(bonusText);

        // And animate it to position and fade it out
        var tween:Tween = new Tween(bonusText, 2, Transitions.EASE_OUT);
        var randY:Number = MathUtils.random(bonusText.y - 200, bonusText.y + 200);
        tween.moveTo(bonusText.x + 100, randY);
        tween.scaleTo(2);
        tween.fadeTo(0);
        tween.onCompleteArgs = [bonusText, tween];
        tween.onComplete = _onBonusTweenComplete;
        Starling.juggler.add(tween);

        _displayScore();
    }

    /**
     * Remove bonus tec instance on animation complete
     *
     * @param target
     * @param tween
     */

    private function _onBonusTweenComplete(target:TextField, tween:Tween):void
    {
        removeChild(target);
        Starling.juggler.remove(tween);
    }

    /**
     * remove particle system on emission complete
     *
     * @param event
     */

    private function _removeParticle(event:Event):void
    {
        var explosion:PDParticleSystem = event.target as PDParticleSystem;
        explosion.stop();
        Starling.juggler.remove(explosion);
        removeChild(explosion, true);
    }

    /**
     * Update score view
     *
     */
    public function _displayScore():void
    {
        _score.text = 'SCORE: ' + _gameModel.score.toString();
        _bestScore.text = 'BEST SCORE: ' + _gameModel.best.toString();
    }

    /**
     * On user interaction
     *
     * @param event
     */
    private function _onTouch(event:TouchEvent):void
    {
        var touch:Touch = event.getTouch(stage);
        if (!touch) return;

        var location:Point;

        var i:int;
        var l:int;
        var element:Element;

        switch (touch.phase)
        {
            // On begin touch if touch on element select it
            case TouchPhase.BEGAN:
                if (event.target as Image && Image(event.target).parent as Element)
                {
                    _element1 = Image(event.target).parent as Element;
                    _selectElement.dispatch(_element1);
                }

                break;
            // On end end touch if event over some other element select it
            // If the element is the same as on touch begin do nothing
            case TouchPhase.ENDED:
                location = new Point(touch.globalX, touch.globalY);

                for (i = 0, l = _gameModel.elements.length; i < l; i++)
                {
                    element = _gameModel.elements[i];
                    if (stage.hitTest(location, true) == element.image && !(_element1 && _element1 == element))
                    {
                        _element2 = element;
                        _selectElement.dispatch(_element2);
                    }
                }

                _element1 = null;
                _element2 = null;

                break;
        }

    }

    // On stage trigger check if trigger on play button
    private function _onTrigger(event:Event):void
    {
        if (event.target as Button)
        {
            var button:Button = event.target as Button;
            if (button == _playBtn)
            {
                _onPlayButton.dispatch(); // Trigger over play button
            }
        }

    }

    public function get onPlayButton():Signal
    {
        return _onPlayButton;
    }

    public function get selectElement():Signal
    {
        return _selectElement;
    }
}

}