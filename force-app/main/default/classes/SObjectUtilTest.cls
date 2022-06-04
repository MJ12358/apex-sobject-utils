@IsTest
public class SObjectUtilTest {

	private static Integer count;

	// @TestSetup
	// static void testSetup() {
	// 	new UserFactory().asRestricted().buildAndInsert();
	// 	new AccountFactory(count).buildAndInsert();
	// }

	static {
		count = 2;
	}

	@IsTest
	static void testConvertIdToName() {
		List<Id> idList = new List<Id>();
		for (Account acc : [SELECT Id FROM Account]) {
			idList.add(acc.Id);
		}
		Test.startTest();
		String result1 = SObjectUtil.convertIdToName(idList[0]);
		String result2 = SObjectUtil.convertIdToName(idList);
		Test.stopTest();
		System.assertEquals('Account', result1);
		System.assertEquals('Account', result2);
	}

	@IsTest
	static void testConvertIdToType() {
		List<Id> idList = new List<Id>();
		for (Account acc : [SELECT Id FROM Account]) {
			idList.add(acc.Id);
		}
		Test.startTest();
		Schema.SObjectType result1 = SObjectUtil.convertIdToType(idList[0]);
		Schema.SObjectType result2 = SObjectUtil.convertIdToType(idList);
		Test.stopTest();
		System.assertEquals(Account.SObjectType, result1);
		System.assertEquals(Account.SObjectType, result2);
	}

	@IsTest
	static void testConvertNameToLabel() {
		Account acc = [SELECT Id FROM Account LIMIT 1];
		Test.startTest();
		String name = SObjectUtil.convertNameToLabel('Jobs__c');
		Test.stopTest();
		System.assertEquals('Job', name, 'SObject label must match Job');
	}

	@IsTest
	static void testConvertNameToType() {
		Test.startTest();
		Schema.SObjectType accountType = SObjectUtil.convertNameToType('Account');
		Schema.SObjectType workOrderType = SObjectUtil.convertNameToType('WorkOrder');
		Test.stopTest();
		System.assertEquals(Account.SObjectType, accountType);
		System.assertEquals(WorkOrder.SObjectType, workOrderType);
	}

	@IsTest
	static void testConvertFieldToType() {
		Test.startTest();
		Schema.SObjectField accountField = SObjectUtil.convertFieldToType(Account.SObjectType, 'Name');
		Schema.SObjectField workOrderField = SObjectUtil.convertFieldToType('WorkOrder', 'WorkOrderNumber');
		Test.stopTest();
		System.assertEquals(Account.Name, accountField);
		System.assertEquals(WorkOrder.WorkOrderNumber, workOrderField);
	}

	@IsTest
	static void testGetSObjectType() {
		Test.startTest();
		Schema.SObjectType accountType = SObjectUtil.getSObjectType(Account.Description);
		Schema.SObjectType contactType = SObjectUtil.getSObjectType(Contact.Name.getDescribe());
		Schema.SObjectType workOrderType = SObjectUtil.getSObjectType(WorkOrder.Status);
		Test.stopTest();
		System.assertEquals(Account.SObjectType, accountType);
		System.assertEquals(Contact.SObjectType, contactType);
		System.assertEquals(WorkOrder.SObjectType, workOrderType);
	}

	@IsTest
	static void testGetFieldValue() {
		Account acc = [SELECT Description, CreatedBy.Name FROM Account LIMIT 1];
		acc.Description = 'testing';
		update acc;
		Test.startTest();
		String description = (String)SObjectUtil.getFieldValue(acc, 'Description');
		String createdName = (String)SObjectUtil.getFieldValue(acc, 'CreatedBy.Name');
		Test.stopTest();
		System.assertEquals('testing', description);
		System.assert(String.isNotBlank(createdName));
	}

	@IsTest
	static void testGetAllFields() {
		Test.startTest();
		Map<String, Schema.SObjectField> fields = SObjectUtil.getAllFields('Account');
		Test.stopTest();
		System.assert(fields.keySet().size() > 0);
	}

