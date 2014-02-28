package com.reesta.match3.vo
{

/**
 * Value object for single element
 * @author Marko Ristic
 */

import flash.geom.Point;

import starling.display.Image;

import starling.display.Sprite;
	
	public class ElementVO
	{

        private var _point:Point; // current position of the element in the board
		private var _graphic:int; // type of the element

		public function ElementVO(graphic:int)
		{
            _graphic = graphic;
		}

        public function get graphic():int
        {
            return _graphic;
        }

        public function get point():Point
        {
            return _point;
        }

        public function set point(value:Point):void
        {
            _point = value;
        }
    }

}