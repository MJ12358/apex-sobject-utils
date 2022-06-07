@IsTest
public class FieldSetUtilTest {

  // Cannot create a fieldset within a test
  // all i can check here is failures

  @IsTest
	static void testGetFields() {
		Test.startTest();
		List<String> fields = FieldSetUtil.getFields('Account', 'FieldSet');
		Test.stopTest();
		System.assert(fields.isEmpty());
	}

	@IsTest
	static void testGetDescribed() {
		Test.startTest();
		List<Schema.DescribeFieldResult> result = FieldSetUtil.getDescribed('Account', 'FieldSet');
		Test.stopTest();
		System.assert(result.isEmpty());
	}

  @IsTest
  static void testGetDescribedForAura() {
    Test.startTest();
    String result = FieldSetUtil.getDescribedForAura('Account', 'FieldSet');
    Test.stopTest();
  }

}
