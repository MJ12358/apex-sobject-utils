@IsTest
public class SObjectMatcherTest {

	@TestSetup
	static void testSetup() {
		List<Account> accounts = new List<Account>();
		accounts.add(new AccountFactory()
			.put(Account.Name, 'Test Number1')
			.put(Account.Email__c, 'test1@test.com')
			.put(Account.Phone, '(123) 456-7890')
			.build()
			.getRecord()
		);
		accounts.add(new AccountFactory()
			.put(Account.Name, 'Test Number2')
			.put(Account.Phone, '(123) 456-7890')
			.build()
			.getRecord()
		);
		accounts.add(new AccountFactory()
			.put(Account.Name, 'Test Number3')
			.put(Account.AnnualRevenue, 123456.789)
			.put(Account.Phone, '(123) 456-7890')
			.build()
			.getRecord()
		);
		insert accounts;
	}

	@IsTest
	static void testError1() {
		Test.startTest();
		try {
			new SObjectMatcher(Account.SObjectType, null);
			System.assert(false, 'Expected an exception');
		} catch (SObjectMatcherException e) {
			System.assert(true, 'Exception caught');
		}
		Test.stopTest();
	}

	@IsTest
	static void testError2() {
		Map<Schema.SObjectField, Object> fieldMap = new Map<Schema.SObjectField, Object>{
			Account.Name => 'Test Number1',
			Account.Email__c => 'test1@test.com',
			Account.Phone => '123-456-7890',
			Account.CreatedDate => Date.today()
		};
		Test.startTest();
		try {
			new SObjectMatcher(Account.SObjectType, fieldMap).setThreshold(4);
			System.assert(false, 'Expected an exception');
		} catch (SObjectMatcherException e) {
			System.assert(true, 'Exception caught');
		}
		Test.stopTest();
	}

	@IsTest
	static void testNumber1() {
		Map<Schema.SObjectField, Object> fieldMap = new Map<Schema.SObjectField, Object>{
			Account.Name => 'Test Number1',
			Account.Email__c => 'test1@test.com',
			Account.Phone => '123-456-7890',
			Account.CreatedDate => Date.today()
		};
		List<Account> accounts = [SELECT Name, Email__c, Phone, CreatedDate FROM Account];
		Test.startTest();
		SObjectMatcher matcher = new SObjectMatcher(Account.SObjectType, fieldMap).find(accounts);
		Integer confidence = matcher.getConfidence();
		SObject result = matcher.getRecord();
		Test.stopTest();
		System.assertEquals(3, confidence);
		System.assertNotEquals(null, result);
		System.assertEquals(Account.SObjectType, result.getSObjectType());
	}

	@IsTest
	static void testNumber2() {
		Map<Schema.SObjectField, Object> fieldMap = new Map<Schema.SObjectField, Object>{
			Account.Name => 'Test Number2',
			Account.CreatedDate => '1897-07-07',
			Account.Phone => '123-456-7890'
		};
		List<Account> accounts = [SELECT Name, CreatedDate, Phone FROM Account];
		Test.startTest();
		SObjectMatcher matcher = new SObjectMatcher(Account.SObjectType, fieldMap).find(accounts);
		Integer confidence = matcher.getConfidence();
		SObject result = matcher.getRecord();
		Test.stopTest();
		System.assertEquals(2, confidence);
		System.assertNotEquals(null, result);
		System.assertEquals(Account.SObjectType, result.getSObjectType());
	}

	@IsTest
	static void testNumber3() {
		Map<Schema.SObjectField, Object> fieldMap = new Map<Schema.SObjectField, Object>{
			Account.Name => 'Test Number3',
			Account.AnnualRevenue => 123456.789,
			Account.Phone => '123-456-7890'
		};
		List<Account> accounts = [SELECT Name, AnnualRevenue, Phone FROM Account];
		Test.startTest();
		SObjectMatcher matcher = new SObjectMatcher(Account.SObjectType, fieldMap).find(accounts);
		Integer confidence = matcher.getConfidence();
		SObject result = matcher.getRecord();
		Test.stopTest();
		System.assertEquals(3, confidence);
		System.assertNotEquals(null, result);
		System.assertEquals(Account.SObjectType, result.getSObjectType());
	}

