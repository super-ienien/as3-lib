package caspar.mixer {
	
	public class CasparCoordinate {

		public var screenWidth:int;
		public var screenHeight:int;
		private var _anchorX:int;
		private var _anchorY:int;
		
		public function CasparCoordinate(screenWidth:int, screenHeight:int, anchorX:int = 0, anchorY:int = 0) {
			this.screenWidth = screenWidth;
			this.screenHeight = screenHeight;
			this._anchorX = anchorX;
			this._anchorY = anchorY;
		}

		public function x(val)
		{
			return (val+this._anchorX)/this.screenWidth;
		}

		public function y(val)
		{
			return (val+this._anchorY)/this.screenHeight;
		}
		
		public function width(val)
		{
			return val/this.screenWidth;
		}

		public function height(val)
		{
			return val/this.screenHeight;
		}
	}
}