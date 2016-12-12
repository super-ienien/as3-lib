﻿package caspar.mixer {
	
	import caspar.cg.CasparChannel;
	import caspar.network.ServerConnection;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;
	
	public class Window {

		public var channel: CasparChannel
		public var cg:ServerConnection;

		public var rect:Rectangle;
		public var cgRect:Rectangle;
		public var ratio:Number;
		public var initialLayer:int;
		public var nextUpperLayer:int;
		public var nextLowerLayer:int;
		public var layers:Object = {};
		public var visible:Boolean;
		
		public static function _getNextLayer():int
		{
			var l = Window._nextLayer;
			Window._nextLayer += 50;
			return l;
		}

		private static var _nextLayer = 1020;
		
		public function Window(channel:CasparChannel, layer:int = -1)
		{
			this.rect = new Rectangle();
			this.cgRect = new Rectangle();
			this.channel = channel;
			this.cg = channel.cg;
			this.nextUpperLayer = layer > -1 ? layer-1:Window._getNextLayer()-1;
			this.nextLowerLayer = this.nextUpperLayer;
		}

		public function init(deferred:Boolean = false)
		{
			this.rect = new Rectangle();
			this.cgRect = new Rectangle();
			this.visible = false;
			this.setTo(0, 0, 0, 0);
			this.send(deferred);
			return this;
		}
		
		public function addLayer(name:String, type:String, upper:Boolean = true, external:Boolean = false, align:String = ''):WindowLayer
		{
			if (this.layers[name]) return this.layers[name];
			var layerId = upper ? this.nextUpperLayer++:this.nextLowerLayer--;
			var layer = new WindowLayer(this, layerId, type, external, align);
			this.layers[name] = layer;
			return layer;
		}
		
		public function layer(name:String):WindowLayer
		{
			return this.layers[name];
		}
		
		public function setVisible(value:Boolean)
		{
			for (var i in this.layers)
			{
				this.layers[i].setVisible(value);
			}
		}
		
		public function scaleX(x:int):Window
		{
			this.setTo(this.rect.x, this.rect.y, x, x/this.ratio);
			return this;
		}
				
		public function scaleY(y:int):Window
		{
			this.setTo(this.rect.x, this.rect.y, y*this.ratio, y);
			return this;
		}
		
		public function resize(width:int, height:int):Window
		{
			this.setTo(this.rect.x, this.rect.y, width, height);
			return this;
		}
		
		public function moveTo(x:int, y:int = 0):Window
		{
			this.setTo(x, y, this.rect.width, this.rect.height);
			return this;
		}
		
		public function translate(x:int, y:int = 0):Window
		{
			this.setTo(this.rect.x+x, this.rect.y+y, this.rect.width, this.rect.height);
			return this;
		}
				
		public function setTo(x:int, y:int, width:int, height:int):Window
		{
			trace(0);
			this.rect.width = width;
			this.rect.height = height;
			this.rect.x = x;
			this.rect.y = y;
			trace(1);
			this.ratio = width/height;
			this.cgRect.width = this.channel.coord.width(width);
			this.cgRect.height = this.channel.coord.height(height);
			this.cgRect.x = this.channel.coord.x(x);
			this.cgRect.y = this.channel.coord.y(y);
			trace(2);

			for (var i in this.layers)
			{
				this.layers[i].calculate();
			}
			
			return this;
		}

		public function clear()
		{
			this.init();
		}
		
		public function send(deferred: Boolean = false, duration: int = 0, ease: String = '')
		{
			for (var i in this.layers)
			{
				this.layers[i].send(true, duration, ease);
			}
			if (!deferred)
			{
				this.cg.MixerCommit(this.channel.id);
			}
			return this;
		}
	}
}