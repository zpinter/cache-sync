package com.effectiveui.vo
{
	[Bindable]
	[RemoteClass(alias="com.effectiveui.vo.AddressVO")]
	public class AddressVO extends BaseVO
	{
		public var line1:String;
		public var line2:String;
		public var zip:String;
		public var city:String;
		public var state:String;
	}
}