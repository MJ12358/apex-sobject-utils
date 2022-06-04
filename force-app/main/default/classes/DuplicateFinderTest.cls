@IsTest
public class DuplicateFinderTest {

	private static List<Account> getAccounts(Integer count) {
		Account acc = new Account();
		acc.Name = 'Test User';
		return new List<Account>{ acc };
	}

	private static Account getAccount() {
		return getAccounts(1).get(0);
	}

	@IsTest
	static void testDuplicate() {
		insert getAccounts(3);
		Test.startTest();
		SObject result = new DuplicateFinder().find(getAccount()).getRecord();
		Test.stopTest();
		System.assertNotEquals(null, result);
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
		// Opportunity opp = new OpportunityFactory().build().getRecord();
		Opportunity opp = new Opportunity();
		opp.AccountId = 'test';
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
