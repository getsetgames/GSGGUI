package
{
	import com.adobe.photoshop.Layer;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import mx.utils.StringUtil;

	public class PSTools
	{
		public static function charToInteger(keyword:String):Number	
		{
			var value:Number;
			value  = keyword.charCodeAt(0) * 256 * 256 * 256;
			value += keyword.charCodeAt(1) * 256 * 256;
			value += keyword.charCodeAt(2) * 256;
			value += keyword.charCodeAt(3);
			return value;
		}
		
		public static function stringToPoint(str:String):Point
		{
			var ret:Point = new Point();
			var start:int = str.indexOf("{");
			var end:int = str.indexOf("}");
			if (start != -1 && end != -1)
			{
				var pointString:String = str.substring(start + 1, end -1);
				var components:Array = pointString.split(",");
				if (components.length == 2)
				{
					ret.x = Number(components[0]);
					ret.y = Number(components[1]);
				}
			}
			return ret;
		}
		
		public static function pointToString(point:Point):String
		{
			return "{ " + point.x + ", " + point.y + " }";
		}
		
		public static function stringToRectangle(str:String):Rectangle
		{
			var start:int = str.indexOf("{");
			var end:int = str.indexOf("}");
			var pointStr:String = str.substring(start + 1, end);
			var point01:Point = stringToPoint(pointStr);
			start = str.indexOf("{", end + 1);
			end = str.indexOf("}", start);
			pointStr = str.substring(start, end);
			var point02:Point = stringToPoint(pointStr);
			return new Rectangle(point01.x, point01.y, point02.x, point02.y);
		}
		
		public static function rectangleToString(rect:Rectangle):String
		{
			return "{ { " + rect.x + ", " + rect.y + " }, { " + rect.width + ", " + rect.height + " } }";
		}
		
		public static function getRectangleFromUnitArray(bounds:Array, units:String = "px"):Rectangle
		{
			var tlX:UnitValue = new UnitValue(bounds[0]);
			var tlY:UnitValue = new UnitValue(bounds[1]);
			
			var brX:UnitValue = new UnitValue(bounds[2]);
			var brY:UnitValue = new UnitValue(bounds[3]);
			
			var ret:Rectangle = new Rectangle(tlX.getAs(units), tlY.getAs(units), brX.getAs(units) - tlX.getAs(units), brY.getAs(units) - tlY.getAs(units));
			
			return ret;
		}
		
		public static function getLayerRectangle(layer:Layer):Rectangle
		{
			var bounds:Array = layer.bounds;
			var rect:Rectangle = PSTools.getRectangleFromUnitArray(bounds);
			return rect;
		}
		
		public static function stringToBoolean(string:String):Boolean
		{
			var lowercaseString:String = StringUtil.trim(string.toLowerCase());
			switch (lowercaseString)
			{
				case "1":
				case "true":
				case "yes":
				case "positive":
					return true;
			}
			
			return false;
		}
	}
}