package 
{
	import com.adobe.csawlib.photoshop.Photoshop;
	import com.adobe.csxs.core.CSInterface;
	import com.adobe.photoshop.*;
	import com.adobe.xmp.core.XMPMeta;
	
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.dns.AAAARecord;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	import spark.components.TextInput;
	
	public class GSGGUIPhotoshop
	{
		private static var kDocuments:Dictionary = new Dictionary();
		
		private static var kXMPNamespace:String = "com.getsetgames.GSGGUI";
		
		private static var kLayerName:String = "layerName";
		private static var kLayerID:String = "layerID";
		private static var kLayerClass:String = "layerClass";
		
		private static var kLayerHorizontalPositionType:String = "layerHorizontalPositionType";
		private static var kLayerVerticalPositionType:String = "layerVerticalPositionType";
		
		
		public static var kLayerHorizontalPosition:String = "layerHorizontalPosition";
		public static var kLayerHorizontalSnapTo:String = "layerHorizontalSnapTo";
		
		public static var kLayerVerticalPosition:String = "layerVerticalPosition";
		public static var kLayerVerticalSnapTo:String = "layerVerticalSnapTo";
		
		public static var kLayerPositionTypeAbsolute:String = "layerPositionTypeAbsolute";
		public static var kLayerPositionTypeSnapToPoint:String = "layerPositionTypeSnapToPoint";
		public static var kLayerPositionTypeRelative:String = "layerPositionTypeRelative";
		
		public static var kLayerPositionSnapToLeft:String = "layerPositionSnapToLeft";
		public static var kLayerPositionSnapToRight:String = "layerPositionSnapToRight";
		public static var kLayerPositionSnapToTop:String = "layerPositionSnapToTop";
		public static var kLayerPositionSnapToBottom:String = "layerPositionSnapToBottom";
		
		public static var kShouldRespondToEvents:Boolean = true;
		
		public static function getDocumentData(doc:Document = null):GSGGUIDocumentData
		{
			var ret:GSGGUIDocumentData = null;
			try
			{
				if (doc == null)
				{
					doc = Photoshop.app.activeDocument;
				}
				ret = kDocuments[doc.hostObjectDelegate];
				if (ret == null)
				{
					ret = new GSGGUIDocumentData(doc);
					kDocuments[doc.hostObjectDelegate] = ret;
					ret.loadAllLayers();
				}
			}
			catch (err:Error)
			{
				var stackTrace:String = err.getStackTrace();
				trace(stackTrace.split("\n")[1] + ": " + err);
			}
			return ret;
		}
		
		public static function deleteDocumentData(doc:Document):void
		{
			kDocuments[doc] = null;
		}
		
		public static function photoshopCallback(eventID:Number, descID:Number):void 
		{
			if (Photoshop.app.activeDocument == null || !kShouldRespondToEvents)
			{
				return;
			}
			
			if((eventID == PSTools.charToInteger("Opn ") || eventID == PSTools.charToInteger("Dlt ") ||
				eventID == PSTools.charToInteger("Mk  ") || eventID == PSTools.charToInteger("slct")))
			{
				updateLayerBasics();
				updateLayerPositionOptions();
				updateExportOptions()
			}
			else if (eventID == PSTools.charToInteger("CnvS"))
			{
				kShouldRespondToEvents = false;
				var doc:GSGGUIDocumentData = getDocumentData();
				doc.updateSize();
				if (doc.size.x != doc.oldSize.x || doc.size.y != doc.oldSize.y)
				{
					repositionLayersInDocument();
				}
				kShouldRespondToEvents = true;
			}
			else if (eventID == PSTools.charToInteger("Trnf") || eventID == PSTools.charToInteger("move"))
			{
				refreshLayerSize();
				updateLayerPositionOptions();
			}
			else if (eventID == PSTools.charToInteger("save"))
			{
				writeMetadata(null);
			}
		}
		
		public static function refreshLayerSize():void
		{
			try
			{
				var doc:GSGGUIDocumentData = getDocumentData();
				var layer:GSGGUILayerData = doc.getLayerData();
				layer.updateRect();
				layer.updateRawPosition();
				layer.updatePosition();
			}
			catch (err:Error)
			{
				var stackTrace:String = err.getStackTrace();
				trace(stackTrace.split("\n")[1] + ": " + err);
			}
		}
		
		public static function repositionLayersInDocument():void
		{
			try
			{
				var layers:Layers = Photoshop.app.activeDocument.layers;
				repositionLayers(layers);
			}
			catch (err:Error)
			{
				var stackTrace:String = err.getStackTrace();
				trace(stackTrace.split("\n")[1] + ": " + err);
			}
		}
		
		public static function repositionLayers(layers:Layers):void
		{
			try
			{
				var doc:GSGGUIDocumentData = getDocumentData();
				for (var i:int = 0; i < layers.length; ++i)
				{
					var layer:GSGGUILayerData = doc.getLayerData(layers.index(i));
					repositionLayer(layer);
//					if (layer is LayerSet)
//					{
//						repositionLayers(layer.layers);
//					}
				}
			}
			catch (err:Error)
			{
				var stackTrace:String = err.getStackTrace();
				trace(stackTrace.split("\n")[1] + ": " + err);
			}
		}
		
		public static function repositionLayer(layer:GSGGUILayerData):void
		{
			try
			{
				layer.updateRect();
				layer.updateRawPosition();
				var doc:GSGGUIDocumentData = layer.document;
				var rawPosition:Point = layer.rawPosition;
				var position:Point = layer.position;
				var newPosition:Point = new Point();
				var newScale:Point = new Point(100, 100);
				var documentSize:Point = doc.size;
				var oldDocSize:Point = doc.oldSize;
				var positionTypeH:String = layer.positionTypeHorizontal;
				var positionTypeV:String = layer.positionTypeVertical;
				
				if (positionTypeH == GSGGUIMetadata.kPositionTypeSnapToRight)
				{
					newPosition.x = documentSize.x - position.x;
				}
				else if (positionTypeH == GSGGUIMetadata.kPositionTypeSnapToLeftRight)
				{
					newScale.x = ((layer.rect.width + documentSize.x - oldDocSize.x) / layer.rect.width);
					newPosition.x = (layer.position.x - (layer.rect.width * 0.5)) + (layer.rect.width * newScale.x * 0.5);
					newScale.x *= 100;
				}
				else if (positionTypeH == GSGGUIMetadata.kPositionTypeRelative)
				{
					newPosition.x = documentSize.x * position.x;
				}
				else
				{
					newPosition.x = position.x;
				}
				
				/*=========================================================================================================*/
				if (positionTypeV == GSGGUIMetadata.kPositionTypeSnapToTop)
				{
					newPosition.y = documentSize.y - position.y;
				}
				else if (positionTypeV == GSGGUIMetadata.kPositionTypeSnapToTopBottom)
				{
					newScale.y = ((layer.rect.height + documentSize.y - oldDocSize.y) / layer.rect.height);
					newPosition.y = (layer.position.y - (layer.rect.height * 0.5)) + (layer.rect.height * newScale.y * 0.5);
					newScale.y *= 100;
				}
				else if (positionTypeV == GSGGUIMetadata.kPositionTypeRelative)
				{
					newPosition.y = documentSize.y * position.y;
				}
				else
				{
					newPosition.y = position.y;
				}
					
				/*=========================================================================================================*/
				if (position != null && newPosition != null)
				{
					layer.layer.translate((newPosition.x - rawPosition.x) + "px", (rawPosition.y - newPosition.y) + "px");
					layer.layer.resize(newScale.x, newScale.y, AnchorPosition.MIDDLECENTER);
					layer.updateRect();
					layer.updateRawPosition();
					layer.updatePosition();
				}
			}
			catch (err:Error)
			{
				var stackTrace:String = err.getStackTrace();
				trace(stackTrace.split("\n")[1] + ": " + err);
			}
		}
		
		public static function composeLayerName(layerName:String, layerID:String, layerClass:String):String
		{
			var ret:String = layerName;
			if (layerID.length != 0 || layerClass.length != 0)
			{
				ret += " <";
			}
			
			if (layerID.length != 0)
			{
				ret += layerID;
			}
			
			if (layerID.length != 0 && layerClass.length != 0)
			{
				ret += "::";
			}
			
			if (layerClass.length != 0)
			{
				ret += layerClass;
			}
			
			if (layerID.length != 0 || layerClass.length != 0)
			{
				ret += ">";
			}
			
			return ret;
		}
		
		public static function displayAlert(message:String):void
		{
			CSInterface.instance.evalScript("alert", message);
		}
		
		public static function changedLayerBasics(evt:Event):void
		{
			if (Photoshop.app.activeDocument == null)
			{
				return;
			}
			
			var doc:GSGGUIDocumentData = getDocumentData();
			var layer:GSGGUILayerData = doc.getLayerData();
			
			if (evt.currentTarget == GSGGUI.instance.nameField)
			{
				layer.name = GSGGUI.instance.nameField.text;
			}
			else if (evt.currentTarget == GSGGUI.instance.idField)
			{
				layer.id = GSGGUI.instance.idField.text;
			}
			else if (evt.currentTarget == GSGGUI.instance.classField)
			{
				layer.cls = GSGGUI.instance.classField.text;
			}
			else if (evt.currentTarget == GSGGUI.instance.miscField)
			{
				layer.misc = GSGGUI.instance.miscField.text;
			}
			
			layer.layer.name = composeLayerName(GSGGUI.instance.nameField.text, GSGGUI.instance.idField.text, GSGGUI.instance.classField.text);
		}
		
		public static function changedPositionType(evt:Event):void
		{
			try
			{
				var doc:GSGGUIDocumentData = getDocumentData();
				var layer:GSGGUILayerData = doc.getLayerData();
				
				var obj:Object = null;
				if (evt.currentTarget == GSGGUI.instance.positionDropDownHorizontal)
				{
					obj = GSGGUI.instance.positionDropDownHorizontal.selectedItem;
					if (obj.data == GSGGUIMetadata.kPositionTypeSnapToPoint)
					{
						layer.positionTypeHorizontal = GSGGUIMetadata.kPositionTypeSnapToLeft;
					}
					else
					{
						layer.positionTypeHorizontal = obj.data;
					}
				}
				else if (evt.currentTarget == GSGGUI.instance.positionDropDownVertical)
				{
					obj = GSGGUI.instance.positionDropDownVertical.selectedItem;
					if (obj.data == GSGGUIMetadata.kPositionTypeSnapToPoint)
					{
						layer.positionTypeVertical = GSGGUIMetadata.kPositionTypeSnapToTop;
					}
					else
					{
						layer.positionTypeVertical = obj.data;
					}
				}
				
				if (evt.currentTarget == GSGGUI.instance.snapToDropDownHorizontal)
				{
					obj = GSGGUI.instance.snapToDropDownHorizontal.selectedItem;
					layer.positionTypeHorizontal = obj.data;
				}
				else if (evt.currentTarget == GSGGUI.instance.snapToDropDownVertical)
				{
					obj = GSGGUI.instance.snapToDropDownVertical.selectedItem;
					layer.positionTypeVertical = obj.data;
				}
				
				if (layer.rawPosition == null)
				{
					layer.updateRect();
					layer.updateRawPosition();
				}
				layer.updatePosition();
			}
			catch(err:Error)
			{
				var stackTrace:String = err.getStackTrace();
				trace(stackTrace.split("\n")[1] + ": " + err);
			}
			
			updateLayerPositionOptions();
		}
		
		public static function updateLayerBasics():void
		{
			try
			{
				var doc:GSGGUIDocumentData = getDocumentData();
				var layer:GSGGUILayerData = doc.getLayerData();
				
				GSGGUI.instance.nameField.text = layer.name;
				GSGGUI.instance.idField.text = layer.id;
				GSGGUI.instance.classField.text = layer.cls;
				GSGGUI.instance.miscField.text = layer.misc;
				
				var layerName:String = composeLayerName(layer.name, layer.id, layer.cls);
				if (layer.layer.name != layerName)
				{	
					layer.layer.name = layerName;
				}
			}
			catch (err:Error)
			{
				var stackTrace:String = err.getStackTrace();
				trace(stackTrace.split("\n")[1] + ": " + err);
			}
		}
		
		public static function updateLayerPositionOptions():void
		{	
			try
			{
				var doc:GSGGUIDocumentData = getDocumentData();
				var layer:GSGGUILayerData = doc.getLayerData();
				var i:int = 0;
				var obj:Object = null;
				var provider:ArrayCollection = null;
				var type:String = null;
				
				if (layer.positionTypeHorizontal == GSGGUIMetadata.kPositionTypeSnapToLeft || layer.positionTypeHorizontal == GSGGUIMetadata.kPositionTypeSnapToRight || layer.positionTypeHorizontal == GSGGUIMetadata.kPositionTypeSnapToLeftRight)
				{
					GSGGUI.instance.panelRelativeHorizontal.visible = false;
					GSGGUI.instance.panelSnapToPointHorizontal.visible = true;
					provider = GSGGUI.instance.snapToHorizontalTypes;
					for (i = 0; i < provider.length; ++i)
					{
						obj = provider.getItemAt(i);
						if (obj.data == layer.positionTypeHorizontal)
						{
							GSGGUI.instance.snapToDropDownHorizontal.selectedIndex = obj.index;
							break;
						}
					}
					type = GSGGUIMetadata.kPositionTypeSnapToPoint;
				}
				else if (layer.positionTypeHorizontal == GSGGUIMetadata.kPositionTypeRelative)
				{
					GSGGUI.instance.panelRelativeHorizontal.visible = true;
					GSGGUI.instance.panelSnapToPointHorizontal.visible = false;
					type = GSGGUIMetadata.kPositionTypeRelative;
					GSGGUI.instance.relativePositionHorizontal.text = (layer.position.x * 100).toFixed(2).toString();
				}
				else
				{
					GSGGUI.instance.panelRelativeHorizontal.visible = false;
					GSGGUI.instance.panelSnapToPointHorizontal.visible = false;
					type = GSGGUIMetadata.kPositionTypeAbsolute;
				}
				
				provider = GSGGUI.instance.positionTypes;
				for (i = 0; i < provider.length; ++i)
				{
					obj = provider.getItemAt(i);
					if (obj.data == type)
					{
						GSGGUI.instance.positionDropDownHorizontal.selectedIndex = obj.index;
						break;
					}
				}
				
				if (layer.positionTypeVertical == GSGGUIMetadata.kPositionTypeSnapToTop || layer.positionTypeVertical == GSGGUIMetadata.kPositionTypeSnapToBottom || layer.positionTypeVertical == GSGGUIMetadata.kPositionTypeSnapToTopBottom)
				{
					GSGGUI.instance.panelRelativeVertical.visible = false;
					GSGGUI.instance.panelSnapToPointVertical.visible = true;
					provider = GSGGUI.instance.snapToVerticalTypes;
					for (i = 0; i < provider.length; ++i)
					{
						obj = provider.getItemAt(i);
						if (obj.data == layer.positionTypeVertical)
						{
							GSGGUI.instance.snapToDropDownVertical.selectedIndex = obj.index;
							break;
						}
					}
					type = GSGGUIMetadata.kPositionTypeSnapToPoint;
				}
				else if (layer.positionTypeVertical == GSGGUIMetadata.kPositionTypeRelative)
				{
					GSGGUI.instance.panelRelativeVertical.visible = true;
					GSGGUI.instance.panelSnapToPointVertical.visible = false;
					type = GSGGUIMetadata.kPositionTypeRelative;
					GSGGUI.instance.relativePositionVertical.text = (layer.position.y * 100).toFixed(2).toString();
				}
				else
				{
					GSGGUI.instance.panelRelativeVertical.visible = false;
					GSGGUI.instance.panelSnapToPointVertical.visible = false;
					type = GSGGUIMetadata.kPositionTypeAbsolute;
				}
				
				provider = GSGGUI.instance.positionTypes;
				for (i = 0; i < provider.length; ++i)
				{
					obj = provider.getItemAt(i);
					if (obj.data == type)
					{
						GSGGUI.instance.positionDropDownVertical.selectedIndex = obj.index;
						break;
					}
				}
			}
			catch(err:Error)
			{
				try
				{
					GSGGUI.instance.panelRelativeHorizontal.visible = false;
					GSGGUI.instance.panelSnapToPointHorizontal.visible = false;
					GSGGUI.instance.panelRelativeVertical.visible = false;
					GSGGUI.instance.panelSnapToPointVertical.visible = false;
					GSGGUI.instance.positionDropDownHorizontal.selectedIndex = 0;
					GSGGUI.instance.positionDropDownVertical.selectedIndex = 0;
				}
				catch (err0:Error)
				{
					var stackTrace0:String = err0.getStackTrace();
					trace(stackTrace0.split("\n")[1] + ": " + err0);
				}
				
				var stackTrace:String = err.getStackTrace();
				trace(stackTrace.split("\n")[1] + ": " + err);
			}
		}
		
		public static function updateExportOptions():void
		{
			try
			{
				var doc:GSGGUIDocumentData = getDocumentData();
				var layer:GSGGUILayerData = doc.getLayerData();
				GSGGUI.instance.exportPNGCheckBox.selected = layer.exportPNG;
			}
			catch (err:Error)
			{
				var stackTrace:String = err.getStackTrace();
				trace(stackTrace.split("\n")[1] + ": " + err);
			}
		}
		
		public static function calculateRelativePosition(evt:Event):void
		{
			try
			{
				var doc:GSGGUIDocumentData = getDocumentData();
				var layer:GSGGUILayerData = doc.getLayerData();
				
				layer.updateRect();
				layer.updateRawPosition();
				layer.updatePosition();
				GSGGUI.instance.relativePositionHorizontal.text = (layer.position.x * 100).toFixed(2).toString();
				GSGGUI.instance.relativePositionVertical.text = (layer.position.y * 100).toFixed(2).toString();
				
			}
			catch (err:Error)
			{
				var stackTrace:String = err.getStackTrace();
				trace(stackTrace.split("\n")[1] + ": " + err);
			}
		}
		
		public static function manualRelativePosition(evt:Event):void
		{
			try
			{
				var doc:GSGGUIDocumentData = getDocumentData();
				var layer:GSGGUILayerData = doc.getLayerData();
				
				var currentPosition:Point = layer.rawPosition;
				var newPosition:Point = new Point();
				var documentSize:Point = doc.size;
				if (evt.currentTarget == GSGGUI.instance.relativePositionHorizontal)
				{
					newPosition.y = currentPosition.y;
					newPosition.x = documentSize.x * (Number(GSGGUI.instance.relativePositionHorizontal.text) / 100.0);
				}
				else if (evt.currentTarget == GSGGUI.instance.relativePositionVertical)
				{
					newPosition.x = currentPosition.x;
					newPosition.y = documentSize.y * (Number(GSGGUI.instance.relativePositionVertical.text) / 100.0);
				}
			
				layer.layer.translate((newPosition.x - currentPosition.x) + "px", (currentPosition.y - newPosition.y) + "px");
				layer.updateRect();
				layer.updateRawPosition();
				layer.updatePosition();
			}
			catch(err:Error)
			{
				var stackTrace:String = err.getStackTrace();
				trace(stackTrace.split("\n")[1] + ": " + err);
			}
		}
		
		public static function creationCompleteHandler(evt:Event):void
		{
			
			if (evt.currentTarget == GSGGUI.instance.panelRelativeHorizontal || evt.currentTarget == GSGGUI.instance.panelSnapToPointHorizontal
				|| evt.currentTarget == GSGGUI.instance.panelRelativeVertical || evt.currentTarget == GSGGUI.instance.panelSnapToPointVertical)
			{
				updateLayerPositionOptions();
			}
			else if (evt.currentTarget == GSGGUI.instance.exportPNGCheckBox)
			{
				updateExportOptions();
			}
		}
		
		public static function changedExportSettings(evt:Event):void
		{
			try
			{
				var doc:GSGGUIDocumentData = getDocumentData();
				var layer:GSGGUILayerData = doc.getLayerData();
				if (evt.currentTarget == GSGGUI.instance.exportPNGCheckBox)
				{
					layer.exportPNG = GSGGUI.instance.exportPNGCheckBox.selected;
				}
			}
			catch (err:Error)
			{
				var stackTrace:String = err.getStackTrace();
				trace(stackTrace.split("\n")[1] + ": " + err);
			}
		}
		
		public static function writeMetadata(evt:Event):void
		{
			try
			{
				var doc:GSGGUIDocumentData = getDocumentData();
				doc.saveLayersMetadata();
			}
			catch (err:Error)
			{
				var stackTrace:String = err.getStackTrace();
				trace(stackTrace.split("\n")[1] + ": " + err);
			}
		}
		
		public static function calculateLayerSizes(evt:Event):void
		{
			try
			{
				var doc:GSGGUIDocumentData = getDocumentData();
				doc.calculateLayerSizes();
			}
			catch (err:Error)
			{
				var stackTrace:String = err.getStackTrace();
				trace(stackTrace.split("\n")[1] + ": " + err);
			}
		}
	}
}