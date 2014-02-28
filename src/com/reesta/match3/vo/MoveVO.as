/**
 * Created by ReLaX on 22.2.14..
 */
package com.reesta.match3.vo
{
import flash.geom.Point

/**
 * Value object for single move after two elements are selected
 * @author Marko Ristic
 */

public class MoveVO
{
    private var _action:String; // Can be 'attempt' after the selection of two elements or 'return' if there is no 3 in a row.
    private var _cell1:Point; // First selected cell of the move
    private var _cell2:Point; // Second selected cell of the move

    public function MoveVO(action: String, cell1: Point, cell2: Point)
    {
        _action = action;
        _cell1 = cell1;
        _cell2 = cell2;
    }


    public function set action(value:String):void
    {
        _action = value;
    }

    public function get action():String
    {
        return _action;
    }

    public function get cell1():Point
    {
        return _cell1;
    }

    public function get cell2():Point
    {
        return _cell2;
    }

}
}
