@IsTest
public class OptionDmlTest {

	private static Database.DMLOptions options;

	static {
		options = new Database.DMLOptions();
		options.AllowFieldTruncation = true;
		options.OptAllOrNone = true;
	}

	@IsTest
	static void testError() {
		Test.startTest();
		try {
			new OptionDml(null);
			System.assert(false, 'Excepted and exception');
		} catch (Exception e) {
			System.assert(true, 'Exception caught');
		}
		Test.stopTest();
	}

	@IsTest
	static void testInsert() {
		Test.startTest();
		SObjectUnitOfWork uow = new SObjectUnitOfWork(
			new List<Schema.SObjectType>{ Account.SObjectType },
			new OptionDml(options)
		);
		Account acc = new Account();
		acc.Name = 'Testing';
		uow.registerNew(acc);
		uow.commitWork();
		Test.stopTest();
		System.assertEquals(1, [SELECT Count() FROM Account]);
	}

	@IsTest
	static void testUpdate() {
		Account acc = new Account();
		acc.Name = 'Testing';
		insert acc;
		Test.startTest();
		SObjectUnitOfWork uow = new SObjectUnitOfWork(
			new List<Schema.SObjectType>{ Account.SObjectType },
			new OptionDml(options)
		);
		acc.Description = 'Description';
		uow.registerDirty(acc);
		uow.commitWork();
		Test.stopTest();
		System.assertEquals('Description', [SELECT Description FROM Account].Description);
	}

	@IsTest
	static void testUpsert() {
		Account acc = new Account();
		acc.Name = 'Testing';
		insert acc;
		Test.startTest();
		SObjectUnitOfWork uow = new SObjectUnitOfWork(
			new List<Schema.SObjectType>{ Account.SObjectType },
			new OptionDml(options)
		);
		acc.Description = 'Description';
		uow.registerUpsert(acc);
		uow.commitWork();
		Test.stopTest();
		System.assertEquals('Description', [SELECT Description FROM Account].Description);
	}

}
