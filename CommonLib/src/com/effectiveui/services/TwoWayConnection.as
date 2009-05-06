package com.effectiveui.services
{
	import flash.events.AsyncErrorEvent;
	import flash.events.EventDispatcher;
	import flash.events.SecurityErrorEvent;
	import flash.events.StatusEvent;
	import flash.net.LocalConnection;
	
	import mx.controls.Alert;
	
	public class TwoWayConnection extends EventDispatcher
	{
		private var outgoing:LocalConnection;
		private var incoming:LocalConnection;
		private var name:String;
		private var outgoingName:String;
		private var incomingName:String;
		
		public function TwoWayConnection(name:String)
		{
			this.name=name;	
		}
		
		public function listen():void {
			incoming = new LocalConnection();
			incoming.addEventListener(AsyncErrorEvent.ASYNC_ERROR,onIncomingAsyncError);
			incoming.addEventListener(StatusEvent.STATUS,onIncomingStatusEvent);
			incoming.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onIncomingSecurityError);
			incoming.allowDomain("*");
			incoming.allowDomain("localhost");
			incoming.client = this;
			var listeningConnection:String = "_" + name + "-receive";
			
			try {
				incoming.connect(listeningConnection);
			} catch (error:ArgumentError) {
				trace("Can't connect, " + listeningConnection + " is already being used");
			}
		}
		
		public function connectToServer(serverName:String):void {
			listen();
			incomingName = serverName;
			
			outgoing = new LocalConnection();
			outgoing.addEventListener(AsyncErrorEvent.ASYNC_ERROR,onOutgoingAsyncError);
			outgoing.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onOutgoingSecurityError);
			outgoing.addEventListener(StatusEvent.STATUS,onOutgoingStatusEvent);
			outgoingName = "_" + serverName + "-receive";
			outgoing.send(outgoingName,"onClientConnect",name);
		}
		
		public function onClientConnect(clientName:String):void {
			incomingName = clientName;
			trace(name + " received connection from " + clientName);
			
			outgoing = new LocalConnection();
			outgoing.addEventListener(AsyncErrorEvent.ASYNC_ERROR,onOutgoingAsyncError);
			outgoing.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onOutgoingSecurityError);
			outgoing.addEventListener(StatusEvent.STATUS,onOutgoingStatusEvent);
			outgoingName = "_" + clientName + "-receive";
		}
		
		public function onReceive(message:String,args:Object):void {
			//Alert.show(name + " received " + message + " from " + incomingName);
			dispatchEvent(new IncomingMessageEvent(message,args));
		}
		
		public function send(message:String,args:Object):void {	
			if (!outgoingName) {
				trace("You must first connect to a server or have a client connected to you");
				return;
			}
			trace("Sending " + message + " to " + outgoingName);
			outgoing.send(outgoingName,"onReceive",message,args);
		}
		
		private function onIncomingAsyncError(e:AsyncErrorEvent):void {
			trace("incoming received async error " + e.text);
		}
		private function onIncomingStatusEvent(e:StatusEvent):void {
			trace("incoming receive status event " + e.level);	
		}
		private function onIncomingSecurityError(e:SecurityErrorEvent):void {
			trace("incoming receive security error " + e.text);	
		}
		
		private function onOutgoingAsyncError(e:AsyncErrorEvent):void {
			trace("outgoing received async error " + e.text);
		}
		private function onOutgoingStatusEvent(e:StatusEvent):void {
			trace("outgoing receive status event " + e.level);	
		}
		private function onOutgoingSecurityError(e:SecurityErrorEvent):void {
			trace("outgoing receive security error " + e.text);	
		}
		
	}
}