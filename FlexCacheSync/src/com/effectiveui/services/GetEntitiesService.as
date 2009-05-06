package com.effectiveui.services
{
	import flash.events.AsyncErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.StatusEvent;
	import flash.net.LocalConnection;
	
	public class GetEntitiesService
	{
		public var socket:TwoWayConnection;
		private static var _instance:GetEntitiesService;
		
		public function GetEntitiesService(access:PrivateEntityCache):void {
			
		}
		
		public static function getInstance():GetEntitiesService {
			if (_instance == null) _instance = new GetEntitiesService(new PrivateEntityCache);
			return _instance;
		}
		
		public function getEntities(ids:Array):void {
			for each (var id:String in ids) {
				socket.send("getEntity",id);
			}
		}

	}
	
}
class PrivateEntityCache {}