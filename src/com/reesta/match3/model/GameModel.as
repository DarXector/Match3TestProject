/**
 * Created by ReLaX on 22.2.14..
 */
package com.reesta.match3.model
{
/**
 * Gaame Model class.
 * @author Marko Ristic
 */


import com.reesta.match3.view.Element;
import com.reesta.match3.vo.ElementVO;
import com.reesta.match3.vo.MoveVO;

import org.osflash.signals.Signal;

import starling.textures.Texture;

import utils.Constants;

import utils.MathUtils;

import starling.events.EventDispatcher;

import flash.utils.setInterval;
import flash.utils.clearInterval;
import flash.geom.Point;

import utils.SoundManager;

public class GameModel extends EventDispatcher
{
    private var _elapsedTimer:uint;
    private var _startTime:Date;
    private var _stime:String;

    private var _score:int;
    private var _best:int;
    private var _scoresInARow:int;

    private var _canMove:Boolean;

    private var _nextMove:MoveVO;

    private var _gameOver:Signal = new Signal();
    private var _onScore:Signal = new Signal();
    private var _elementCreated:Signal = new Signal();

    private var _map:Vector.<Vector.<int>>; // a 2d Vector for storing elements data
    private var _elements:Vector.<Element>; // Vector of all elements on screen
    private var _elementsMap:Vector.<Vector.<Element>>; // a 2d Vector of references to elements

    private var _explosionConfig:XML;
    private var _explosionTexture:Texture;

    private var _soundManager:SoundManager;

    public function GameModel()
    {
        // Instantiate Explosion particle effect assets
        _explosionConfig = XML(new EmbeddedAssets.ExplosionConfig());
        _explosionTexture = Texture.fromBitmap(new EmbeddedAssets.ExplosionParticle());

        // Instantiate sound manager
        _soundManager = SoundManager.getInstance();
    }

    /**
     * Start Game timer and reset some game data
     *
     */

    public function startTimer():void
    {
        _soundManager.addSound("chit", Main.assets.getSound("chit"));
        _soundManager.addSound("sparkle", Main.assets.getSound("sparkle"));
        _score = 0;
        _startTime = new Date();
        _elapsedTimer = setInterval(_checkElapsed, 10);
    }

    /**
     * Calculate Time left
     *
     */

    private function _checkElapsed():void
    {
        var currentTime:Date = new Date();
        var time:Number = Constants.GAME_TIME - (currentTime.time - _startTime.time);
        if (time <= 0)
        {
            _gameComplete();
            return;
        }
        _stime = MathUtils.toTimeCode(time, false);
    }

    /**
     * Add score on elements matched
     *
     * @param point Position of element iniside the board
     * @param s Single row score
     */

    public function addScore(points:Vector.<Point>, s:int):void
    {
        for (var i:int = 0, l:int = points.length; i < l; i++)
        {
            _map[points[i].y][points[i].x] = 0; // reset cell in the map
        }

        _scoresInARow++; // Increase rows destroyed in one user interactions
        _score += _scoresInARow * s; // Multiply for bonus points
        if (_score > _best)
        {
            _best = _score; // Change best score if the new score is greater
        }
        _onScore.dispatch(points, _scoresInARow, s); // Dispatch score
    }

    /**
     * Time out, game over
     *
     */

    private function _gameComplete():void
    {
        clearInterval(_elapsedTimer);
        _gameOver.dispatch();
    }

    /**
     * Create a new empty board model
     *
     */

    public function newMap():void
    {
        _clearMap();

        _map = new Vector.<Vector.<int>>();
        _elements = new Vector.<Element>();
        _elementsMap = new Vector.<Vector.<Element>>();

        for (var i:int = 0; i < Constants.BOARD_HEIGHT; i++)
        {
            _map[i] = new Vector.<int>(); // new row
            _elementsMap[i] = new Vector.<Element>(); // new row

            for (var j:int = 0; j < Constants.BOARD_WIDTH; j++)
            {
                createElement(i, j, true);
            }
        }
    }

    /**
     * Create dingle element and place it in the Board model and map
     *
     * @param i column
     * @param j row
     * @param newBoard if created while populating a new board or recently emptied cells
     */

    public function createElement(i:int, j:int, newBoard:Boolean = false):void
    {
        var graphic:int = MathUtils.random(1, Constants.COLOR_VARIANTS); //random element type and graphic
        if (newBoard) _map[i].push(graphic); // populate column
        else _map[i][j] = graphic; // populate cell

        var vo:ElementVO = new ElementVO(graphic);
        vo.point = new Point(j, i); // x, y

        var elem:Element = new Element(vo);
        elem.x = j * Constants.BOARD_CELL_WIDTH;
        elem.y = 0;

        if (newBoard) _elementsMap[i].push(elem); // populate column
        else _elementsMap[i][j] = elem; // populate cell

        _elements.push(elem);

        _elementCreated.dispatch(elem); // element Created
    }

    /**
     * Clears the board model
     *
     */

    private function _clearMap():void
    {
        _map = null;
        _elementsMap = null;
        if (_elements != null)
        {
            for (var i:int = _elements.length - 1; i >= 0; i--)
            {
                _elements[i].parent.removeChild(_elements[i]);
                _elements[i] = null;
                _elements.splice(i, 1);
            }
        }
    }

    /**
     * Swap two elements on move using their board coordinates
     *
     */

    public function swapElements():void
    {
        var cell1Val:int = _map[_nextMove.cell1.y][_nextMove.cell1.x]; // [row][column]
        _map[_nextMove.cell1.y][_nextMove.cell1.x] = _map[_nextMove.cell2.y][_nextMove.cell2.x];
        _map[_nextMove.cell2.y][_nextMove.cell2.x] = cell1Val; // swap graphics in the map

        // swap elements
        var cell1Element:Element = _elementsMap[nextMove.cell1.y][nextMove.cell1.x]; // remember element
        var cell2Point:Point = new Point(_nextMove.cell2.x, _nextMove.cell2.y);

        delete _elementsMap[_nextMove.cell1.y][_nextMove.cell1.x];
        _elementsMap[_nextMove.cell1.y][_nextMove.cell1.x] = _elementsMap[_nextMove.cell2.y][_nextMove.cell2.x];
        _elementsMap[_nextMove.cell1.y][_nextMove.cell1.x].vo.point = new Point(_nextMove.cell1.x, _nextMove.cell1.y); // set new coordinates for the second element

        delete _elementsMap[_nextMove.cell2.y][_nextMove.cell2.x];
        _elementsMap[_nextMove.cell2.y][_nextMove.cell2.x] = cell1Element;
        _elementsMap[_nextMove.cell2.y][_nextMove.cell2.x].vo.point = cell2Point; // set new coordinates for the first element

        // if this is the first time this move is made, set action to return
        if (_nextMove.action == "attempt")
        {
            _nextMove.action = "return";
        } else
        {
            // if this is already a return operation
            _nextMove = null;
        }
    }

    /**
     * Play Sound FX
     *
     */

    public function playFX(id:String):void
    {
        _soundManager.playSound(id, 0.6);
        _soundManager.setVolume(id, 0.6);

    }

    public function get gameOver():Signal
    {
        return _gameOver;
    }

    public function get stime():String
    {
        return _stime;
    }

    public function get canMove():Boolean
    {
        return _canMove;
    }

    public function set canMove(value:Boolean):void
    {
        if (value) _scoresInARow = 0; // When user interaction is allowed reset bonus counter
        _canMove = value;
    }

    public function get score():int
    {
        return _score;
    }

    public function get best():int
    {
        return _best;
    }

    public function get onScore():Signal
    {
        return _onScore;
    }

    public function get map():Vector.<Vector.<int>>
    {
        return _map;
    }

    public function get elements():Vector.<Element>
    {
        return _elements;
    }

    public function get elementsMap():Vector.<Vector.<Element>>
    {
        return _elementsMap;
    }

    public function get nextMove():MoveVO
    {
        return _nextMove;
    }

    public function set nextMove(value:MoveVO):void
    {
        _nextMove = value;
    }

    public function get elementCreated():Signal
    {
        return _elementCreated;
    }

    public function get explosionConfig():XML
    {
        return _explosionConfig;
    }

    public function get explosionTexture():Texture
    {
        return _explosionTexture;
    }
}
}
