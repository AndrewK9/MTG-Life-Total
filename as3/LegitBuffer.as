package as3 {
	import flash.utils.ByteArray;	
	
	public class LegitBuffer {

		public var byteArray = new ByteArray();

		public function get length(): int {
			return byteArray.length;
		}
		
		public function LegitBuffer(size:int = 0) {
			setPointer(size);
		}
		public function setPointer(pos:int):void {
			while(byteArray.position < pos) {
				byteArray.position = byteArray.length;
				byteArray.writeByte(0);
			}
			byteArray.position = pos;
		}
		public function slice(start:int = 0, end:int = 0): ByteArray {
			var temp:ByteArray = new ByteArray();
			if(end == 0) end = byteArray.length;
			byteArray.position = start;
			byteArray.readBytes(temp, 0, end - start);
			return temp;
		}
		public function trim(amt:int = 1):void {
			byteArray = slice(amt);
		}
		public function readUInt8(offset:int = 0):int {
			byteArray.position = offset;
			return byteArray.readByte();
		}
		public function write(str:String, offset:int = 0):void {
			setPointer(offset);
			byteArray.writeMultiByte(str, "us-ascii");
		}
		public function writeUInt8(num:int, offset:int = 0):void {
			setPointer(offset);
			byteArray.writeByte(num);
		}
		public function print():void {
			byteArray.position = 0;
			var output:String = "<Buffer ";
			while(byteArray.position < byteArray.length){
				output += byteArray.readByte().toString(16) + " ";
			}
			output += "> \"" + toString() + "\"";
			trace(output);
		}
		public function toString():String {
			return byteArray.toString();
		}
	}
}
