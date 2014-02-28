package com.reesta.match3.control
{
/**
 * Board Controller
 * @author Marko Ristic
 */

import com.reesta.match3.model.GameModel;
import com.reesta.match3.model.ModelLocator;
import com.reesta.match3.view.Element;
import com.reesta.match3.view.Game;
import com.reesta.match3.vo.MoveVO;

import flash.geom.Point;

import utils.Constants;


public class BoardController
{
    private var _gameModel:GameModel;
    private var _game:Game;

    private var _element1:Element;

    public function BoardController(view:Game)
    {
        _gameModel = ModelLocator.instance.gameModel;
        _game = view as Game;
        _game.selectElement.add(_onSelectElement); // On
    }

    /**
     * Perform a thinking operation - check if any elements are in middle of an animation, if there are any empty cells
     * and if there are any matches and there are now pending moves.
     * If all is true Player can interact
     *
     */

    public function think():void
    {
        if (_animating() && _checkEmptyCells() && _noMatches() && _noNextMove())
        {
            _gameModel.canMove = true;
        }
    }

    /**
     * Function for animating elements falling.
     * @return true if no animation was performed.
     */

    private function _animating():Boolean
    {
        var noAnimation:Boolean = true;
        for (var i:int = _gameModel.elements.length - 1; i >= 0; i--)
        {
            var elem:Element = _gameModel.elements[i];
            // if cell is empty - remove the element
            if (_gameModel.map[elem.vo.point.y][elem.vo.point.x] == 0)
            {
                elem.parent.removeChild(elem);
                noAnimation = false;
                _gameModel.elements.splice(i, 1);
                continue;
            }

            var destX:int = elem.vo.point.x * Constants.BOARD_CELL_WIDTH;
            var destY:int = elem.vo.point.y * Constants.BOARD_CELL_WIDTH;
            if (destX > elem.x)
            {
                elem.x += Constants.ANIMATION_MOVEMENT_SPEED;
                noAnimation = false;
            }
            if (destX < elem.x)
            {
                elem.x -= Constants.ANIMATION_MOVEMENT_SPEED;
                noAnimation = false;
            }
            if (destY > elem.y)
            {
                elem.y += Constants.ANIMATION_MOVEMENT_SPEED;
                noAnimation = false;
            }
            if (destY < elem.y)
            {
                elem.y -= Constants.ANIMATION_MOVEMENT_SPEED;
                noAnimation = false;
            }
        }
        return noAnimation; // Return true if no animation was performed.
    }

    /**
     * Function for checking if there are any 3 (or more) in a row matches.
     * @return true if no matches found
     */

    private function _noMatches():Boolean
    {
        var matchingCells:int;
        var prevElem:int;
        var noMatches:Boolean = true;
        var m:int;
        var i:int;
        var j:int;
        var points: Vector.<Point>;

        // Check horizontally:

        for (i = 0; i < Constants.BOARD_HEIGHT; i++)
        {
            prevElem = _gameModel.map[i][0];
            matchingCells = 1;
            for (j = 1; j < Constants.BOARD_WIDTH; j++)
            {
                if (_gameModel.map[i][j] == prevElem && prevElem != 0 && j != Constants.BOARD_WIDTH - 1)
                {
                    matchingCells++;
                } else
                {
                    if (_gameModel.map[i][j] == prevElem && prevElem != 0 && j == Constants.BOARD_WIDTH - 1)
                    {
                        matchingCells++;
                        j++;
                    }
                    if (matchingCells >= 3)
                    {
                        // Match of 3 or more found
                        noMatches = false;
                        points = new Vector.<Point>();
                        for (m = 0; m < matchingCells; m++)
                        {
                            points.push(new Point(j - m - 1, i));
                        }
                        _onScore(points); // score for elements on these positions
                    }
                    if (j != Constants.BOARD_WIDTH)
                    {
                        prevElem = _gameModel.map[i][j];
                        matchingCells = 1;
                    }
                }
            }
        }

        // Check vertically:

        for (i = 0; i < Constants.BOARD_WIDTH; i++)
        {
            prevElem = _gameModel.map[0][i];
            matchingCells = 1;
            for (j = 1; j < Constants.BOARD_HEIGHT; j++)
            {
                if (_gameModel.map[j][i] == prevElem && prevElem != 0 && j != Constants.BOARD_HEIGHT - 1)
                {
                    matchingCells++;
                } else
                {
                    if (_gameModel.map[j][i] == prevElem && prevElem != 0 && j == Constants.BOARD_HEIGHT - 1)
                    {
                        matchingCells++;
                        j++;
                    }
                    if (matchingCells >= 3)
                    {
                        // Match of 3 or more found
                        noMatches = false;
                        points = new Vector.<Point>();
                        for (m = 0; m < matchingCells; m++)
                        {
                            points.push(new Point(i, j - m - 1));
                        }
                        _onScore(points);  // score for elements on these positions
                    }
                    if (j != Constants.BOARD_HEIGHT)
                    {
                        prevElem = _gameModel.map[j][i];
                        matchingCells = 1;
                    }
                }
            }
        }

        if (!noMatches)
        {
            _clearNextMove();
        }
        return noMatches; // Return true if no matches found
    }

    /**
     * Function for checking if there are any empty cells on the board. Spawns elements at the top if first row cells are empty, and puses them down
     * @return true if no empty cells found
     */

    private function _checkEmptyCells():Boolean
    {
        var noEmpty:Boolean = true;
        // Move columns down if there's empty space below (go from bottom)
        var i:int;
        var j:int;
        var previousEmpty:Boolean = false;
        for (j = 0; j < Constants.BOARD_WIDTH; j++)
        {
            previousEmpty = false;
            for (i = Constants.BOARD_HEIGHT - 1; i >= 0; i--)
            {
                if (_gameModel.map[i][j] == 0)
                {
                    previousEmpty = true;
                    noEmpty = false;
                    if (i == 0)
                    {
                        _gameModel.createElement(i, j, false);
                    }
                } else
                {
                    if (previousEmpty == true)
                    {
                        _gameModel.map[i + 1][j] = _gameModel.map[i][j]; // move the element down
                        _gameModel.map[i][j] = 0; // make previous cell empty
                        _gameModel.elementsMap[i + 1][j] = _gameModel.elementsMap[i][j]; // move the visual element down
                        delete(_gameModel.elementsMap[i][j]); // make previous element cell empty
                        _gameModel.elementsMap[i + 1][j].vo.point = new Point(j, i + 1); // set new coords for animation
                    }
                }
            }
        }

        return noEmpty; // Return true if no empty cells found
    }

    /**
     * Function that checks if there's no player move in queue.
     * @return true if no moves are found
     */

    private function _noNextMove():Boolean
    {
        var noMoves:Boolean = true;
        if (_gameModel.nextMove != null)
        {
            noMoves = false;
            // swap map values

            _gameModel.swapElements();
        }
        return noMoves;
    }

    /**
     * On player select element
     * @return element selected
     */

    public function _onSelectElement(element:Element):void
    {
        if (_gameModel.canMove && element)
        {
            // If the player clicks the board, and if he can make a move, then try to make a move
            _gameModel.playFX('chit'); // play select SFX
            element.select();
            if (!_element1) // no element selected before
            {
                _element1 = element;
            }
            else if (_element1) // one element already selected
            {
                // Check if the elements are next to each other
                if ((Math.abs(_element1.vo.point.x - element.vo.point.x) == 1 && Math.abs(_element1.vo.point.y - element.vo.point.y) == 0) || (Math.abs(_element1.vo.point.x - element.vo.point.x) == 0 && Math.abs(_element1.vo.point.y - element.vo.point.y) == 1))
                {
                    _gameModel.canMove = false;
                    // Two cells that need to be swapped are passed to the board's nextMove object, which is basically a queue
                    _gameModel.nextMove = new MoveVO("attempt", new Point(_element1.vo.point.x, _element1.vo.point.y), new Point(element.vo.point.x, element.vo.point.y));

                    // reset
                    _element1.deselect();
                    element.deselect();
                    _element1 = null;
                }
                // if the same cell is selected, cancel movement
                if (_element1 == element)
                {
                    element.deselect();
                    _element1 = null;
                }
            }
        }
    }

    /**
     * Use this to not attempt to return the switched cells back to their places.
     */

    private function _clearNextMove():void
    {
        _gameModel.nextMove = null;
    }

    /**
     * Performed on each row of 3 or more destroyed.
     * @param    points Coordinates of destroyed elements
     */

    private function _onScore(points:Vector.<Point>):void
    {
        _gameModel.playFX('sparkle');
        _gameModel.addScore(points, points.length * 10);
    }
}
}