	@IsTest
	static void testSelectById() {
		Account acc = [SELECT Id FROM Account LIMIT 1];
		Test.startTest();
		SObject result = SObjectUtil.selectById(acc.Id);
		Test.stopTest();
		System.assertNotEquals(null, result);
	}

	@IsTest
	static void testDeleteById() {
		Account acc = [SELECT Id FROM Account LIMIT 1];
		Test.startTest();
		SObjectUtil.deleteById(acc.Id);
		Test.stopTest();
		List<Account> accs = [SELECT Id FROM Account];
		System.assertEquals(count - 1, accs.size(), 'Record must be deleted');
	}

	@IsTest
	static void testDeleteRecordDml() {
		Account acc = [SELECT Id FROM Account LIMIT 1];
		// Delete the record to force a dml error during test
		delete acc;
		Test.startTest();
		try {
			SObjectUtil.deleteById(acc.Id);
			System.assert(false, 'Expected an exception');
		} catch (Exception e) {
			System.assert(true, 'Exception caught');
		}
		Test.stopTest();
		List<Account> accs = [SELECT Id FROM Account];
		System.assertEquals(count - 1, accs.size(), 'Record must be deleted');
	}

	@IsTest
	static void testDeleteRecordRestricted() {
		Account acc = [SELECT Id FROM Account LIMIT 1];
		User user = [SELECT Id FROM User WHERE Username LIKE '%restricteduser%' LIMIT 1];
		Test.startTest();
		System.runAs(user) {
			try {
				SObjectUtil.deleteById(acc.Id);
				System.assert(false, 'Expected an exception');
			} catch (Exception e) {
				System.assert(true, 'Exception caught');
			}
		}
		Test.stopTest();
		List<Account> accs = [SELECT Id FROM Account];
		System.assertEquals(count, accs.size(), 'Record must not be deleted');
	}

	@IsTest
	static void testUpdateRecords() {
		List<Account> accounts = [SELECT Name FROM Account];
		Test.startTest();
		for (Account acc : accounts) {
			acc.Name = 'Testing';
		}
		String json = System.JSON.serialize(accounts);
		SObjectUtil.updateRecords(json);
		Test.stopTest();
		for (Account acc : [SELECT Name FROM Account]) {
			System.assertEquals('Testing', acc.Name);
		}
	}

	@IsTest
	static void testUpdateRecord() {
		Account acc = [SELECT Id, Name FROM Account LIMIT 1];
		Test.startTest();
		acc.Name = 'Testing';
		String json = System.JSON.serialize(acc);
		SObjectUtil.updateRecord(json);
		Test.stopTest();
		System.assertEquals('Testing', [SELECT Name FROM Account WHERE Id = :acc.Id].Name);
	}

	// @IsTest
	// static void testCreateContentVersion() {
	// 	File file = new File();
	// 	file.body = 'ABCDE==';
	// 	file.name = 'Testing.jpg';
	// 	Account acc = [SELECT Id FROM Account LIMIT 1];
	// 	Test.startTest();
	// 	SObjectUtil.createContentVersion(new List<File>{ file }, acc.Id);
	// 	Test.stopTest();
	// 	System.assertEquals(1, [SELECT Count() FROM ContentVersion WHERE FirstPublishLocationId = :acc.Id]);
	// }

	@IsTest
	static void testGetFieldSetFields() {
		Test.startTest();
		List<String> fields = SObjectUtil.getFieldSetFields('WorkOrder', 'Related_List');
		Test.stopTest();
		System.assertNotEquals(null, fields, 'Field set must be returned');
	}

	@IsTest
	static void testGetFieldSetFieldsDesc() {
		Test.startTest();
		String result = SObjectUtil.getFieldSetFieldsDesc('WorkOrder', 'Related_List');
		Test.stopTest();
		System.assertNotEquals(null, result);
	}

	@IsTest
	static void testGetPicklistValues() {
		Test.startTest();
		List<String> picklist = SObjectUtil.getPicklistValues('Account', 'Type');
		Test.stopTest();
		System.assert(picklist.size() > 0, 'Picklist values must be returned');
	}

