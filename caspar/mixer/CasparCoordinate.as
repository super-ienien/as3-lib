package caspar.mixer {
	
	public class CasparCoordinate {

		private var _width:int;
		private var _height:int;
		private var _anchorX:int;
		private var _anchorY:int;
		
		public function CasparCoordinate(screenWidth:int, screenHeight:int, anchorX:int = 0, anchorY:int = 0) {
			this._width = screenWidth;
			this._height = screenHeight;
			this._anchorX = anchorX;
			this._anchorY = anchorY;
		}

		public function x(val)
		{
			return (val+this._anchorX)/this._width;
		}

		public function y(val)
		{
			return (val+this._anchorY)/this._height;
		}
		
		public function width(val)
		{
			return val/this._width;
		}

		public function height(val)
		{
			return val/this._height;
		}
	}
}