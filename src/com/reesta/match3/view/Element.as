package com.reesta.match3.view
{
/**
 * Element View class.
 * @author Marko Ristic
 */


import com.reesta.match3.vo.ElementVO;

import flash.geom.Point;

import starling.display.Image;

import starling.display.Sprite;

import utils.Constants;

public class Element extends Sprite
	{

    private var _image:Image; // Image of element graphic
    private var _vo:ElementVO; // Element Value Object

    public function Element(elVO:ElementVO)
    {
        _vo = elVO;

        _image = new Image(Main.assets.getTexture('ball_'+_vo.graphic));
        addChild(_image);
        useHandCursor = true; // Show hand cursor when over element

    }

    public function select():void
    {
        _image.alpha = 0.5;
    }

    public function deselect():void
    {
        _image.alpha = 1;
    }

    public function get vo():ElementVO
    {
        return _vo;
    }

    public function get image():Image
    {
        return _image;
    }
}

}