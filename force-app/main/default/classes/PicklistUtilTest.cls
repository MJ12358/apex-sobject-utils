@IsTest
public class PicklistUtilTest {

  @IsTest
	static void testGetLabels() {
		Test.startTest();
		List<String> picklist = PicklistUtil.getLabels('Account', 'Type');
		Test.stopTest();
		System.assert(picklist.size() > 0, 'Picklist labels must be returned');
	}

  @IsTest
	static void testGetValues() {
		Test.startTest();
		List<String> picklist = PicklistUtil.getValues('Account', 'Type');
		Test.stopTest();
		System.assert(picklist.size() > 0, 'Picklist values must be returned');
	}

  @IsTest
  static void testGetCountries() {
    Test.startTest();
    List<String> labels = PicklistUtil.getCountryLabels();
    List<String> values = PicklistUtil.getCountryValues();
    Test.stopTest();
  }

	@IsTest
	static void testGetStates() {
		Test.startTest();
		List<String> labels = PickListUtil.getStateLabels();
		List<String> values = PicklistUtil.getStateValues();
		Test.stopTest();
	}

}
