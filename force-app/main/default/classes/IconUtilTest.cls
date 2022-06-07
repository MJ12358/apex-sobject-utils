@IsTest
public class IconUtilTest {

  @IsTest
	static void getGetLightningIcon() {
		Test.startTest();
		for (Schema.SObjectType sObjectType : SObjectUtil.globalDescribe.values()) {
			String result = IconUtil.getLightningIcon(sObjectType.newSObject());
			System.assert(String.isNotBlank(result));
		}
		Test.stopTest();
	}

}