package com.effectiveui.services
{
	import flash.events.Event;

	public class IncomingMessageEvent extends Event
	{
		public var args:Object;
		
		public function IncomingMessageEvent(type:String, args:Object,bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.args=args;
			super(type, bubbles, cancelable);
		}
		
	}
}