@IsTest
public class AddressUtilTest {

  @TestSetup
  static void testSetup() {
    Account acc = new Account();
    acc.Name = 'Test Account';
    acc.BillingCity = 'City';
    acc.BillingCountry = 'US';
    acc.BillingPostalCode = '123456';
    acc.BillingState = 'NY';
    acc.BillingStreet = '123 Right Here';
    acc.ShippingCity = 'City';
    acc.ShippingCountry = 'US';
    acc.ShippingPostalCode = '123456';
    acc.ShippingState = 'NY';
    acc.ShippingStreet = '123 Right Here';
    insert acc;

    Contact cont = new Contact();
    cont.FirstName = 'FirstName';
    cont.LastName = 'LastName';
    cont.MailingCity = 'City';
    cont.MailingCountry = 'US';
    cont.MailingPostalCode = '123456';
    cont.MailingState = 'NY';
    cont.MailingStreet = '123 Right Here';
    insert cont;

    Lead l = new Lead();
    l.FirstName = 'FirstName';
    l.LastName = 'LastName';
    l.Company = 'Test Company';
    l.City = 'City';
    l.Country = 'US';
    l.PostalCode = '123456';
    l.State = 'NY';
    l.Street = '123 Right Here';
    insert l;
  }

  @IsTest
	static void testCopy() {
		Lead l = [SELECT Address, Street FROM Lead LIMIT 1];
		Lead newl = new Lead();
		Test.startTest();
		AddressUtil.copy(l.Address, newl);
		Test.stopTest();
		System.assertEquals(l.Street, newl.Street);
	}

  @IsTest
  static void testCopy2() {
    Lead l = [SELECT Address, Street FROM Lead LIMIT 1];
		Lead newl = new Lead();
		Test.startTest();
		AddressUtil.copy(l, newl);
		Test.stopTest();
		System.assertEquals(l.Street, newl.Street);
  }

	@IsTest
	static void testCopyToBilling() {
		Account acc = [SELECT BillingAddress, BillingStreet FROM Account LIMIT 1];
		Account newAcc = new Account();
		Test.startTest();
		AddressUtil.copyToBilling(acc.BillingAddress, newAcc);
		Test.stopTest();
		System.assertEquals(acc.BillingStreet, newAcc.BillingStreet);
	}

	@IsTest
	static void testCopyToShipping() {
		Account acc = [SELECT ShippingAddress, ShippingStreet FROM Account LIMIT 1];
		Account newAcc = new Account();
		Test.startTest();
		AddressUtil.copyToShipping(acc.ShippingAddress, newAcc);
		Test.stopTest();
		System.assertEquals(acc.ShippingStreet, newAcc.ShippingStreet);
	}

  @IsTest
	static void testCopyToMailing() {
		Contact cont = [SELECT MailingAddress, MailingStreet FROM Contact LIMIT 1];
		Contact newCont = new Contact();
		Test.startTest();
		AddressUtil.copyToMailing(cont.MailingAddress, newCont);
		Test.stopTest();
		System.assertEquals(cont.MailingStreet, newCont.MailingStreet);
	}

	@IsTest
	static void testIsEmpty() {
		Account acc = new Account();
		WorkOrder wo = new WorkOrder();
		Test.startTest();
		System.assertEquals(true, AddressUtil.isEmpty(acc.ShippingAddress));
		System.assertEquals(true, AddressUtil.isEmpty(wo));
		wo.City = 'Testing';
		System.assertEquals(false, AddressUtil.isEmpty(wo));
		Test.stopTest();
	}

  @IsTest
  static void testIsEmpty2() {
    Account acc = [SELECT ShippingAddress FROM Account LIMIT 1];
    Test.startTest();
    System.assertEquals(false, AddressUtil.isEmpty(acc.ShippingAddress));
    Test.stopTest();
  }

	@IsTest
	static void testIsBillingEmpty() {
		Account acc = new Account();
		Test.startTest();
		System.assertEquals(true, AddressUtil.isBillingEmpty(acc));
		acc.BillingStreet = 'Testing';
		System.assertEquals(false, AddressUtil.isBillingEmpty(acc));
		Test.stopTest();
	}

	@IsTest
	static void testIsShippingEmpty() {
		Account acc = new Account();
		Test.startTest();
		System.assertEquals(true, AddressUtil.isShippingEmpty(acc));
		acc.ShippingStreet = 'Testing';
		System.assertEquals(false, AddressUtil.isShippingEmpty(acc));
		Test.stopTest();
	}

  @IsTest
	static void testIsMailingEmpty() {
		Contact cont = new Contact();
		Test.startTest();
		System.assertEquals(true, AddressUtil.isMailingEmpty(cont));
		cont.MailingStreet = 'Testing';
		System.assertEquals(false, AddressUtil.isMailingEmpty(cont));
		Test.stopTest();
	}

	@IsTest
	static void testHasChanged() {
		WorkOrder wo1 = new WorkOrder();
		WorkOrder wo2 = new WorkOrder();
		Test.startTest();
		System.assertEquals(false, AddressUtil.hasChanged(wo1, wo2));
		wo2.City = 'Testing';
		System.assertEquals(true, AddressUtil.hasChanged(wo1, wo2));
		Test.stopTest();
	}

}