	@IsTest
	static void testNoResult() {
		Map<Schema.SObjectField, Object> fieldMap = new Map<Schema.SObjectField, Object>{
			Account.Name => 'Not Found',
			Account.Email__c => 'tbd@tbd.com',
			Account.Phone => '9876543210'
		};
		List<Account> accounts = [SELECT Name, Email__c, Phone FROM Account];
		Test.startTest();
		SObjectMatcher matcher = new SObjectMatcher(Account.SObjectType, fieldMap).find(accounts);
		Integer confidence = matcher.getConfidence();
		SObject result = matcher.getRecord();
		Test.stopTest();
		System.assertEquals(0, confidence);
		System.assertEquals(null, result);
	}

	@IsTest
	static void testGenerateQuery() {
		Map<Schema.SObjectField, Object> fieldMap = new Map<Schema.SObjectField, Object>{
			Account.Name => 'Test Number1',
			Account.Email__c => 'test1@test.com',
			Account.Phone => '123-456-7890'
		};
		Test.startTest();
		SObjectMatcher matcher = new SObjectMatcher(Account.SObjectType, fieldMap).find();
		Integer confidence = matcher.getConfidence();
		SObject result = matcher.getRecord();
		Test.stopTest();
		System.assertEquals(3, confidence);
		System.assertNotEquals(null, result);
		System.assertEquals(Account.SObjectType, result.getSObjectType());
	}

	@IsTest
	static void testGenerateQueryComplex() {
		Map<Schema.SObjectField, Object> fieldMap = new Map<Schema.SObjectField, Object>{
			Account.Id => [SELECT Id FROM Account LIMIT 1].Id,
			Account.Name => 'Test Number3',
			Account.AnnualRevenue => 123456.789,
			Account.Phone => '123-456-7890',
			Account.CreatedDate => Datetime.now()
		};
		Test.startTest();
		SObjectMatcher matcher = new SObjectMatcher(Account.SObjectType, fieldMap).find();
		Integer confidence = matcher.getConfidence();
		SObject result = matcher.getRecord();
		Test.stopTest();
		System.assertEquals(3, confidence);
		System.assertNotEquals(null, result);
		System.assertEquals(Account.SObjectType, result.getSObjectType());
	}

	@IsTest
	static void testGenerateQueryEmptyValue() {
		Map<Schema.SObjectField, Object> fieldMap = new Map<Schema.SObjectField, Object>{
			Account.Name => 'Test Number1',
			Account.Email__c => '',
			Account.Phone => null
		};
		Test.startTest();
		SObjectMatcher matcher = new SObjectMatcher(Account.SObjectType, fieldMap).find();
		Integer confidence = matcher.getConfidence();
		SObject result = matcher.getRecord();
		Test.stopTest();
		System.assertEquals(1, confidence);
		System.assertNotEquals(null, result);
		System.assertEquals(Account.SObjectType, result.getSObjectType());
	}

	@IsTest
	static void testGenerateQueryAllEmptyValues() {
		Map<Schema.SObjectField, Object> fieldMap = new Map<Schema.SObjectField, Object>{
			Account.Name => '',
			Account.Email__c => '',
			Account.Phone => null
		};
		Test.startTest();
		SObjectMatcher matcher = new SObjectMatcher(Account.SObjectType, fieldMap).find();
		Integer confidence = matcher.getConfidence();
		SObject result = matcher.getRecord();
		Test.stopTest();
		System.assertEquals(0, confidence);
		System.assertEquals(null, result);
	}

	@IsTest
	static void testGenerateQueryDateString() {
		Map<Schema.SObjectField, Object> fieldMap = new Map<Schema.SObjectField, Object>{
			Account.Name => 'Test Number1',
			Account.CreatedDate => '2020-01-01'
		};
		Test.startTest();
		SObjectMatcher matcher = new SObjectMatcher(Account.SObjectType, fieldMap).find();
		Integer confidence = matcher.getConfidence();
		SObject result = matcher.getRecord();
		Test.stopTest();
		System.assertEquals(1, confidence);
		System.assertNotEquals(null, result);
		System.assertEquals(Account.SObjectType, result.getSObjectType());
	}

}
