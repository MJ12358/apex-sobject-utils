@IsTest
public class SObjectSelectorTest {

	private static Integer count = 1;
	private static TestSObjectSelector selector;

	@TestSetup
	static void testSetup() {
		Account acc = new Account();
		acc.Name = 'Test0';
		insert acc;
	}

	static {
		selector = new TestSObjectSelector();
	}

	@IsTest
	static void testGetFieldListString() {
		System.assertNotEquals(null, selector.getFieldListString());
	}

	@IsTest
	static void testGetRelatedFieldListString() {
		System.assert(String.isNotBlank(selector.getRelatedFieldListString('Parent')));
	}
	
	@IsTest
	static void testGetSObjectName() {
		System.assertEquals('Account', selector.getSObjectName());
	}

	@IsTest
	static void testSelectCount() {
		List<Account> accounts = [SELECT Id FROM Account];
		Test.startTest();
		Integer result = selector.selectCount('Id', accounts[0].Id);
		Test.stopTest();
		System.assertNotEquals(null, result, 'Result count must be returned');
	}

	@IsTest
	static void testSelectCountAll() {
		Test.startTest();
		Integer result = selector.selectCount();
		Test.stopTest();
		System.assertNotEquals(null, result, 'Result count must be returned');
	}

	@IsTest
	static void testSelectCountAllByIsActive() {
		Test.startTest();
		Integer result = selector.selectCountByIsActive();
		Test.stopTest();
		System.assertNotEquals(null, result, 'Result count must be returned');
	}

	@IsTest
	static void testSelectAll() {
		Test.startTest();
		List<Account> results = selector.selectAll();
		Test.stopTest();
		System.assert(results.size() > 0, 'Results must be returned');
		System.assertEquals(Account.SObjectType, results.getSObjectType());
	}
	
	@IsTest
	static void testSelectSObjectsById() {
		// Inserting in reverse order so that we can test the order by of select 
		List<Account> accountList = new List<Account> {
			new Account(Name = 'TestAccount2', AccountNumber = 'A2', AnnualRevenue = 12345.67),
			new Account(Name = 'TestAccount1', AccountNumber = 'A1', AnnualRevenue = 76543.21)
		};
		insert accountList;		
		Set<Id> idSet = new Set<Id>();
		for(Account item : accountList) {
			idSet.add(item.Id);
		}
			
		Test.startTest();
		Account result = (Account)selector.selectById(new List<Id>(idSet)[0]);
		List<Account> results = (List<Account>)selector.selectById(idSet);		
		Test.stopTest();
		
		System.assertNotEquals(null, result);
		System.assertEquals(2, results.size());
		System.assertEquals('TestAccount1', results[1].Name);
		System.assertEquals('A1', results[1].AccountNumber);
		System.assertEquals(76543.21, results[1].AnnualRevenue);
		System.assertEquals('TestAccount2', results[0].Name);
		System.assertEquals('A2', results[0].AccountNumber);
		System.assertEquals(12345.67, results[0].AnnualRevenue);
	}

	@IsTest
	static void testSelectSObjectsByIsActive() {
		Test.startTest();
		List<Account> results = selector.selectByIsActive();
		Test.stopTest();
		System.assert(results.size() > 0, 'Result count must be returned');
	}

	@IsTest
	static void testSelectAllSObjectFields() {
		Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id FROM Account]);
		Test.startTest();
		List<Account> results = selector.selectById(accounts.keySet());
		Test.stopTest();
		System.assertEquals(count, results.size(), 'Results must be returned');
		System.assertEquals(Account.SObjectType, results.getSObjectType());
	}
	
	@IsTest
	static void testAssertIsAccessible() {
		List<Account> accountList = new List<Account> {
			new Account(Name = 'TestAccount2', AccountNumber = 'A2', AnnualRevenue = 12345.67),
			new Account(Name = 'TestAccount1', AccountNumber = 'A1', AnnualRevenue = 76543.21)
		};		
		insert accountList;		
		Set<Id> idSet = new Set<Id>();
		for (Account item : accountList) {
			idSet.add(item.Id);
		}
		
		// Create a user which will not have access to the test object type
		// User testUser = new UserFactory().asRestricted().buildAndInsert().getRecord();
		User testUser = new User();
		// System.runAs(testUser) {
		// 	try {
		// 		TestSObjectSelector testSelector = new TestSObjectSelector();
		// 		List<SObject> result = testSelector.selectById(idSet);
		// 		System.assert(false, 'Expected an exception');
		// 	} catch (CrudException e) {
		// 		System.assert(true, 'Exception caught');
		// 	} catch (Exception e) {
		// 		System.assert(false, 'Expected a CrudException');
		// 	}
		// }
	}

	@IsTest
	static void testLimitError() {
		Test.startTest();
		try {
			new TestSObjectSelector().setLimit(50001);
			System.assert(false, 'Expected an exception');
		} catch (SObjectSelectorException e) {
			System.assert(true, 'Exception caught');
		}
		Test.stopTest();
	}

	@IsTest
	static void testGeneric() {
		Test.startTest();
		List<SObject> records1 = new SObjectSelector.Generic(Account.SObjectType).selectAll();
		List<SObject> records2 = new SObjectSelector.Generic(Account.SObjectType, true).selectAll();
		List<SObject> records3 = new SObjectSelector.Generic(Account.SObjectType, true, true).selectAll();
		Test.stopTest();
		System.assertEquals(count, records1.size());
		System.assertEquals(count, records2.size());
		System.assertEquals(count, records3.size());
	}
	
	private class TestSObjectSelector extends SObjectSelector {
		
		public Schema.SObjectType getSObjectType() {
			return Account.SObjectType;
		}
		
	}

}