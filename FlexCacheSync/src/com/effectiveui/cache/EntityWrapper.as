package com.effectiveui.cache
{
	import mx.utils.ObjectProxy;
	
	[Bindable]
	public class EntityWrapper
	{
		public var entityId:String;
		public var entity:*; 
		
		public function EntityWrapper(id:String)
		{
			entityId = id;
		}
		
	}
}