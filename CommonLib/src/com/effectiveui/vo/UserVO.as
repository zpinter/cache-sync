package com.effectiveui.vo
{
	[Bindable]
	[RemoteClass(alias="com.effectiveui.vo.UserVO")]
	
	public class UserVO extends BaseVO
	{
		public var username:String;
		public var firstname:String;
		public var lastname:String;
		public var address:AddressVO;
		
		public function toString():String {
			var result:Array = [
				"username:" + username,			
				"firstname:" + firstname,
				"lastname:" + lastname
			];
			return result.join(", ");
		}
	}
}