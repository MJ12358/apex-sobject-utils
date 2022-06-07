@IsTest
public class DuplicateFinderTest {

	private static List<Account> getAccounts(Integer count) {
    List<Account> results = new List<Account>();
    for (Integer i = 0; i < count; i++) {
      Account acc = new Account();
      acc.Name = 'Test Account';
      acc.BillingStreet = '123 Right Here';
      acc.BillingCity = 'City';
      acc.BillingState = 'NY';
      results.add(acc);
    }
		return results;
	}

	private static Account getAccount() {
		return getAccounts(1).get(0);
	}

	@IsTest
	static void testDuplicate() {
		insert getAccounts(3);
		Test.startTest();
		DuplicateFinder finder = new DuplicateFinder().find(getAccount());
    SObject result = finder.getRecord();
    List<SObject> results = finder.getRecords();
		Test.stopTest();
		System.assertNotEquals(null, result);
    System.assertEquals(3, results.size());
	}

	@IsTest
	static void testDuplicateById() {
		insert getAccounts(3);
		Account acc = [SELECT Id FROM Account LIMIT 1];
		Test.startTest();
		SObject result = new DuplicateFinder().find(acc.Id).getRecord();
		Test.stopTest();
		System.assertNotEquals(null, result);
	}

	@IsTest
	static void testNoDuplicate() {
		Test.startTest();
		SObject result = new DuplicateFinder().find(getAccount()).getRecord();
		Test.stopTest();
		System.assertEquals(null, result);
	}

	@IsTest
	static void testNoDuplicateRuleForSObject() {
		Opportunity opp = new Opportunity();
		opp.AccountId = SObjectUtil.getFakeId(Opportunity.SObjectType);
		Test.startTest();
		try {
			new DuplicateFinder().find(opp);
			System.assert(false, 'Expected an exception');
		} catch (DuplicateFinderException e) {
			System.assert(true, 'Exception caught');
		}
		Test.stopTest();
	}

	@IsTest
	static void testConfidence() {
		insert getAccount();
		Test.startTest();
		SObject result = new DuplicateFinder().setConfidence(6).find(getAccount()).getRecord();
		Test.stopTest();
		System.assertNotEquals(null, result);
	}

	@IsTest
	static void testConfidenceError() {
		Test.startTest();
		try {
			new DuplicateFinder().setConfidence(1);
			System.assert(false, 'Expected an exception');
		} catch (DuplicateFinderException e) {
			System.assert(true, 'Exception caught');
		}
		Test.stopTest();
	}

	@IsTest
	static void testRuleNameError() {
		Test.startTest();
		try {
			new DuplicateFinder('invalid_rule_name');
			System.assert(false, 'Expected and exception');
		} catch (DuplicateFinderException e) {
			System.assert(true, 'Exception caught');
		}
		Test.stopTest();
	}

	@IsTest
	static void testGetRecordPopulated() {
		insert getAccount();
		Test.startTest();
		SObject result = new DuplicateFinder().find(getAccount()).getRecordPopulated();
		Test.stopTest();
		System.assertNotEquals(null, result);
	}

}
