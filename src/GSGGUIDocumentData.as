package
{
	import com.adobe.photoshop.Document;
	import com.adobe.photoshop.Layer;
	import com.adobe.photoshop.LayerSet;
	import com.adobe.photoshop.Layers;
	
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	public class GSGGUIDocumentData
	{
		public var size:Point;
		public var oldSize:Point;
		public var document:Document;
		public var layers:Dictionary;
		
		public function GSGGUIDocumentData(theDocument:Document)
		{
			layers = new Dictionary();
			document = theDocument;
			updateSize();
		}
		
		public function updateSize():void
		{
			oldSize = size;
			var docHeight:UnitValue = new UnitValue(document.height);
			var docWidth:UnitValue = new UnitValue(document.width);
			size = new Point(docWidth.getAs("px"), docHeight.getAs("px"));
		}
		
		public function getLayerData(layer:Layer = null):GSGGUILayerData
		{
			if (layer == null)
			{
				layer = document.activeLayer;
			}
			var layerData:GSGGUILayerData = layers[layer.hostObjectDelegate];
			if (layerData == null)
			{
				layerData = new GSGGUILayerData(layer, this);
				layers[layer.hostObjectDelegate] = layerData;
			}
			return layerData;
		}
		
		public function loadAllLayers():void
		{
			this.loadLayersInSet(document.layers);
		}
		
		public function loadLayersInSet(psLayers:Layers):void
		{
			var length:int = psLayers.length;
			for (var i:int = 0; i < length; ++i)
			{
				var psLayer:Layer = psLayers.index(i);
				this.getLayerData(psLayer);
				var typename:String = psLayer.hostGet("typename", String);
				if (typename == "LayerSet")
				{
					var children:Layers = psLayer.hostGet("layers", Layers);
					this.loadLayersInSet(children);
				}
			}
		}
		
		public function deleteLayer(layer:Layer):void
		{
			layers[layer] = null;
		}
		
		public function saveLayersMetadata():void
		{
			for each (var layerData:GSGGUILayerData in layers)
			{
				layerData.writeLayerMetadata();
			}
		}
		
		public function calculateLayerSizes():void
		{
			this.loadAllLayers();
			for each (var layerData:GSGGUILayerData in layers)
			{
				layerData.updateRect();
				layerData.updateRawPosition();
				layerData.updatePosition();
			}
		}
	}
}