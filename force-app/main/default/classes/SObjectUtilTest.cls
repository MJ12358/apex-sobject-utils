@IsTest
public class SObjectUtilTest {

  private static Integer count = 2;

  @TestSetup
  static void testSetup() {
    List<Account> accounts = new List<Account>();
    for (Integer i = 0; i < count; i++) {
      Account acc = new Account();
      acc.Name = 'Name' + i;
      accounts.add(acc);
    }
    insert accounts;
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
    String name = SObjectUtil.convertNameToLabel('Account');
    String name2 = SObjectUtil.convertNameToLabel('InvalidSObject');
    Test.stopTest();
    System.assertEquals('Account', name);
    System.assertEquals(null, name2);
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

  // TODO: create a restricted user
  // @IsTest
  // static void testDeleteRecordRestricted() {
  //  Account acc = [SELECT Id FROM Account LIMIT 1];
  //  User user = [SELECT Id FROM User WHERE Username LIKE '%restricteduser%' LIMIT 1];
  //  Test.startTest();
  //  System.runAs(user) {
  //    try {
  //      SObjectUtil.deleteById(acc.Id);
  //      System.assert(false, 'Expected an exception');
  //    } catch (Exception e) {
  //      System.assert(true, 'Exception caught');
  //    }
  //  }
  //  Test.stopTest();
  //  List<Account> accs = [SELECT Id FROM Account];
  //  System.assertEquals(count, accs.size(), 'Record must not be deleted');
  // }

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
  static void testGetMostRecentlyViewedRecord() {
    Test.startTest();
    SObject result = SObjectUtil.getMostRecentlyViewedRecord(Account.SObjectType);
    Test.stopTest();
    System.assertNotEquals(null, result);
  }

  @IsTest
  static void testIsValid() {
    Test.startTest();
    System.assertEquals(true, SObjectUtil.isValid('Account'));
    System.assertEquals(true, SObjectUtil.isValid('Account', 'Name'));
    System.assertEquals(false, SObjectUtil.isValid('Testing'));
    System.assertEquals(false, SObjectUtil.isValid('Account', 'Testing'));
    System.assertEquals(true, SObjectUtil.isValid('WorkOrder', 'Account.Name'));
    System.assertEquals(false, SObjectUtil.isValid('WorkOrder', 'Account.Testing'));
    // opposite
    System.assertEquals(false, SObjectUtil.isNotValid('Account'));
    System.assertEquals(false, SObjectUtil.isNotValid('Account', 'Name'));
    System.assertEquals(true, SObjectUtil.isNotValid('Testing'));
    System.assertEquals(true, SObjectUtil.isNotValid('Account', 'Testing'));
    System.assertEquals(false, SObjectUtil.isNotValid('WorkOrder', 'Account.Name'));
    System.assertEquals(true, SObjectUtil.isNotValid('WorkOrder', 'Account.Testing'));
    Test.stopTest();
  }

  @IsTest
  static void testFakeId() {
    Test.startTest();
    Id result = SObjectUtil.getFakeId('Account');
    Test.stopTest();
    System.assertNotEquals(null, result);
  }

}
