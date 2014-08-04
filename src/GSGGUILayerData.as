package
{
	import com.adobe.photoshop.Layer;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	public class GSGGUILayerData
	{	
		private var m_name:String;
		private var m_id:String;
		private var m_cls:String;
		private var m_misc:String;
		private var m_rect:Rectangle;
		private var m_position:Point;
		private var m_rawPosition:Point;
		private var m_positionTypeHorizontal:String;
		private var m_positionTypeVertical:String;
		private var m_layer:Layer;
		private var m_document:GSGGUIDocumentData;
		private var m_exportPNG:Boolean;
		private var m_scaleToFitHorizontal:Boolean;
		private var m_scaleToFitVertical:Boolean;
		
		private var m_dirty:Boolean;
		
		//=====================================================
		public function get name():String
		{
			return m_name;
		}
		
		public function set name(value:String):void
		{
			m_name = value;
			m_dirty = true;
		}
		//=====================================================
		
		//=====================================================
		public function get id():String
		{
			return m_id;
		}
		
		public function set id(value:String):void
		{
			m_id = value;
			m_dirty = true;
		}
		//=====================================================
		
		//=====================================================
		public function get cls():String
		{
			return m_cls;
		}
		
		public function set cls(value:String):void
		{
			m_cls = value;
			m_dirty = true;
		}
		//=====================================================
		
		//=====================================================
		public function get misc():String
		{
			return m_misc;
		}
		
		public function set misc(value:String):void
		{
			m_misc = value;
			m_dirty = true;
		}
		//=====================================================
		
		//=====================================================
		public function get rect():Rectangle
		{
			return m_rect;
		}
		
		public function set rect(value:Rectangle):void
		{
			m_rect = value;
			m_dirty = true;
		}
		//=====================================================
		
		//=====================================================
		public function get position():Point
		{
			return m_position;
		}
		
		public function set position(value:Point):void
		{
			m_position = value;
			m_dirty = true;
		}
		//=====================================================
		
		//=====================================================
		public function get rawPosition():Point
		{
			return m_rawPosition;
		}
		
		public function set rawPosition(value:Point):void
		{
			m_rawPosition = value;
			m_dirty = true;
		}
		//=====================================================
		
		//=====================================================
		public function get positionTypeHorizontal():String
		{
			return m_positionTypeHorizontal;
		}
		
		public function set positionTypeHorizontal(value:String):void
		{
			m_positionTypeHorizontal = value;
			m_dirty = true;
		}
		//=====================================================
		
		//=====================================================
		public function get positionTypeVertical():String
		{
			return m_positionTypeVertical;
		}
		
		public function set positionTypeVertical(value:String):void
		{
			m_positionTypeVertical = value;
			m_dirty = true;
		}
		//=====================================================
		
		//=====================================================
		public function get layer():Layer
		{
			return m_layer;
		}
		
		public function set layer(value:Layer):void
		{
			m_layer = value;
			m_dirty = true;
		}
		//=====================================================
		
		//=====================================================
		public function get document():GSGGUIDocumentData
		{
			return m_document;
		}
		
		public function set document(value:GSGGUIDocumentData):void
		{
			m_document = value;
			m_dirty = true;
		}
		//=====================================================
		
		//=====================================================
		public function get exportPNG():Boolean
		{
			return m_exportPNG;
		}
		
		public function set exportPNG(value:Boolean):void
		{
			m_exportPNG = value;
			m_dirty = true;
		}
		//=====================================================
		
		//=====================================================
		public function get scaleToFitHorizontal():Boolean
		{
			return m_scaleToFitHorizontal;
		}
		
		public function set scaleToFitHorizontal(value:Boolean):void
		{
			m_scaleToFitHorizontal = value;
			m_dirty = true;
		}
		//=====================================================
		
		//=====================================================
		public function get scaleToFitVertical():Boolean
		{
			return m_scaleToFitVertical;
		}
		
		public function set scaleToFitVertical(value:Boolean):void
		{
			m_scaleToFitVertical = value;
			m_dirty = true;
		}
		//=====================================================
		
		//=====================================================
		public function get dirty():Boolean
		{
			return m_dirty;
		}
		//=====================================================
		
		
		
		public function GSGGUILayerData(theLayer:Layer, theDocument:GSGGUIDocumentData)
		{
			layer = theLayer;
			document = theDocument;
			
			if (!GSGGUIMetadata.readLayerMetadata(this))
			{
				name = layer.name;
				id = "";
				cls = "";
				misc = "";
				positionTypeHorizontal = GSGGUIMetadata.kPositionTypeAbsolute;
				positionTypeVertical = GSGGUIMetadata.kPositionTypeAbsolute;
				updateRect();
				updateRawPosition();
				updatePosition();
				exportPNG = false;
			}
			else
			{
				m_dirty = false;
			}
		}
		
		public function updateRect():void
		{
			var bounds:Array = layer.bounds;
			rect = PSTools.getRectangleFromUnitArray(bounds);
		}
		
		public function updateRawPosition():void
		{
			var docSize:Point = document.size;
			rawPosition = new Point((rect.x + (rect.width * 0.5)), (docSize.y - (rect.y + (rect.height * 0.5))));
		}
		
		public function updatePosition():void
		{
			var docSize:Point = document.size;
			position = new Point(rawPosition.x, rawPosition.y);
			if (positionTypeHorizontal == GSGGUIMetadata.kPositionTypeRelative)
			{
				position.x = position.x / docSize.x;
			}
			else if (positionTypeHorizontal == GSGGUIMetadata.kPositionTypeSnapToRight)
			{
				position.x = docSize.x - rawPosition.x;
			}
			
			if (positionTypeVertical == GSGGUIMetadata.kPositionTypeRelative)
			{
				position.y = position.y / docSize.y; 
			}
			else if (positionTypeVertical == GSGGUIMetadata.kPositionTypeSnapToTop)
			{
				position.y = docSize.y - position.y;
			}
		}
		
		public function writeLayerMetadata():void
		{
			if (m_dirty)
			{
				GSGGUIMetadata.writeLayerMetadata(this);
				m_dirty = false;
			}
		}
	}
}