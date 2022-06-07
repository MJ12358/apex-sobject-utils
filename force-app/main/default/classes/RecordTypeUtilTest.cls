@IsTest
public class RecordTypeUtilTest {

  // Insert not allowed on RecordType
  // all i can check for in that they dont exist

  private static String recordTypeId = SObjectUtil.getFakeId(Account.SObjectType);

  @TestSetup
  static void testSetup() {
    Account acc = new Account();
    acc.Name = 'Test Account';
    insert acc;
  }

  @IsTest
  static void testGet() {
    Test.startTest();
    Map<Id, String> result = RecordTypeUtil.get('Account');
    Test.stopTest();
    // System.assert(result.size() == 0);
  }

  @IsTest
	static void testGetId() {
    Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
		Test.startTest();
		Id result1 = RecordTypeUtil.getId('Account', 'RT1');
    Id result2 = RecordTypeUtil.getId(acc, 'RT1');
		Test.stopTest();
		System.assertEquals(null, result1);
    System.assertEquals(null, result2);
	}

	@IsTest
	static void testGetLabel() {
    Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
		Test.startTest();
		String result1 = RecordTypeUtil.getLabel('Account', recordTypeId);
    String result2 = RecordTypeUtil.getLabel(acc, recordTypeId);
		Test.stopTest();
		System.assertEquals(null, result1);
    System.assertEquals(null, result2);
	}

	@IsTest
	static void testGetName() {
    Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
		Test.startTest();
		String result1 = RecordTypeUtil.getName('Account', recordTypeId);
    String result2 = RecordTypeUtil.getName(acc, recordTypeId);
		Test.stopTest();
		System.assertEquals(null, result1);
    System.assertEquals(null, result2);
	}

}
