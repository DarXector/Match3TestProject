/**
 * Created by ReLaX on 22.2.14..
 */
package com.reesta.match3.control
{
/**
 * Main Game Controller
 * @author Marko Ristic
 */

import com.reesta.match3.view.Game;
import com.reesta.match3.model.GameModel;
import com.reesta.match3.model.ModelLocator;

import flash.utils.setInterval;
import flash.utils.clearInterval;

import starling.display.Sprite;

import utils.Constants;

public class Controller
{
    private var _gameModel:GameModel;
    private var _view:Game;
    private var _updateInterval:uint;
    private var _boardController:BoardController;

    public function Controller(view:Sprite)
    {
        _view = view as Game;
        _gameModel = ModelLocator.instance.gameModel; // get game model

        _view.onPlayButton.add(_startGame); // On user start interaction
    }

    /**
     * start the game and all logic
     *
     */

    private function _startGame():void
    {
        _view.startGame();
        _gameModel.startTimer();
        _updateInterval = setInterval(_updateGame, Constants.TICK_CONST);
        _gameModel.gameOver.add(_stopGame);

        _gameModel.canMove = false; // first it's false, elements are entering
    }

    /**
     * Update game logic
     *
     */

    private function _updateGame():void
    {
        // If the player still can't move, keep executing think()
        // until the player can move.
        if (!_gameModel.canMove)
        {
            _boardController.think();
        }
        _view.tick();
    }

    /**
     * Stop update game and game logic on game over
     *
     */

    private function _stopGame():void
    {
        _gameModel.canMove = false;
        clearInterval(_updateInterval);
    }

    public function set boardController(value:BoardController):void
    {
        _boardController = value;
    }
}
}
