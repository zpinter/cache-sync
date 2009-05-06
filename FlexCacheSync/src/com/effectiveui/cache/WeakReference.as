package com.effectiveui.cache
{
	import flash.utils.Dictionary;
	
	public class WeakReference
	{
		
		private var dic:Dictionary;
		
		public function WeakReference(obj:*)
		{
			dic = new Dictionary(true);
			dic[obj] = 1;
		}
		
		public function getValue():* {
			for (var item:* in dic) {
				return item;
			}
			return null;
		}

	}
}