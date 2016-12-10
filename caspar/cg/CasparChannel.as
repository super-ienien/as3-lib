package caspar.cg {
	
	import caspar.mixer.CasparCoordinate;
	import caspar.network.ServerConnection;
	
	public class CasparChannel {

		public var coord:CasparCoordinate;
		public var cg:ServerConnection;
		public var id:int;
		
		public function CasparChannel(cg:ServerConnection, channelID:int, screenWidth:int, screenHeight:int) {
			this.coord = new CasparCoordinate(screenWidth, screenHeight, Math.round(screenWidth/2), Math.round(screenHeight/2));
			this.id = channelID;
			this.cg = cg;
		}
		
		public function clear(layer:int = -1):void
		{
			this.cg.ClearMedia(this.id, layer);
		}
		
		public function clearMixer(layer:int = -1):void
		{
			this.cg.MixerClear(this.id, layer);
		}		
		
		public function commit():void
		{
			this.cg.MixerCommit(this.id);
		}
	}
}
