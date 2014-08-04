package
{
	import com.adobe.csawlib.photoshop.Photoshop;
	import com.adobe.csxs.core.CSInterface;
	import com.adobe.photoshop.*;
	import com.adobe.xmp.core.XMPMeta;
	
	public class GSGGUIMetadata
	{	
		public static var kName:String = "GSGGUIName";
		public static var kID:String = "GSGGUIID";
		public static var kClass:String = "GSGGUIClass";
		public static var kMisc:String = "GSGGUIMisc";
		
		
		public static var kPositionTypeHorizontal:String = "GSGGUIPositionTypeHorizontal";
		public static var kPositionTypeVertical:String = "GSGGUIPositionTypeVertical";
		
		public static var kPositionTypeAbsolute:String = "GSGGUIPositionTypeAbsolute";
		public static var kPositionTypeRelative:String = "GSGGUIPositionTypeRelative";
		public static var kPositionTypeSnapToPoint:String = "GSGGUIPositionTypeSnapToPoint";
		
		public static var kPositionTypeSnapToLeft:String = "GSGGUIPositionTypeSnapToLeft";
		public static var kPositionTypeSnapToRight:String = "GSGGUIPositionTypeSnapToRight";
		public static var kPositionTypeSnapToLeftRight:String = "GSGGUIPositionTypeSnapToLeftRight";
		
		public static var kPositionTypeSnapToTop:String = "GSGGUIPositionTypeSnapToTop";
		public static var kPositionTypeSnapToBottom:String = "GSGGUIPositionTypeSnapToBottom";
		public static var kPositionTypeSnapToTopBottom:String = "GSGGUIPositionTypeSnapToTopBottom";
		
		public static var kScaleToFitHorizontal:String = "GSGGUIScaleToFitHorizontal";
		public static var kScaleToFitVertical:String = "GSGGUIScaleToFitVertical";
		
		public static var kRect:String = "GSGGUIRect";
		public static var kPosition:String = "GSGGUIPosition";
		
		public static var kExportPNG:String = "GSGGUIExportPNG";
		
		private static var kXMPNamespace:String = "com.getsetgames.GSGGUI";
		private var app:Application = Photoshop.app;
		
		public static function setLayerMetadata(key:String, value:String, layer:Layer=null):void
		{
			try
			{	
				if (layer == null)
				{
					layer = Photoshop.app.activeDocument.activeLayer;
				}
				
				if (layer != Photoshop.app.activeDocument.backgroundLayer)
				{
					var metadata:XMPMeta = new XMPMeta(layer.xmpMetadata.rawData);
					var ns:Namespace = new Namespace(kXMPNamespace);
					metadata.ns::[key] = value;
					layer.xmpMetadata.rawData = metadata.serialize();
				}
			}
			catch (err:Error)
			{
				var stackTrace:String = err.getStackTrace();
				trace(stackTrace.split("\n")[1] + ": " + err);
			}
		}
		
		public static function getLayerMetadata(key:String, layer:Layer=null):String
		{
			try
			{
				if (layer == null)
				{
					layer = Photoshop.app.activeDocument.activeLayer;
				}
				
				if (layer != Photoshop.app.activeDocument.backgroundLayer)
				{
					var metadata:XMPMeta = new XMPMeta(layer.xmpMetadata.rawData);
					var ns:Namespace = new Namespace(kXMPNamespace);
					return metadata.ns::[key].toString();
				}
			}
			catch (err:Error)
			{
				var stackTrace:String = err.getStackTrace();
				trace(stackTrace.split("\n")[1] + ": " + err);
			}
			
			return null;
		}
		
		public static function writeLayerMetadata(layerData:GSGGUILayerData):void
		{
			try
			{
				var layer:Layer = layerData.layer;
				var metadata:XMPMeta = new XMPMeta(layer.xmpMetadata.rawData);
				var ns:Namespace = new Namespace(kXMPNamespace);
				
				metadata.ns::[kPositionTypeHorizontal] = layerData.positionTypeHorizontal;
				metadata.ns::[kPositionTypeVertical] = layerData.positionTypeVertical;
				metadata.ns::[kPosition] = PSTools.pointToString(layerData.position);
				metadata.ns::[kRect] = PSTools.rectangleToString(layerData.rect);
				metadata.ns::[kName] = layerData.name;
				metadata.ns::[kID] = layerData.id;
				metadata.ns::[kClass] = layerData.cls;
				metadata.ns::[kMisc] = layerData.misc;
				metadata.ns::[kExportPNG] = layerData.exportPNG.toString();
				metadata.ns::[kScaleToFitHorizontal] = layerData.scaleToFitHorizontal;
				metadata.ns::[kScaleToFitVertical] = layerData.scaleToFitVertical;
				
				layer.xmpMetadata.rawData = metadata.serialize();
			}
			catch (err:Error)
			{
				var stackTrace:String = err.getStackTrace();
				trace(stackTrace.split("\n")[1] + ": " + err);
			}
		}
		
		public static function readLayerMetadata(layerData:GSGGUILayerData):Boolean
		{
			try
			{
				var layer:Layer = layerData.layer;
				var metadata:XMPMeta = new XMPMeta(layer.xmpMetadata.rawData);
				var ns:Namespace = new Namespace(kXMPNamespace);
				
				var layerName:String = metadata.ns::[kName];
				if (layerName == null || layerName == "null")
				{
					return false;
				}
				layerData.name = layerName;
				layerData.positionTypeHorizontal = metadata.ns::[kPositionTypeHorizontal];
				layerData.positionTypeVertical = metadata.ns::[kPositionTypeVertical];
				layerData.position = PSTools.stringToPoint(metadata.ns::[kPosition]);
				layerData.rect = PSTools.stringToRectangle(metadata.ns::[kRect]);
				layerData.id = metadata.ns::[kID];
				layerData.cls = metadata.ns::[kClass];
				layerData.misc = metadata.ns::[kMisc];
				layerData.exportPNG = PSTools.stringToBoolean(metadata.ns::[kExportPNG]);
				layerData.scaleToFitHorizontal = PSTools.stringToBoolean(metadata.ns::[kScaleToFitHorizontal]);
				layerData.scaleToFitVertical = PSTools.stringToBoolean(metadata.ns::[kScaleToFitVertical]);
				
				return true;
			}
			catch (err:Error)
			{
				var stackTrace:String = err.getStackTrace();
				trace(stackTrace.split("\n")[1] + ": " + err);
			}
			
			return false;
		}
	}
}