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
    SObjectFactory factory = new SObjectFactoryMock(count);
    factory.build();
		List<Contact> records = (List<Contact>)factory.getRecords();
		Test.stopTest();
		System.assertEquals(count, records.size(),
			'The correct number of records should have been built');
		for (Contact cont : records) {
			System.assertNotEquals(null, cont, 'Null should never be returned');
		}
	}

	@IsTest
	static void buildAndInsertRecords() {
		Test.startTest();
    SObjectFactory factory = new SObjectFactoryMock(count);
    factory.buildAndInsert();
		List<Contact> records = (List<Contact>)factory.getRecords();
		Test.stopTest();
		System.assertEquals(count, records.size(),
			'The correct number of records should have been built');
		for (Contact acc : records) {
			System.assertNotEquals(null, acc.Id, 'All of the accounts should have been inserted');
		}
	}

	@IsTest
	static void buildRecord() {
		Test.startTest();
    SObjectFactoryMock factory = new SObjectFactoryMock(count);
    factory.build();
		Contact record = (Contact)factory.getRecord();
		Test.stopTest();
		System.assertNotEquals(null, record, 'Null should never be returned');
	}

	@IsTest
	static void buildAndInsertRecord() {
		Test.startTest();
    SObjectFactoryMock factory = new SObjectFactoryMock(count);
    factory.buildAndInsert();
		Contact record = (Contact)factory.getRecord();
		Test.stopTest();
		System.assertNotEquals(null, record, 'Null should never be returned');
		System.assertNotEquals(null, record.Id, 'The record should have been inserted');
	}

	@IsTest
	static void testPutField() {
		Test.startTest();
    SObjectFactoryMock factory = new SObjectFactoryMock(count);
    factory.put(Contact.LastName, 'Test Contact');
    factory.buildAndInsert();
		Contact record = (Contact)factory.getRecord();
		Test.stopTest();
		System.assertEquals('Test Contact', record.LastName);
	}

	@IsTest
	static void testGenericSObject() {
		Test.startTest();
    SObjectFactoryMock factory = new SObjectFactoryMock(count);
    factory.put(Contact.AccountId, Account.SObjectType);
    factory.buildAndInsert();
		Contact record = (Contact)factory.getRecord();
		Test.stopTest();
		System.assertNotEquals(null, record.AccountId);
	}

	@IsTest
	static void testProfiles() {
		Test.startTest();
    SObjectFactoryMock factory = new SObjectFactoryMock();
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
		factory.put(Contact.LastName, '');
		try {
			factory.buildAndInsert();
			System.assert(false, 'Expected an exception');
		} catch (Exception e) {
			System.assert(true, 'Exception caught');
		}
		Test.stopTest();
	}

  @IsTest
  static void testMergeFields() {
    Test.startTest();
    SObjectFactoryMock factory = new SObjectFactoryMock();
    factory.put(Contact.LastName, 'Test{!index}');
    factory.put(Contact.Description, '{!rand}');
    factory.build();
    Contact record = (Contact)factory.getRecord();
    Test.stopTest();
    System.assertEquals('Test0', record.LastName);
    System.assert(String.isNotBlank(record.Description));
  }

	//* SObject factory mock

	private class SObjectFactoryMock extends SObjectFactory {

		public Schema.SObjectType getSObjectType() {
			return Contact.SObjectType;
		}

		public override Map<Schema.SObjectField, Object> getDefaultFieldToValue() {
			return new Map<Schema.SObjectField, Object>{
				Contact.Birthdate => SObjectFactory.DEFAULT_VALUE,
        Contact.DoNotCall => SObjectFactory.DEFAULT_VALUE,
        Contact.Email =>  SObjectFactory.DEFAULT_VALUE,
        Contact.LeadSource => SObjectFactory.DEFAULT_VALUE,
        Contact.MobilePhone => SObjectFactory.DEFAULT_VALUE,
        Contact.Title => SObjectFactory.DEFAULT_VALUE
			};
		}

		public SObjectFactoryMock() {
			super();
		}

		public SObjectFactoryMock(Integer count) {
			super(count);
		}

	}

}