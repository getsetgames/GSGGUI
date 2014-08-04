package
{
	import mx.collections.ArrayCollection;
	import com.adobe.csawlib.photoshop.Photoshop;
	
	[Bindable]
	public class UnitValue 
	{
		
		public var type: String;
		public var mm: Number; // always in mm
		public var dpi: Number = Photoshop.app.activeDocument.resolution;// 72; // dpi for px - yes, I see the irony, storing values as mm, and dots per inch...
		// dpi will ALWAYS be assumed to be 72 unless it is set to a specific value
		
		public static var zero: UnitValue = new UnitValue( "0 in" );
		
		public function UnitValue( obj:*, unit: String = null ) 
		{
			if ( obj is String ) 
			{
				var num: Number = parseFloat( obj );
				if ( isNaN( num ) ) 
				{
					num = 0;
				}
				type = _extractUnit( String( obj ) );
				
				// if units in the string - check for supplied unit - if so, convert what was in string to unit
				if ( type != "undefined" ) 
				{
					mm = _getMM( num, type );
				} else 
				{
					if ( unit != null ) 
					{
						// this'll make sure the unit is correct
						type = _extractUnit( unit );
						if ( type != "undefined" ) 
						{
							mm = _getMM( num, type );
						}
					}
				}
			} else if ( obj is Number ) 
			{
				type = _extractUnit( unit );
				if ( type != "undefined" ) 
				{
					mm = _getMM( obj as Number, type );
				} else 
				{
					mm = obj as Number;
					type = "mm";
				}
			} else if ( obj is UnitValue ) 
			{
				this.mm = obj.mm;
				this.type = obj.type;
			}
		}
		private static var units: Array = [ "ci", "cirero", "ciceros", "in", "inch", "inches", "pt",  "pts", "point", "points", "px", "pixel", "pixels", "pc", "pica", "picas", "mm", "millimeter", "millimeters", "cm", "centimeter", "centimeters" ];
		public static var prettyUnits: ArrayCollection = new ArrayCollection( [ "ciceros", "inches", "points", "pixels", "picas", "millimeters", "centimeters" ] );
		
		public static function validUnit( unit: String ): Boolean
		{
			for ( var i: int = 0; i < units.length; i++ )
			{
				if ( units[ i ] == unit )
				{
					return true;
				}
			}
			return false;
		}
		public function clone(): UnitValue 
		{
			return new UnitValue( this );
		}
		public function add( x:* ): void 
		{
			var unit: UnitValue = new UnitValue( x, this.type );
			mm += unit.mm;
		}
		public function subtract( x:* ): void 
		{
			var unit: UnitValue = new UnitValue( x, this.type );
			mm -= unit.mm
		}	
		public function multiply( x:* ): void 
		{
			if ( x is Number )
			{	
				mm *= x;
			} else
			{
				var unit: UnitValue = new UnitValue( x, this.type );
				mm *= unit.mm;
			}
		}
		public function divide( x:* ): void 
		{
			if ( x is Number )
			{
				mm /= x;
			} else
			{
				var unit: UnitValue = new UnitValue( x, this.type );
				mm /= unit.mm;
			}
		}
		public function modulo( x:* ): void
		{
			var unit: UnitValue = new UnitValue( x, this.type );
			mm = mm % unit.mm;
		}
		public function lessThan( unit: UnitValue ) : Boolean 
		{
			return ( this.mm < unit.mm );
		}
		public function lessThanEqualTo( unit: UnitValue ) : Boolean 
		{
			return ( this.mm <= unit.mm );
		}
		public function greaterThan( unit: UnitValue ) : Boolean 
		{
			return ( this.mm > unit.mm );
		}
		public function greaterThanEqualTo( unit: UnitValue ) : Boolean 
		{
			return ( this.mm >= unit.mm );
		}
		public function equals( unit: UnitValue ) : Boolean 
		{
			return ( this.mm == unit.mm );
		}
		
		
		public function toString() : String 
		{
			return mm.toString() + " " + type;
		}
		
		private function round( number: Number, precision: int ) : Number 
		{
			if ( precision == 0 ) {
				return Math.round( number );
			}
			return Math.round( number * Math.pow( 10, precision ) ) / Math.pow( 10, precision );
		}
		
		public function getAs( unit: String = null, precision: int = 3 ): Number 
		{
			if ( unit == null ) 
			{
				unit = type;
			}
			return round( this._convert( this.mm, unit ), precision );
		}
		
		public function getAsString( unit: String = null, precision: int = 3 ): String
		{
			var n: Number = getAs( unit, precision );
			if ( unit == null ) 
			{
				unit = type;
			}
			return ( n.toString() + " " + unit );
		}
		private function _extractUnit( st: String ): String 
		{
			if ( st == null ) 
			{
				null;
			}
			try 
			{
				var ex: RegExp = /\%|ci|cirero|in|inch|pt|point|px|pixel|pc|pica|mm|millimeter|cm|centimeter/g;
				return String( st.toLowerCase().match( ex )[ 0 ] );
			} catch ( e: Error )
			{
			}
			return null;
		}
		private function _getMM( num: Number, unit: String ) : Number 
		{
			if ( unit == null ) 
			{
				unit = type;
			}
			switch( unit.toLowerCase() ) 
			{
				case "%" : 
				{
					return 0;
					break;
				}
				case "in" : // 25.4 mm/in
				case "inches" :
				case "inch" : 
				{
					return num * 25.4;
					break;
				}
				case "ci" : // 12.7872 pt / ci and 72 pt/in
				case "ciceros" :
				case "cicero" : 
				{
					return ( num * 12.7872 * 25.4 ) / 72; 
					break;
				}
				case "px" :
				case "pixel" :
				case "pixels" :
				{
					return ( num * 25.4 ) / dpi;
					break;
				}
				case "pts" :
				case "points" :
				case "pt" : // 72 pt / in
				case "point" : 
				{
					return ( num * 25.4 ) / 72;
					break;
				}
				case "pc" : // 12 pt/ pi
				case "pcs" :
				case "picas" :
				case "pica" : 
				{
					return ( num * 25.4 ) * ( 12 / 72 );
					break;
				}
				case "mm" : 
				case "millimeters" :
				case "millimeter" : 
				{
					return num;
					break;
				}
				case "cm" : 
				case "centimeters" :
				case "centimeter" : 
				{
					return ( num * 10 );
					break;
				}
			}
			return 0;
		}
		private function _convert( mm: Number, unit: String = null ): Number 
		{
			if ( unit == null )
			{
				unit = type;
			}
			switch( unit.toLowerCase() ) 
			{
				case "in" : // 25.4 mm/in
				case "inches" :
				case "inch" : 
				{
					return ( mm / 25.4 );
					break;
				}
				case "ci" : // 12.7872 pt / ci and 72 pt/in
				case "ciceros" :
				case "cicero" : 
				{
					return ( ( mm / 25.4 ) * 72 / 12.7872 );
					break;
				}
				case "px" :
				case "pixel" :
				case "pixels" :
				{
					return ( ( mm / 25.4 ) * dpi );
					break;					
				}
				case "pts" :
				case "points" :
				case "pt" : // 72 pt / in
				case "point" : 
				{
					return ( ( mm / 25.4 ) * 72 );
					break;
				}
				case "pc" : // 12 pt/ pi
				case "picas" :
				case "pica" : 
				{
					return ( ( mm / 25.4 ) * 72 / 12 );
					break;
				}
				case "mm" : 
				case "millimeters" :
				case "millimeter" : 
				{
					return mm;
					break;
				}
				case "cm" : 
				case "centimeters" :
				case "centimeter" : 
				{
					return ( mm / 10 );
					break;
				}
			}
			return 0;
		}
	}
}