	// @IsTest
	// static void testGetCountryAndStatePicklistValues() {
	// 	Test.startTest();
	// 	List<String> countries = SObjectUtil.getCountryPicklistValues();
	// 	List<String> states = SObjectUtil.getStatePicklistValues();
	// 	Test.stopTest();
	// 	System.assert(countries.size() > 0);
	// 	System.assert(states.size() > 0);
	// }

	@IsTest
	static void testGetReferenceTo() {
		Test.startTest();
		Set<Schema.SObjectType> result = SObjectUtil.getReferenceTo('Task', 'WhoId');
		Test.stopTest();
		System.assertNotEquals(null, result);
	}

	@IsTest
	static void testGetAccessibleFields() {
		Test.startTest();
		List<String> results = SObjectUtil.getAccessibleFields('Account');
		Test.stopTest();
		System.assert(results.size() > 0);
	}

	@IsTest
	static void testGetAccessibleFieldsByType() {
		Test.startTest();
		List<String> results = SObjectUtil.getAccessibleFields('Account', Schema.DisplayType.PICKLIST);
		Test.stopTest();
		System.assert(results.size() > 0);
	}

	@IsTest
	static void testGetRecordTypeId() {
		Test.startTest();
		Id result = SObjectUtil.getRecordTypeId('Account', 'B2C');
		Test.stopTest();
		System.assertNotEquals(null, result);
	}

