package caspar.mixer {
	
	import caspar.cg.CasparChannel;
	import caspar.network.ServerConnection;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;
	
	public class Window {

		public var channel: CasparChannel

		public var rect:Rectangle;
		public var rectContent:Rectangle;
		
		private var _cgRect:Rectangle;
		
		public var mode: String = 'fill';
		
		public var cg:ServerConnection;
		
		private var sourceWidth:int;
		private var sourceHeight:int;
		
		private var ratio:Number;
		private var contentRatio:Number;
		
		public var windowContent:String;
		public var videoBorderContent:String;
		public var internalShadowContent:String;
		public var externalShadowContent:String;

		public var internalShadowSize: int;
		public var internalShadowOpacity: Number;
		
		public var externalShadowSize: int;
		public var videoBorderSize:int;
		private var _cgVideoBorderWidth:Number;
		private var _cgVideoBorderHeight:Number;

		private var _windowModified: Boolean;
		private var _windowContentModified: Boolean;
		private var _videoBorderModified: Boolean;
		private var _videoBorderContentModified: Boolean;

		private var _externalShadowModified: Boolean;
		private var _externalShadowContentModified: Boolean;
		private var _internalShadowModified: Boolean;
		private var _internalShadowContentModified: Boolean;
		private var _internalShadowOpacityModified: Boolean;

		private var _windowLayer:int;
		private var _videoBorderLayer:int;
		private var _internalShadowTopLayer:int;
		private var _internalShadowBottomLayer:int;
		private var _internalShadowLeftLayer:int;
		private var _internalShadowRightLayer:int;
		private var _externalShadowTopLayer:int;
		private var _externalShadowBottomLayer:int;
		private var _externalShadowLeftLayer:int;
		private var _externalShadowRightLayer:int;
		
		
		private var _windowFill: Rectangle;
		private var _windowCrop: Rectangle;
		private var _videoBorderFill: Rectangle;

		private var _internalShadowTopFill: Rectangle;
		private var _internalShadowRightFill: Rectangle;
		private var _internalShadowBottomFill: Rectangle;
		private var _internalShadowLeftFill: Rectangle;

		private var _externalShadowTopFill: Rectangle;
		private var _externalShadowRightFill: Rectangle;
		private var _externalShadowBottomFill: Rectangle;
		private var _externalShadowLeftFill: Rectangle;

		public static function _getNextLayer():int
		{
			return Window._nextLayer++;
		}

		private static var _nextLayer = 199;
		
		public function Window(channel:CasparChannel, sourceWidth:int, sourceHeight:int, layer:int = -1)
		{
			this.channel = channel;
			this.cg = channel.cg;
			this.sourceWidth = sourceWidth;
			this.sourceHeight = sourceHeight;
			this.contentRatio = sourceWidth/sourceHeight;
			if (layer < 0)
			{
				this._videoBorderLayer = Window._getNextLayer();
				this._windowLayer = Window._getNextLayer();
				this._internalShadowTopLayer = Window._getNextLayer();
				this._internalShadowBottomLayer = Window._getNextLayer();
				this._internalShadowLeftLayer = Window._getNextLayer();
				this._internalShadowRightLayer = Window._getNextLayer();
				this._externalShadowTopLayer = Window._getNextLayer();
				this._externalShadowBottomLayer = Window._getNextLayer();
				this._externalShadowLeftLayer = Window._getNextLayer();
				this._externalShadowRightLayer = Window._getNextLayer();				
			}
			else
			{
				layer--;
				this._videoBorderLayer = layer++;
				this._windowLayer = layer++;
				this._internalShadowTopLayer = layer++;
				this._internalShadowBottomLayer = layer++;
				this._internalShadowLeftLayer = layer++;
				this._internalShadowRightLayer = layer++;
				this._externalShadowTopLayer = layer++;
				this._externalShadowBottomLayer = layer++;
				this._externalShadowLeftLayer = layer++;
				this._externalShadowRightLayer = layer++;								
			}
		}

		public function init(deferred:Boolean = false)
		{
			this.mode = 'fill';
			
			this.rect = new Rectangle();
			this.rectContent = new Rectangle();
			this._cgRect = new Rectangle();

			this.internalShadowSize = 0;
			this.internalShadowOpacity = 1;
			
			this.externalShadowSize = 0;
			this.videoBorderSize = 0;
			this._cgVideoBorderWidth = 0;
			this._cgVideoBorderHeight = 0;

			this._windowModified = false;
			this._windowContentModified = false;
			this._videoBorderModified = false;
			this._videoBorderContentModified= false;
			this._externalShadowModified = false;
			this._externalShadowContentModified = false;
			this._internalShadowModified = false;
			this._internalShadowContentModified = false;
			this._internalShadowOpacityModified = false;
			
			this._windowFill = new Rectangle(this.channel.coord.x(0), this.channel.coord.y(0), this.channel.coord.width(0), this.channel.coord.height(0));
			this._windowCrop = new Rectangle();
			this._videoBorderFill = new Rectangle();

			this._internalShadowTopFill = new Rectangle();
			this._internalShadowRightFill = new Rectangle();
			this._internalShadowBottomFill = new Rectangle();
			this._internalShadowLeftFill = new Rectangle();

			this._externalShadowTopFill = new Rectangle();
			this._externalShadowRightFill = new Rectangle();
			this._externalShadowBottomFill = new Rectangle();
			this._externalShadowLeftFill = new Rectangle();

			this.cg.ClearMedia(this.channel.id, this._windowLayer)
			this.cg.ClearMedia(this.channel.id, this._videoBorderLayer)
			this.cg.ClearMedia(this.channel.id, this._internalShadowTopLayer)
			this.cg.ClearMedia(this.channel.id, this._internalShadowBottomLayer)
			this.cg.ClearMedia(this.channel.id, this._internalShadowLeftLayer)
			this.cg.ClearMedia(this.channel.id, this._internalShadowRightLayer)
			this.cg.ClearMedia(this.channel.id, this._externalShadowTopLayer)
			this.cg.ClearMedia(this.channel.id, this._externalShadowBottomLayer)
			this.cg.ClearMedia(this.channel.id, this._externalShadowLeftLayer)
			this.cg.ClearMedia(this.channel.id, this._externalShadowRightLayer)

			this.cg.MixerClear(this.channel.id, this._windowLayer)
			this.cg.MixerClear(this.channel.id, this._videoBorderLayer)
			this.cg.MixerClear(this.channel.id, this._internalShadowTopLayer)
			this.cg.MixerClear(this.channel.id, this._internalShadowBottomLayer)
			this.cg.MixerClear(this.channel.id, this._internalShadowLeftLayer)
			this.cg.MixerClear(this.channel.id, this._internalShadowRightLayer)
			this.cg.MixerClear(this.channel.id, this._externalShadowTopLayer)
			this.cg.MixerClear(this.channel.id, this._externalShadowBottomLayer)
			this.cg.MixerClear(this.channel.id, this._externalShadowLeftLayer)
			this.cg.MixerClear(this.channel.id, this._externalShadowRightLayer)
			
			this.cg.MixerAnchor(this.channel.id, this._windowLayer, 0.5, 0.5)
			this.cg.MixerAnchor(this.channel.id, this._videoBorderLayer, 0.5, 0.5)
			this.cg.MixerAnchor(this.channel.id, this._internalShadowTopLayer, 0.5, 0)
			this.cg.MixerAnchor(this.channel.id, this._internalShadowBottomLayer, 0.5, 1)
			this.cg.MixerAnchor(this.channel.id, this._internalShadowLeftLayer, 0, 0.5)
			this.cg.MixerAnchor(this.channel.id, this._internalShadowRightLayer, 1, 0.5)
			this.cg.MixerAnchor(this.channel.id, this._externalShadowTopLayer, 0.5, 1)
			this.cg.MixerAnchor(this.channel.id, this._externalShadowBottomLayer, 0.5, 0)
			this.cg.MixerAnchor(this.channel.id, this._externalShadowLeftLayer, 1, 0.5)
			this.cg.MixerAnchor(this.channel.id, this._externalShadowRightLayer, 0, 0.5)
			this.setTo(0, 0, 0, 0);
			this.send(deferred);
			return this;
		}
		
		public function scaleX(x:int)
		{
			this.setTo(this.rect.x, this.rect.y, x, x/this.ratio);
			return this;
		}
				
		public function scaleY(y:int)
		{
			this.setTo(this.rect.x, this.rect.y, y*this.ratio, y);
			return this;
		}

		public function scaleContentX(x:int)
		{
			this.setContentTo(this.rectContent.x, this.rectContent.y, x, x/this.contentRatio);
			return this;
		}
		
		public function scaleContentY(y:int)
		{
			this.setContentTo(this.rectContent.x, this.rectContent.y, y*this.contentRatio, y);
			return this;
		}
		
		public function setWindowContent(clipName)
		{
			this.windowContent = clipName;
			this._windowContentModified = true;
			return this;
		}

		public function setVideoBorderContent(clipName)
		{
			this.videoBorderContent = clipName;
			this._videoBorderContentModified = true;
			if (!clipName) this.setVideoBorder(0);
			return this;
		}
		
		public function setVideoBorder(size:int = 0)
		{
			this.videoBorderSize = size;
			this._cgVideoBorderWidth = this.channel.coord.width(size);
			this._cgVideoBorderHeight = this.channel.coord.height(size);
			this._calculateVideoBorder();
			this._calculateExternalShadow();
			return this;
		}
		
		public function setInternalShadow(size:int = 0)
		{
			this._internalShadowModified = true;
			this.internalShadowSize = size;
			this._calculateInternalShadow();
			return this;
		}
		
		public function setInternalShadowContent(clipName)
		{
			this.internalShadowContent = clipName;
			this._internalShadowContentModified = true;
			if (!clipName) this.setInternalShadow(0);
			return this;
		}
		
		public function setInternalShadowOpacity(opacity:Number = 0)
		{
			this._internalShadowOpacityModified = true;
			this.internalShadowOpacity = opacity;
			return this;
		}		
		
		public function setExternalShadow(size:int = 0)
		{
			this.externalShadowSize = size;
			this._externalShadowModified = true;
			this._calculateExternalShadow();
			return this;
		}				
		
		public function setExternalShadowContent(clipName)
		{
			this.externalShadowContent = clipName;
			this._externalShadowContentModified = true;
			if (!clipName) this.setExternalShadow(0);
			return this;
		}
		
		public function resize(width:int, height:int)
		{
			this.setTo(this.rect.x, this.rect.y, width, height);
			return this;
		}
		
		public function resizeContent(width:int, height:int)
		{
			this.setContentTo(this.rectContent.x, this.rectContent.y, width, height);
			return this;
		}

		public function setMode(mode:String)
		{
			this.mode = mode;
			return this;
		}
		
		public function moveTo(x:int, y:int = 0)
		{
			this.setTo(x, y, this.rect.width, this.rect.height);
			return this;
		}
		
		public function translate(x:int, y:int = 0)
		{
			this.setTo(this.rect.x+x, this.rect.y+y, this.rect.width, this.rect.height);
			return this;
		}
				
		public function moveContent(x:int, y:int)
		{
			this.setContentTo(x, y, this.rectContent.width, this.rectContent.height);
			return this;			
		}
		
		public function setTo(x:int, y:int, width:int, height:int)
		{
			this._windowModified = true;
			this.rect.width = width;
			this.rect.height = height;
			this.rect.x = x;
			this.rect.y = y;
			this.ratio = width/height;
			this._cgRect.width = this.channel.coord.width(width);
			this._cgRect.height = this.channel.coord.height(height);
			this._cgRect.x = this.channel.coord.x(x);
			this._cgRect.y = this.channel.coord.y(y);
			switch (this.mode)
			{
				case 'fill':
					this.rectContent.x = 0;
					this.rectContent.y = 0;
					this._windowFill.x = this._cgRect.x;
					this._windowFill.y = this._cgRect.y;
					if (this.contentRatio > this.ratio)
					{
						this.rectContent.width = height*this.contentRatio;
						this.rectContent.height = height;
						this._windowFill.width = this.channel.coord.width(height*this.contentRatio);
						this._windowFill.height = this._cgRect.height;
					}
					else
					{
						this.rectContent.width = width;
						this.rectContent.height = width/this.contentRatio;
						this._windowFill.width = this._cgRect.width;
						this._windowFill.height = this.channel.coord.height(width/this.contentRatio);
					}
				break;
				case 'fixed':
					
				break;
			}
			this._windowCrop.x = this._cgRect.x-(this._cgRect.width == 0 ? 0:this._cgRect.width/2);
			this._windowCrop.y = this._cgRect.y-(this._cgRect.height == 0 ? 0:this._cgRect.height/2);
			this._windowCrop.width = this._cgRect.width;
			this._windowCrop.height = this._cgRect.height;			
			this._calculateVideoBorder();
			this._calculateInternalShadow();
			this._calculateExternalShadow();
			return this;
		}
		
		public function setContentTo(x:int, y:int, width:int, height:int)
		{
			this._windowModified = true;
			this.rectContent.x = x;
			this.rectContent.y = y;
			this.rectContent.width = width;
			this.rectContent.height = height;
			this._windowFill.x = this.channel.coord.x(x+this.rect.x)
			this._windowFill.y = this.channel.coord.y(y+this.rect.y);
			this._windowFill.width = this.channel.coord.width(width);
			this._windowFill.height = this.channel.coord.height(height);
			return this;
		}
		
		public function _calculateVideoBorder()
		{
			this._videoBorderModified = true;
			
			this._videoBorderFill.width = this._cgRect.width+this._cgVideoBorderWidth*2;
			this._videoBorderFill.height = this._cgRect.height+this._cgVideoBorderHeight*2;
			this._videoBorderFill.x = this._cgRect.x;
			this._videoBorderFill.y = this._cgRect.y;
		}
		
		public function _calculateExternalShadow()
		{
			this._externalShadowModified = true;
			
			var exShadowWidth = this.channel.coord.width(this.externalShadowSize);
			var exShadowHeight = this.channel.coord.height(this.externalShadowSize);
			
			this._externalShadowTopFill.width = this._cgRect.width + this._cgVideoBorderWidth*2 + exShadowWidth*2;
			this._externalShadowTopFill.height = exShadowHeight;
			this._externalShadowTopFill.x = this._cgRect.x;
			this._externalShadowTopFill.y = this._cgRect.y - this._cgRect.height/2 - this._cgVideoBorderHeight;

			this._externalShadowBottomFill.width = this._externalShadowTopFill.width;
			this._externalShadowBottomFill.height = this._externalShadowTopFill.height;
			this._externalShadowBottomFill.x = this._cgRect.x;
			this._externalShadowBottomFill.y = this._cgRect.y + this._cgRect.height/2 + this._cgVideoBorderHeight;
			
			this._externalShadowLeftFill.width = exShadowWidth;
			this._externalShadowLeftFill.height = this._cgRect.height + this._cgVideoBorderHeight*2 + exShadowHeight*2;
			this._externalShadowLeftFill.x = this._cgRect.x - this._cgRect.width/2 - this._cgVideoBorderWidth;
			this._externalShadowLeftFill.y = this._cgRect.y;

			this._externalShadowRightFill.width = this._externalShadowLeftFill.width;
			this._externalShadowRightFill.height = this._externalShadowLeftFill.height;
			this._externalShadowRightFill.x = this._cgRect.x + this._cgRect.width/2 + this._cgVideoBorderWidth;
			this._externalShadowRightFill.y = this._cgRect.y;
		}
		
		public function _calculateInternalShadow()
		{
			this._internalShadowModified = true;
			
			this._internalShadowTopFill.width = this._cgRect.width;
			this._internalShadowTopFill.height = this.channel.coord.height(this.internalShadowSize);
			this._internalShadowTopFill.x = this._cgRect.x;
			this._internalShadowTopFill.y = this._cgRect.y - this._cgRect.height/2;

			this._internalShadowBottomFill.width = this._internalShadowTopFill.width;
			this._internalShadowBottomFill.height = this._internalShadowTopFill.height;
			this._internalShadowBottomFill.x = this._cgRect.x;
			this._internalShadowBottomFill.y = this._cgRect.y + this._cgRect.height/2;
			
			this._internalShadowLeftFill.width = this.channel.coord.width(this.internalShadowSize);
			this._internalShadowLeftFill.height = this._cgRect.height;
			this._internalShadowLeftFill.x = this._cgRect.x - this._cgRect.width/2;
			this._internalShadowLeftFill.y = this._cgRect.y;

			this._internalShadowRightFill.width = this._internalShadowLeftFill.width;
			this._internalShadowRightFill.height = this._internalShadowLeftFill.height;
			this._internalShadowRightFill.x = this._cgRect.x + this._cgRect.width/2;
			this._internalShadowRightFill.y = this._cgRect.y;
		}
		
		public function clear()
		{
			this.init();
		}
		
		public function send(deferred: Boolean = false, duration: int = 0, ease: String = '')
		{
			if (this._windowContentModified)
			{
				if (this.windowContent == '')
				{
					//setTimeout(this.channel.clear, duration, this._videoBorderLayer);
				}
				else
				{
					this.cg.LoadMedia(this.channel.id, this._windowLayer, this.windowContent, true);
					this.cg.PlayMedia(this.channel.id, this._windowLayer);
				}
				this._windowContentModified = false;				
			}
			if (this._windowModified) {
				this.cg.MixerFill(this.channel.id, this._windowLayer, this._windowFill.x, this._windowFill.y, this._windowFill.width, this._windowFill.height, duration, ease, true);
				this.cg.MixerClip(this.channel.id, this._windowLayer, this._windowCrop.x, this._windowCrop.y, this._windowCrop.width, this._windowCrop.height, duration, ease, true);
				this._windowModified = false;
			}
			
			if (this._videoBorderModified)
			{
				this.cg.MixerFill(this.channel.id, this._videoBorderLayer, this._videoBorderFill.x, this._videoBorderFill.y, this._videoBorderFill.width, this._videoBorderFill.height, duration, ease, true);
				this._videoBorderModified = false;
			}
			
			if (this._videoBorderContentModified)
			{
				if (this.videoBorderContent == '')
				{
					//if (duration) setTimeout(this.channel.MediaClear, duration, this.channel.id, this._videoBorderLayer);
					//this.cg.MediaClear(this.channel.id, this._videoBorderLayer);
				}
				else
				{
					this.cg.LoadMedia(this.channel.id, this._videoBorderLayer, this.videoBorderContent, true);
					this.cg.PlayMedia(this.channel.id, this._videoBorderLayer);
				}
				this._videoBorderContentModified = false;
			}
			
			if (this._internalShadowModified)
			{
				this.cg.MixerFill(this.channel.id, this._internalShadowTopLayer, this._internalShadowTopFill.x, this._internalShadowTopFill.y, this._internalShadowTopFill.width, this._internalShadowTopFill.height, duration, ease, true);
				this.cg.MixerFill(this.channel.id, this._internalShadowBottomLayer, this._internalShadowBottomFill.x, this._internalShadowBottomFill.y, this._internalShadowBottomFill.width, this._internalShadowBottomFill.height, duration, ease, true);
				this.cg.MixerFill(this.channel.id, this._internalShadowRightLayer, this._internalShadowRightFill.x, this._internalShadowRightFill.y, this._internalShadowRightFill.width, this._internalShadowRightFill.height, duration, ease, true);
				this.cg.MixerFill(this.channel.id, this._internalShadowLeftLayer, this._internalShadowLeftFill.x, this._internalShadowLeftFill.y, this._internalShadowLeftFill.width, this._internalShadowLeftFill.height, duration, ease, true);
				this._internalShadowModified = false;
			}
						
			if (this._internalShadowContentModified)
			{
				if (this._internalShadowContentModified == '')
				{
					/*
					setTimeout(this.channel.clear, duration, this.channel.id, this._internalShadowTopLayer);
					setTimeout(this.channel.clear, duration, this.channel.id, this._internalShadowLeftLayer);
					setTimeout(this.channel.clear, duration, this.channel.id, this._internalShadowRightLayer);
					setTimeout(this.channel.clear, duration, this.channel.id, this._internalShadowBottomLayer);
					*/
				}
				else
				{
					this.cg.LoadMedia(this.channel.id, this._internalShadowTopLayer, this.internalShadowContent+'_top', true);
					this.cg.LoadMedia(this.channel.id, this._internalShadowLeftLayer, this.internalShadowContent+'_left', true);
					this.cg.LoadMedia(this.channel.id, this._internalShadowRightLayer, this.internalShadowContent+'_right', true);
					this.cg.LoadMedia(this.channel.id, this._internalShadowBottomLayer, this.internalShadowContent+'_bottom', true);
				}
				this._internalShadowContentModified = false;
			}

			if (this._internalShadowOpacityModified)
			{
				this.cg.MixerOpacity(this.channel.id, this._internalShadowTopLayer, this.internalShadowOpacity, duration, ease, true);
				this.cg.MixerOpacity(this.channel.id, this._internalShadowBottomLayer, this.internalShadowOpacity, duration, ease, true);
				this.cg.MixerOpacity(this.channel.id, this._internalShadowRightLayer, this.internalShadowOpacity, duration, ease, true);
				this.cg.MixerOpacity(this.channel.id, this._internalShadowLeftLayer, this.internalShadowOpacity, duration, ease, true);
			}
			
			if (this._externalShadowModified) {
				this.cg.MixerFill(this.channel.id, this._externalShadowTopLayer, this._externalShadowTopFill.x, this._externalShadowTopFill.y, this._externalShadowTopFill.width, this._externalShadowTopFill.height, duration, ease, true);
				this.cg.MixerFill(this.channel.id, this._externalShadowBottomLayer, this._externalShadowBottomFill.x, this._externalShadowBottomFill.y, this._externalShadowBottomFill.width, this._externalShadowBottomFill.height, duration, ease, true);
				this.cg.MixerFill(this.channel.id, this._externalShadowRightLayer, this._externalShadowRightFill.x, this._externalShadowRightFill.y, this._externalShadowRightFill.width, this._externalShadowRightFill.height, duration, ease, true);
				this.cg.MixerFill(this.channel.id, this._externalShadowLeftLayer, this._externalShadowLeftFill.x, this._externalShadowLeftFill.y, this._externalShadowLeftFill.width, this._externalShadowLeftFill.height, duration, ease, true);
				this._externalShadowModified = false;
			}
			
			if (this._externalShadowContentModified)
			{
				if (this._externalShadowContentModified == '')
				{
					/*
					setTimeout(this.channel.clear, duration, this.channel.id, this._externalShadowTopLayer);
					setTimeout(this.channel.clear, duration, this.channel.id, this._externalShadowLeftLayer);
					setTimeout(this.channel.clear, duration, this.channel.id, this._externalShadowRightLayer);
					setTimeout(this.channel.clear, duration, this.channel.id, this._externalShadowBottomLayer);
					*/
				}
				else
				{
					this.cg.LoadMedia(this.channel.id, this._externalShadowTopLayer, this.externalShadowContent+'_top', true);
					this.cg.LoadMedia(this.channel.id, this._externalShadowLeftLayer, this.externalShadowContent+'_left', true);
					this.cg.LoadMedia(this.channel.id, this._externalShadowRightLayer, this.externalShadowContent+'_right', true);
					this.cg.LoadMedia(this.channel.id, this._externalShadowBottomLayer, this.externalShadowContent+'_bottom', true);
				}
				this._externalShadowContentModified  = false;
			}			
			
			if (!deferred)
			{
				this.cg.MixerCommit(this.channel.id);
			}
			return this;
		}
	}
}