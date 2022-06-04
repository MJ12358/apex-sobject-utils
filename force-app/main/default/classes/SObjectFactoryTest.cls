@IsTest
private class SObjectFactoryTest {

	private static Integer count = 3;

	@IsTest
	static void testError() {
		Test.startTest();
		try {
			new SObjectFactoryMock().getRecord();
			System.assert(false, 'Expected an exception');
		} catch (SObjectFactoryException e) {
			System.assert(true, 'Exception caught');
		}
		Test.stopTest();
	}

	@IsTest
	static void buildRecords() {
		Test.startTest();
		List<Account> testAccounts = new SObjectFactoryMock(count).build().getRecords();
		Test.stopTest();
		System.assertEquals(count, testAccounts.size(),
			'The correct number of records should have been built');
		for (Account testAccount : testAccounts) {
			System.assertNotEquals(null, testAccount, 'Null should never be returned');
		}
	}

	@IsTest
	static void buildAndInsertRecords() {
		Test.startTest();
		List<Account> testAccounts = new SObjectFactoryMock(count).buildAndInsert().getRecords();
		Test.stopTest();
		System.assertEquals(count, testAccounts.size(),
			'The correct number of records should have been built');
		for (Account testAccount : testAccounts) {
			System.assertNotEquals(null, testAccount.Id, 'All of the accounts should have been inserted');
		}
	}

	@IsTest
	static void buildRecord() {
		Test.startTest();
		Account record = new SObjectFactoryMock().build().getRecord();
		Test.stopTest();
		System.assertNotEquals(null, record, 'Null should never be returned');
	}

	@IsTest
	static void buildAndInsertRecord() {
		Test.startTest();
		Account record = new SObjectFactoryMock().buildAndInsert().getRecord();
		Test.stopTest();
		System.assertNotEquals(null, record, 'Null should never be returned');
		System.assertNotEquals(null, record.Id, 'The record should have been inserted');
	}

	@IsTest
	static void testPutField() {
		Test.startTest();
		Account record = new SObjectFactoryMock().put(Account.Name, 'Test Account').buildAndInsert().getRecord();
		Test.stopTest();
		System.assertEquals('Test Account', record.Name);
	}

	@IsTest
	static void testGenericSObject() {
		Test.startTest();
		SObjectFactoryMock factory = new SObjectFactoryMock();
		Account record = factory.put(Account.ParentId, factory.provideSObject(Account.SObjectType)).buildAndInsert().getRecord();
		Test.stopTest();
		System.assertNotEquals(null, record.ParentId);
	}

	@IsTest
	static void testProfiles() {
		SObjectFactoryMock factory = new SObjectFactoryMock();
		Test.startTest();
		Id adminId = factory.getAdminProfile();
		Id standardId = factory.getStandardProfile();
		Id restrictedId = factory.getRestrictedProfile();
		Test.stopTest();
		System.assertNotEquals(null, adminId);
		System.assertNotEquals(null, standardId);
		System.assertNotEquals(null, restrictedId);
	}

	@IsTest
	static void testFailure() {
		Test.startTest();
		SObjectFactoryMock factory = new SObjectFactoryMock();
		factory.put(Account.Name, 'Test Account');
		try {
			factory.buildAndInsert();
			System.assert(false, 'Expected an exception');
		} catch (Exception e) {
			System.assert(true, 'Exception caught');
		}
		Test.stopTest();
	}

	//* SObject factory mock

	private class SObjectFactoryMock extends SObjectFactory {

		public Schema.SObjectType getSObjectType() {
			return Account.SObjectType;
		}

		public override Map<Schema.SObjectField, Object> getDefaultFieldToValue() {
			return new Map<Schema.SObjectField, Object>{
				Account.AnnualRevenue => SObjectFactory.DEFAULT_VALUE,
				Account.BillingLatitude => SObjectFactory.DEFAULT_VALUE,
				Account.BillingLongitude => SObjectFactory.DEFAULT_VALUE,
				Account.Description => SObjectFactory.DEFAULT_VALUE, 
				Account.Industry => SObjectFactory.DEFAULT_VALUE,
				Account.NumberOfEmployees => SObjectFactory.DEFAULT_VALUE,
				Account.Phone => SObjectFactory.DEFAULT_VALUE,
				Account.Website => SObjectFactory.DEFAULT_VALUE
			};
		}

		public SObjectFactoryMock() {
			super();
		}

		public SObjectFactoryMock(Integer count) {
			super(count);
		}

		public SObjectFactoryMock put(Schema.SObjectField field, Object value) {
			putField(field, value);
			return this;
		}

		public SObjectFactoryMock build() {
			buildRecords();
			return this;
		}

		public SObjectFactoryMock buildAndInsert() {
			buildAndInsertRecords();
			return this;
		}

		public Account getRecord() {
			return (Account)getSObjectRecord();
		}

		public List<Account> getRecords() {
			return (List<Account>)getSObjectRecords();
		}

	}

}