	@IsTest
	static void testGetRecordTypeLabel() {
		Id recordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'B2C' LIMIT 1].Id;
		Test.startTest();
		String result = SObjectUtil.getRecordTypeLabel('Account', recordTypeId);
		Test.stopTest();
		System.assertNotEquals(null, result);
	}

	@IsTest
	static void testGetRecordTypeName() {
		Id recordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'B2C' LIMIT 1].Id;
		Test.startTest();
		String result = SObjectUtil.getRecordTypeName('Account', recordTypeId);
		Test.stopTest();
		System.assertNotEquals(null, result);
	}

	@IsTest
	static void testGetRelationshipName() {
		Test.startTest();
		System.assertEquals('Account', SObjectUtil.getRelationshipName('Contact', 'AccountId'));
		System.assertEquals('Order', SObjectUtil.getRelationshipName('OrderItem', 'OrderId'));
		Test.stopTest();
	}

	@IsTest
	static void testGetChildRelationshipName() {
		Test.startTest();
		System.assertEquals('Contacts', SObjectUtil.getChildRelationshipName('Contact', 'AccountId'));
		System.assertEquals('OrderItems', SObjectUtil.getChildRelationshipName('OrderItem', 'OrderId'));
		Test.stopTest();
	}

	@IsTest
	static void testCopyToAddress() {
		User usr = [SELECT Address, Street FROM User LIMIT 1];
		User newUsr = new User();
		Test.startTest();
		SObjectUtil.copyToAddress(usr.Address, newUsr);
		Test.stopTest();
		System.assertEquals(usr.Street, newUsr.Street);
	}

	@IsTest
	static void testCopyToBillingAddress() {
		Account acc = [SELECT BillingAddress, BillingStreet FROM Account LIMIT 1];
		Account newAcc = new Account();
		Test.startTest();
		SObjectUtil.copyToBillingAddress(acc.BillingAddress, newAcc);
		Test.stopTest();
		System.assertEquals(acc.BillingStreet, newAcc.BillingStreet);
	}

	@IsTest
	static void testCopyToShippingAddress() {
		Account acc = [SELECT ShippingAddress, ShippingStreet FROM Account LIMIT 1];
		Account newAcc = new Account();
		Test.startTest();
		SObjectUtil.copyToShippingAddress(acc.ShippingAddress, newAcc);
		Test.stopTest();
		System.assertEquals(acc.ShippingStreet, newAcc.ShippingStreet);
	}

	@IsTest
	static void testIsAddressEmpty() {
		Account acc = new Account();
		WorkOrder wo = new WorkOrder();
		Test.startTest();
		System.assertEquals(true, SObjectUtil.isAddressEmpty(acc.ShippingAddress));
		System.assertEquals(true, SObjectUtil.isAddressEmpty(wo));
		wo.City = 'Testing';
		System.assertEquals(false, SObjectUtil.isAddressEmpty(wo));
		Test.stopTest();
	}

	@IsTest
	static void testIsBillingAddressEmpty() {
		Account acc = new Account();
		Test.startTest();
		System.assertEquals(true, SObjectUtil.isBillingAddressEmpty(acc));
		acc.BillingStreet = 'Testing';
		System.assertEquals(false, SObjectUtil.isBillingAddressEmpty(acc));
		Test.stopTest();
	}

	@IsTest
	static void testIsShippingAddressEmpty() {
		Account acc = new Account();
		Test.startTest();
		System.assertEquals(true, SObjectUtil.isShippingAddressEmpty(acc));
		acc.ShippingStreet = 'Testing';
		System.assertEquals(false, SObjectUtil.isShippingAddressEmpty(acc));
		Test.stopTest();
	}

	@IsTest
	static void testHasAddressChanged() {
		WorkOrder wo1 = new WorkOrder();
		WorkOrder wo2 = new WorkOrder();
		Test.startTest();
		System.assertEquals(false, SObjectUtil.hasAddressChanged(wo1, wo2));
		wo2.City = 'Testing';
		System.assertEquals(true, SObjectUtil.hasAddressChanged(wo1, wo2));
		Test.stopTest();
	}

	@IsTest
	static void testLightningIconName() {
		Test.startTest();
		for (Schema.SObjectType sObjectType : SObjectUtil.globalDescribe.values()) {
			String result = SObjectUtil.getLightningIconName(sObjectType.newSObject());
			System.assert(String.isNotBlank(result));
		}
		Test.stopTest();
	}

	@IsTest
	static void testGetMostRecentlyViewedRecord() {
		Test.startTest();
		SObject result = SObjectUtil.getMostRecentlyViewedRecord(Account.SObjectType);
		Test.stopTest();
		System.assertNotEquals(null, result);
	}

	@IsTest
	static void testGetRecordTypes() {
		Test.startTest();
		Map<Id, String> results = SObjectUtil.getRecordTypes('Account');
		Test.stopTest();
		System.assertNotEquals(0, results.size());
	}

	@IsTest
	static void testIsValid() {
		Test.startTest();
		System.assertEquals(true, SObjectUtil.isValid('Account'));
		System.assertEquals(true, SObjectUtil.isValid('Account', 'Name'));
		System.assertEquals(false, SObjectUtil.isValid('Testing'));
		System.assertEquals(false, SObjectUtil.isValid('Account', 'Testing'));
		System.assertEquals(true, SObjectUtil.isValid('WorkOrder', 'Account.Name'));
		System.assertEquals(true, SObjectUtil.isValid('Order', 'Quote.Opportunity.Account.Name'));
		System.assertEquals(false, SObjectUtil.isValid('WorkOrder', 'Account.Testing'));
		System.assertEquals(true, SObjectUtil.isValid('WorkOrderLineItem', 'WorkOrder.Order__r.Account.Name'));
		System.assertEquals(true, SObjectUtil.isValid('Employee__c', 'Manager__r.JobTitle__r.Department__c'));
		// opposite
		System.assertEquals(false, SObjectUtil.isNotValid('Account'));
		System.assertEquals(false, SObjectUtil.isNotValid('Account', 'Name'));
		System.assertEquals(true, SObjectUtil.isNotValid('Testing'));
		System.assertEquals(true, SObjectUtil.isNotValid('Account', 'Testing'));
		System.assertEquals(false, SObjectUtil.isNotValid('WorkOrder', 'Account.Name'));
		System.assertEquals(false, SObjectUtil.isNotValid('Order', 'Quote.Opportunity.Account.Name'));
		System.assertEquals(true, SObjectUtil.isNotValid('WorkOrder', 'Account.Testing'));
		System.assertEquals(false, SObjectUtil.isNotValid('WorkOrderLineItem', 'WorkOrder.Order__r.Account.Name'));
		System.assertEquals(false, SObjectUtil.isNotValid('Employee__c', 'Manager__r.JobTitle__r.Department__c'));
		Test.stopTest();
	}

}
