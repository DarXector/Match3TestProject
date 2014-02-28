package utils
{
/**
 * Game Constants
 * @author Marko Ristic
 */

import flash.geom.Point;

    public class Constants
    {
        public static const BOARD_POSITION:Point = new Point(50, 50); // Top left corner of the board
        public static const BOARD_WIDTH:int = 8; // Size of board in cells
        public static const BOARD_HEIGHT:int = 8;
        public static const BOARD_CELL_WIDTH:int = 48; // Size of a single cell (square) in pixels
        public static const COLOR_VARIANTS:int = 5; // Number of different elements
        public static const GAME_TIME:int = 60000; // Game time in mmiliseconds.
        public static const ANIMATION_MOVEMENT_SPEED:int = 8; // Elements animation time
        public static const TICK_CONST:Number = 1/60; // Game update frequency
    }
}