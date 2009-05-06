package com.effectiveui.cache
{
	import com.effectiveui.services.GetEntitiesService;
	import com.effectiveui.vo.BaseVO;
	
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.core.UIComponent;
	
	import org.pranaframework.reflection.Accessor;
	import org.pranaframework.reflection.Type;
	
	public class EntityCache
	{		
		private static var _instance:EntityCache;
		
		public static function getInstance():EntityCache {
			if (_instance == null) _instance = new EntityCache(new PrivateEntityCache);
			return _instance;
		}
		
		private var cache:Dictionary;
		private var pendingItems:Dictionary;
		private var propertyCache:Dictionary;
		
		public function EntityCache(access:PrivateEntityCache){
			cache = new Dictionary();
			pendingItems = new Dictionary();
			propertyCache = new Dictionary();
		}
		
		private function checkEntities():void {
			var entityIds : Array;
			
			shouldCheck = false;
			
//			trace("begin check entities");
			for (var id:String in cache) {
				
				if (id != null) {
					var wr:WeakReference = cache[id] as WeakReference;
					var ew:EntityWrapper = wr.getValue() as EntityWrapper;
					
					if (ew == null) {
						delete cache[id]; //delete weak reference to object that has been gc'ed
					} else {
						if (!pendingItems[id] && ew.entity == null) {
							pendingItems[id] = true; //don't fetch this item again, until result received
							if(entityIds == null){
								entityIds = [];
							}
							entityIds.push(id);
						}		
					}
				}
			}
			
			if (entityIds) {
				GetEntitiesService.getInstance().getEntities(entityIds);
			}			
		}

		//This returns the entity if it is in the cache. However, the cache is not modified
		//in any way by checking for the entity.
		public function getEntityIfCached(id:Number,resultIfNotInCache:BaseVO=null):BaseVO {
			if (isNaN(id)) {
				throw new Error("Provided entity id is NaN");
			}
						
			var res:WeakReference = cache[id] as WeakReference;
			
			if (res == null || res.getValue() == null) 	return resultIfNotInCache;
			
			var ew:EntityWrapper = res.getValue() as EntityWrapper;
						
			if (ew == null || ew.entity == null) return resultIfNotInCache;
			return ew.entity;			
		}

		public function getEntity(id:String,triggerCheckEntities:Boolean=true):EntityWrapper {
			var res:WeakReference = cache[id] as WeakReference;
			var ew:EntityWrapper;
			
			if (!id) {
				throw new Error("Must provide an entity id");
			}
			
			if (res == null || res.getValue() == null) {			
				ew = new EntityWrapper(id);
				cache[id] = new WeakReference(ew);
				
				if (triggerCheckEntities) checkEntitiesNextFrame();
				
				return ew;
			}
			
			ew = res.getValue() as EntityWrapper;
			return ew;			
		}
		
		private var shouldCheck:Boolean = false;
		
		private function checkEntitiesNextFrame():void {			
			if (shouldCheck) return;
			shouldCheck = true;
			var app:UIComponent = Application.application as UIComponent;
			app.callLater(checkEntities,null);
		
		}
		
		public function updateEntity(entity:BaseVO,currentRefs:Dictionary=null):BaseVO {		
			if (!entity.id) return null;
				
			var ew:EntityWrapper = getEntity(entity.id,false);
			var result:BaseVO = null;
			var isNewObject:Boolean = false;				
			
			if (currentRefs == null) currentRefs = new Dictionary();			
			if (currentRefs[entity.id]) {
				if (ew.entity == null) return null;
				return ew.entity as BaseVO;
			}			
			currentRefs[entity.id] = true;
						
//			trace("Updating entity " + entity + " with id " + entity.id);
			
			if (ew.entity == null) {
				//the wrapper object does not currently have an entity
				ew.entity = entity;
				isNewObject = true;
				checkEntityProperties(ew.entity as BaseVO,currentRefs);	
			} else if (ew.entity === entity) {
				//same identity objects
				checkEntityProperties(ew.entity as BaseVO,currentRefs);	
			} else {									
				for each (var prop:String in getEntityPropertiesPrana(entity)) {
					//prevent simple types like Strings from being duplicated and triggering property change events
					if (ew.entity[prop] != entity[prop]) { 
						ew.entity[prop] = checkEntityProperty(entity[prop],currentRefs);						
					}		
				}
			}			
			pendingItems[entity.id] = false;
			return ew.entity as BaseVO;
		}
		
		public static function getEntityPropertiesPrana(entity:BaseVO):Array {	
			var ec:EntityCache = EntityCache.getInstance();
			var classname:String = getQualifiedClassName(entity);		
			
			var result:Array = ec.propertyCache[classname] as Array;
			if (result) {
				return result;
			} else {
				result = new Array();
				ec.propertyCache[classname] = result; 
			}
			
			var type:Type = Type.forName(classname);
			
			for each (var accessor:Accessor in type.accessors) {
				if (accessor.isStatic == false && accessor.access.name == "readwrite") {
					result.push(accessor.name);
				}
			}
			return result;
		}
		
		//recursively check properties, looking for objects to add to the cache
		private function checkEntityProperties(entity:BaseVO,currentRefs:Dictionary):void {			
			for each (var prop:String in getEntityPropertiesPrana(entity)) {
				var res:Object = checkEntityProperty(entity[prop],currentRefs);
				if (entity[prop] != res) entity[prop] = res;
			}			
		}
		
		//obj can be Array or ArrayCollection
		public function updateCollection(obj:Object,currentRefs:Dictionary=null):void {
			checkEntityProperty(obj,currentRefs);
		}
		
		private function checkEntityProperty(obj:Object,currentRefs:Dictionary):Object {
			if (obj is BaseVO) {					
				var res:BaseVO = updateEntity(obj as BaseVO,currentRefs);
				if (res != null) return res;					
			}
			
			if (obj is Array) {
				var arr:Array = obj as Array;
				for (var i:int=0;i<arr.length;i++) {
					if (arr[i] is BaseVO) {
						var res2:BaseVO = updateEntity(arr[i] as BaseVO,currentRefs);
						if (res2 != null) arr[i] = res2;
					}
				}
			}
			
			if (obj is ArrayCollection) {
				var ac:ArrayCollection = obj as ArrayCollection;
				ac.disableAutoUpdate();
				for (i=0;i<ac.length;i++) {
					if (ac.getItemAt(i) is BaseVO) {
						var res3:BaseVO = updateEntity(ac.getItemAt(i) as BaseVO,currentRefs);
						if (res3 != null) {
							ac.setItemAt(res3,i);
						}
					}
				}					
				ac.enableAutoUpdate();
			}		
						
			return obj;					
		}

	}
}
/**
 * Inner class which restricts contructor access to Private
 */
class PrivateEntityCache {}
