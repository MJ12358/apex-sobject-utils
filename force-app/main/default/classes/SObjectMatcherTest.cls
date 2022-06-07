@IsTest
public class SObjectMatcherTest {

  private static Double revenue = 123456.789;
  private static String phone = '(123) 456-7890';

	@TestSetup
	static void testSetup() {
		List<Account> accounts = new List<Account>();

    Account acc1 = new Account();
    acc1.Name = 'Test Number1';
    acc1.Phone = phone;
    accounts.add(acc1);

    Account acc2 = new Account();
    acc2.Name = 'Test Number2';
    acc2.Phone = phone;
    accounts.add(acc2);

    Account acc3 = new Account();
    acc3.Name = 'Test Number3';
    acc3.AnnualRevenue = revenue;
    acc3.Phone = phone;
    accounts.add(acc3);

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
			Account.Phone => phone,
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
			Account.Phone => phone,
			Account.CreatedDate => Date.today()
		};
		List<Account> accounts = [SELECT Name, Phone, CreatedDate FROM Account];
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
	static void testNumber2() {
		Map<Schema.SObjectField, Object> fieldMap = new Map<Schema.SObjectField, Object>{
			Account.Name => 'Test Number2',
			Account.CreatedDate => '1897-07-07',
			Account.Phone => phone
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
			Account.AnnualRevenue => revenue,
			Account.Phone => phone
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
			Account.Phone => '9876543210'
		};
		List<Account> accounts = [SELECT Name, Phone FROM Account];
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
			Account.Phone => phone
		};
		Test.startTest();
		SObjectMatcher matcher = new SObjectMatcher(Account.SObjectType, fieldMap).find();
		Integer confidence = matcher.getConfidence();
		SObject result = matcher.getRecord();
		Test.stopTest();
		System.assertEquals(2, confidence);
		System.assertNotEquals(null, result);
		System.assertEquals(Account.SObjectType, result.getSObjectType());
	}

	@IsTest
	static void testGenerateQueryComplex() {
		Map<Schema.SObjectField, Object> fieldMap = new Map<Schema.SObjectField, Object>{
			Account.Id => [SELECT Id FROM Account LIMIT 1].Id,
			Account.Name => 'Test Number3',
			Account.AnnualRevenue => revenue,
			Account.Phone => phone
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
