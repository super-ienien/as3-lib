package caspar.mixer {
	import flash.geom.Rectangle;
	import caspar.cg.CasparChannel;
	import caspar.network.ServerConnection;
	
	public class WindowLayer {

		public static const CONTENT:String = 'content';
		public static const BORDER:String = 'border';
		public static const EDGE:String = 'edge';

		public static const INTERNAL_EDGE:String = 'internal_EDGE'
		public static const EXTERNAL_EDGE:String = 'external_EDGE'

		public static const TOP_ALIGN:String = 'top_align'
		public static const BOTTOM_ALIGN:String = 'bottom_align'
		public static const LEFT_ALIGN:String = 'left_align'
		public static const RIGHT_ALIGN:String = 'right_align'
		
		public static const COLOR_CONTENT:String = 'color';
		public static const CLIP_CONTENT:String = 'clip';
		public static const IMAGE_CONTENT:String = 'image';
		public static const DECKLINK_CONTENT:String = 'decklink';
		
		public static const FILL_SCALE:String = 'fill_scale'
		public static const STRETCH_SCALE:String = 'stretch_scale'
		public static const FIXED_SCALE:String = 'fixed'

		public static const RANDOM_SEEK:String = 'random_seek'
				
		public var channel:CasparChannel;
		public var cg:ServerConnection;
		
		public var rect:Rectangle;
		public var cgRect:Rectangle;
		public var rectContent:Rectangle;
		public var cgRectContent:Rectangle;
		
		public var originalContentWidth:int;
		public var originalContentHeight:int;
		public var originalContentRatio:Number;

		public var external:Boolean;
		public var align:String;

		public var delta:int;
		public var _cgDeltaWidth:Number;
		public var _cgDeltaHeight:Number;
		
		public var size:int;
		public var _cgSizeWidth:Number;
		public var _cgSizeHeight:Number;

		public var blendMode:String;

		public var opacity:int;
		public var visible:Boolean;
		
		public var clipActive:Boolean;
		public var clipRect:Rectangle;
		public var modified:Boolean;
		public var opacityModified:Boolean;
		public var blendModeModified:Boolean;
		public var contentModified:Boolean;
		public var clipModified:Boolean;

		public var visibleModified:Boolean;

		public var content:String;
		public var contentType:String;
		public var contentScale:String;
		public var contentLoop:Boolean;
		public var contentAutoPlay:Boolean;
		
		public var type:String;
		public var layerId:int;
		
		private var _winModified:Boolean;
		private var _ownModified:Boolean;
		private var _winRect:Rectangle;
		private var _ownContentModified:Boolean;
		
		private var _seekContent:int;
		
		private var _window:Window;
		
		public function window():Window
		{
			return this._window;
		}
		
		public function WindowLayer(window:Window, layerId:int, type:String, external:Boolean = false, align:String = '')
		{
			this.type = type;
			this.channel = window.channel;
			this.cg = window.channel.cg;
			this.layerId = layerId;
			this.external = external;
			this.align = align;
			this._window = window;
			this.init();
		}
		
		public function init()
		{
			this.rect = new Rectangle(this.channel.coord.x(0), this.channel.coord.y(0), this.channel.coord.width(0), this.channel.coord.height(0));
			this.cgRect = new Rectangle();
			this.cgRectContent = new Rectangle();
			this.rectContent = new Rectangle();
			this.clipRect = new Rectangle();
			this.clipActive = false;
			this.modified = false;
			this.contentModified = false;
			this.clipModified = false;
			this.opacityModified = false;
			this.visibleModified = false;
			this.blendModeModified = false;
			this.opacity = 1;
			this.visible = true;
			this.size = 0;
			this.delta = 0;
			this.contentLoop = false;
			this.contentAutoPlay = true;
			this._seekContent = -1;
			this._cgDeltaWidth = 0;
			this._cgDeltaHeight = 0;
			this._cgSizeWidth = 0;
			this._cgSizeHeight = 0;
			this.blendMode = 'Normal';
			this.cg.ClearMedia(this.channel.id, this.layerId);
			this.cg.MixerClear(this.channel.id, this.layerId);

			switch (this.type)
			{
				case WindowLayer.CONTENT:
					this.contentScale = WindowLayer.FILL_SCALE;
					this.cg.MixerAnchor(this.channel.id, this.layerId, 0.5, 0.5);
					break;
				case WindowLayer.BORDER:
					this.contentScale = WindowLayer.STRETCH_SCALE;
					this.cg.MixerAnchor(this.channel.id, this.layerId, 0.5, 0.5);
				break;
				case WindowLayer.EDGE:
					this.contentScale = WindowLayer.STRETCH_SCALE;
					switch (this.align)
					{
						case WindowLayer.TOP_ALIGN:
							this.cg.MixerAnchor(this.channel.id, this.layerId, 0.5, this.external ? 1:0);
						break;
						case WindowLayer.BOTTOM_ALIGN:
							this.cg.MixerAnchor(this.channel.id, this.layerId, 0.5, this.external ? 0:1);
						break;
						case WindowLayer.LEFT_ALIGN:
							this.cg.MixerAnchor(this.channel.id, this.layerId, this.external ? 1:0, 0.5);
						break;
						case WindowLayer.RIGHT_ALIGN:
							this.cg.MixerAnchor(this.channel.id, this.layerId, this.external ? 0:1, 0.5);
						break;
					}
				break;
			}
		}
		
		public function setContent(type:String, content:String, width:int = -1, height:int = -1):WindowLayer
		{
			this.contentModified = true;
			this.contentType = type;
			this.content = content;
			if (width > -1 || height > -1)
			{
				this.originalContentWidth = width;
				this.originalContentHeight = height;
				this.rectContent.width = width;
				this.rectContent.height = height;
				if (this.originalContentHeight) this.originalContentRatio = this.originalContentWidth/this.originalContentHeight;
			}
			return this;
		}

		public function seekContent(frame:*, ranMin:int = -1, ranMax:int = -1):WindowLayer
		{
			if (frame == WindowLayer.RANDOM_SEEK)
			{
				frame = ranMin + Math.floor( Math.random() * (ranMax+1));
			}
			this._seekContent = frame;
			return this;
		}
		
		public function setBlendMode (value:String):WindowLayer
		{
			if (this.blendMode === value) return this;
			this.blendMode = value;
			this.blendModeModified = true;
			return this;
		}

		public function setVisible (value:Boolean):WindowLayer
		{
			if (this.visible === value) return this;
			this.visible = value;
			this.visibleModified = true;
			return this;
		}
		
		public function setOpacity (value:int):WindowLayer
		{
			if (this.opacity === value) return this;
			this.opacity = value;
			this.opacityModified = true;
			return this;			
		}
		
		public function setSize (value:int):WindowLayer
		{
			if (this.size === value) return this;
			this.size = value;
			this._ownModified = true;
			this._cgSizeWidth = this.channel.coord.width(value);
			this._cgSizeHeight = this.channel.coord.height(value);			
			return this;
		}

		public function setDelta (value:int):WindowLayer
		{
			if (this.delta == value) return this;
			this.delta = this.external ? value:-value;
			this._ownModified = true;
			this._cgDeltaWidth = this.channel.coord.width(this.delta);
			this._cgDeltaHeight = this.channel.coord.height(this.delta);
			return this;
		}

		public function setContentLoop (loop:Boolean):WindowLayer
		{
			this.contentLoop = loop;
			return this;
		}		
		
		public function setContentAutoPlay (autoPlay:Boolean):WindowLayer
		{
			this.contentAutoPlay = autoPlay;
			return this;
		}

		public function contentLoad():WindowLayer
		{
			this.cg.LoadMedia(this.channel.id, this.layerId, this.content, this.contentLoop, this._seekContent);
			return this;
		}

		public function contentPlay ():WindowLayer
		{
			this.cg.PlayMedia(this.channel.id, this.layerId);
			return this;
		}

		public function setContentScaleMode (mode:String):WindowLayer
		{
			this.contentScale = mode;
			return this;
		}
		
		public function moveContent(x:int, y:int):WindowLayer
		{
			this.setContentTo(x, y, this.rectContent.width, this.rectContent.height);
			return this;
		}
		
		public function resizeContent(width:int, height:int):WindowLayer
		{
			this.setContentTo(this.rectContent.x, this.rectContent.y, width, height);
			return this;
		}

		public function scaleContentX(x:int):WindowLayer
		{
			this.setContentTo(this.rectContent.x, this.rectContent.y, x, x/this.originalContentRatio);
			return this;
		}
		
		public function scaleContentY(y:int):WindowLayer
		{
			this.setContentTo(this.rectContent.x, this.rectContent.y, y*this.originalContentRatio, y);
			return this;
		}
		
		public function setContentTo(x:int, y:int, width:int, height:int):WindowLayer
		{
			this.modified = true;
			this.rectContent.x = x;
			this.rectContent.y = y;
			this.rectContent.width = width;
			this.rectContent.height = height;
			return this;
		}

		public function calculate():WindowLayer
		{
			
			if (!this._ownModified && this._winRect && this._window.rect.equals(this._winRect)) return this;	
			
			this.modified = true;
			this._ownModified = false;
			this.clipActive = false;
			
			trace(this._window.cgRect);
			
			switch (this.type)
			{
				case WindowLayer.CONTENT:
					switch (this.contentScale)
					{
						case WindowLayer.FILL_SCALE:
							this.rectContent.x = this._window.rect.x;
							this.rectContent.y = this._window.rect.y;
							this.rect.x = this._window.cgRect.x;
							this.rect.y = this._window.cgRect.y;
							if (this.originalContentRatio > this._window.ratio)
							{
								this.rectContent.width = this._window.rect.height*this.originalContentRatio;
								this.rectContent.height = this._window.rect.height;
								this.rect.width = this.channel.coord.width(this.rectContent.width);
								this.rect.height = this._window.cgRect.height;
							}
							else if (this.originalContentRatio < this._window.ratio)
							{
								this.rectContent.width = this._window.rect.width;
								this.rectContent.height = this._window.rect.width*this.originalContentRatio;
								this.rect.width = this._window.cgRect.width;
								this.rect.height = this.channel.coord.height(this.rectContent.height);
							}
							else
							{
								if (this.clipActive)
								{
									this.clipActive = false;
									this.clipModified = true;
									this.clipRect = new Rectangle();
								}
								this.rectContent.width = this._window.rect.width;
								this.rectContent.height = this._window.rect.height;
								this.rect.width = this._window.cgRect.width;
								this.rect.height = this._window.cgRect.height;								
								break;
							}
							this.clipModified = true;
							this.clipActive = true;
							this.clipRect.x = this._window.cgRect.x-(this._window.cgRect.width == 0 ? 0:this._window.cgRect.width/2);
							this.clipRect.y = this._window.cgRect.y-(this._window.cgRect.height == 0 ? 0:this._window.cgRect.height/2);
							this.clipRect.width = this._window.cgRect.width;
							this.clipRect.height = this._window.cgRect.height;
						break;
						case WindowLayer.STRETCH_SCALE:
							if (this.clipActive)
							{
								this.clipActive = false;
								this.clipModified = true;
								this.clipRect = new Rectangle();
							}
							this.rect = this._window.cgRect.clone();
							this.rectContent = this._window.rect.clone();
						break;
						case WindowLayer.FIXED_SCALE:
							this.clipActive = true;
							this.rect.x = this.channel.coord.x(this.rectContent.x);
							this.rect.y = this.channel.coord.y(this.rectContent.y);
							this.rect.width = this.channel.coord.width(this.rectContent.width);
							this.rect.height = this.channel.coord.height(this.rectContent.height);
							this.clipRect.x = this._window.cgRect.x-(this._window.cgRect.width == 0 ? 0:this._window.cgRect.width/2);
							this.clipRect.y = this._window.cgRect.y-(this._window.cgRect.height == 0 ? 0:this._window.cgRect.height/2);
							this.clipRect.width = this._window.cgRect.width;
							this.clipRect.height = this._window.cgRect.height;
							this.clipModified = true;
						break;
					}
				break;
				
				case WindowLayer.BORDER:
					this.rect.width = this._window.cgRect.width+this._cgSizeWidth*2;
					this.rect.height = this._window.cgRect.height+this._cgSizeHeight*2;
					this.rect.x = this._window.cgRect.x;
					this.rect.y = this._window.cgRect.y;
				break;
				
				case WindowLayer.EDGE:
					switch (this.align)
					{
						case WindowLayer.TOP_ALIGN:
							this.rect.x = this._window.cgRect.x;
							this.rect.y = this._window.cgRect.y - this._window.cgRect.height/2 - this._cgDeltaHeight;
							this.rect.height = this._cgSizeHeight;
							this.rect.width = this._window.cgRect.width + this._cgDeltaWidth*2;
							if (this.external)
							{
								this.rect.width += this._cgSizeWidth*2;
							}
						break;
						case WindowLayer.BOTTOM_ALIGN:
							this.rect.x = this._window.cgRect.x;
							this.rect.y = this._window.cgRect.y + this._window.cgRect.height/2 + this._cgDeltaHeight;
							this.rect.height = this._cgSizeHeight;
							this.rect.width = this._window.cgRect.width + this._cgDeltaWidth*2;
							if (this.external)
							{
								this.rect.width += this._cgSizeWidth*2;
							}
						break;
						case WindowLayer.LEFT_ALIGN:
							this.rect.x = this._window.cgRect.x - this._window.cgRect.width/2 - this._cgDeltaWidth;
							this.rect.y = this._window.cgRect.y;
							this.rect.width = this._cgSizeWidth;
							this.rect.height = this._window.cgRect.height + this._cgDeltaHeight*2;
							if (this.external)
							{
								this.rect.height += this._cgSizeHeight*2;
							}
						break;
						case WindowLayer.RIGHT_ALIGN:
							this.rect.x = this._window.cgRect.x + this._window.cgRect.width/2 + this._cgDeltaWidth;
							this.rect.y = this._window.cgRect.y;
							this.rect.width = this._cgSizeWidth;
							this.rect.height = this._window.cgRect.height + this._cgDeltaHeight*2;
							if (this.external)
							{
								this.rect.height += this._cgSizeHeight*2;
							}
						break;
					}
				break;
			}
			return this;
		}
		
		public function send(deferred: Boolean = false, duration: int = 0, ease: String = ''):WindowLayer
		{
			if (this.blendModeModified)
			{
				this.cg.MixerBlend(this.channel.id, this.layerId, this.blendMode, true);
				this.blendModeModified = false;
			}
			
			if (!this.visibleModified && this.opacityModified)
			{
				this.cg.MixerOpacity(this.channel.id, this.layerId, this.opacity, duration, ease, true);
				this.opacityModified = false;
			}
			else if (this.visibleModified)
			{
				this.cg.MixerOpacity(this.channel.id, this.layerId, this.visible ? this.opacity:0, duration, ease, true);
				this.opacityModified = false;
				this.visibleModified = false;
			}
			
			if (this.modified)
			{
				this.cg.MixerFill(this.channel.id, this.layerId, this.rect.x, this.rect.y, this.rect.width, this.rect.height, duration, ease, true);
				if (this.clipModified)
				{
					this.cg.MixerClip(this.channel.id, this.layerId, this.clipRect.x, this.clipRect.y, this.clipRect.width, this.clipRect.height, duration, ease, true);
					this.clipModified = false;
				}
				this.modified = false;
			}
			
			if (this.contentModified)
			{
				switch (this.contentType)
				{
					case WindowLayer.CLIP_CONTENT:
						if (this.contentAutoPlay)
						{
							this.cg.LoadMedia(this.channel.id, this.layerId, this.content, this.contentLoop, this._seekContent);
							this.cg.PlayMedia(this.channel.id, this.layerId);
							if (this._seekContent > -1) this._seekContent = -1;							
						}
					break;
					case WindowLayer.COLOR_CONTENT:
					case WindowLayer.IMAGE_CONTENT:
						this.cg.Play(this.channel.id, this.layerId, this.content);
					break;
					case WindowLayer.DECKLINK_CONTENT:
						this.cg.Play(this.channel.id, this.layerId, 'DECKLINK '+this.content);
					break;
				}
				this.contentModified = false;
			}
			if (!deferred)
			{
				this.cg.MixerCommit(this.channel.id);
			}
			return this;
		}
	}
	
}
