# apex-sobject-utils
Utilities to make working with [SObjects](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/langCon_apex_SObjects.htm) and [DML](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_dml_section.htm) easier in [Apex](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_dev_guide.htm).

<a href="https://githubsfdeploy.herokuapp.com/app/githubdeploy/MJ12358/apex-sobject-utils?ref=main">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

# Requirements

- This package requires my [apex-core-utils](https://github.com/MJ12358/apex-core-utils).
	
  The `StringBuilder` and `DateUtil`.

# Highlights

- ### AddressUtil
  Easily work with the compound address field.

-	### CrudException
	Generates a templated error message when a [CRUD](https://developer.salesforce.com/wiki/enforcing_crud_and_fls) exception occurs.

- ### DatabaseException
	An abstract class which is extended by both `CrudException` and `FlsException`, just to make catching easier.

-	###	DuplicateFinder
	Used to easily find duplicates within the org based on the org's defined duplicate rules.

- ### FieldSetUtil
  Easily work with field sets.

-	###	FlsException
	Generates a templated error message when a [FLS](https://developer.salesforce.com/wiki/enforcing_crud_and_fls) exception occurs.

-	### IDml
	An interface used to specify a DML implementation within the `SObjectUnitOfWork`.
	- OptionDml
	- SecureDml
	- SimpleDml

- ### LREngine (Lookup Rollup Engine)
    [Adapted from this amazing code](https://github.com/abhinavguptas/Salesforce-Lookup-Rollup-Summaries/blob/master/classes/LREngine.cls).

    Simplifies rolling up child records in a lookup relationship.

- ### PicklistUtil
  Easily work with picklists.

- ### RecordTypeUtil
  Easily work with record types.

-	### SObjectFactory
	Allows easy creation of SObjects, auto generating required fields and relationships when needed.

    You can extend this class to make your own custom factories, or use the built-in "Generic" factory.

- ### SObjectMatcher
  Match SObjects using fields of your choice.

-	###	SObjectSelector
    [Adapted from this amazing code](https://github.com/financialforcedev/df12-apex-enterprise-patterns/blob/master/df12/src/classes/SObjectSelector.cls).

	  Used to query the database via SOQL.

    You can extend this class to make your own custom selectors, or use the built-in "Generic" selector.
    
    **TODO: Would like to create a "QueryBuilder" instead**

-	### SObjectUnitOfWork
    [Adapted from this amazing code](https://github.com/financialforcedev/df12-apex-enterprise-patterns/blob/master/df12/src/classes/SObjectUnitOfWork.cls).

	  Used to gather all dml work and commits it in a single place.

- ### SObjectUtil
  A utility class that has **many** helper methods to make working with SObjects and their fields easier.

- ### RecordData
  An Aura component to make accessing record data easier.

# Usage

`AddressUtil`

```apex
Lead lead1 = new Lead();
lead1.Street = '123 Main St.';
lead1.City = 'City';
lead1.State = 'NY';
lead1.Country = 'US';

Lead lead2 = new Lead();

AddressUtil.copy(lead1, lead2);

System.assertEquals(lead2, lead1.Street);
System.assertEquals(lead2, lead1.City);
System.assertEquals(lead2, lead1.State);
System.assertEquals(lead2, lead1.Country);
```

`CrudException`

```apex
Account acc = new Account();
CrudException e = new CrudException(DatabaseOperation.READ, acc);
```

`DuplicateFinder`

```apex
Account acc = new Account();
acc.Name = 'Duplicate';

DuplicateFinder finder = new DuplicateFinder();
finder.find(acc);
List<SObject> duplicates = finder.getRecords();
```

`FieldSetUtil`

```apex
List<String> fields = FieldSetUtil.getFields('Account', 'My_Field_Set');

List<Schema.DescribeFieldResult> describes = FieldSetUtil.getDescribed('Account', 'My_Field_Set');
```

`FlsException`

```apex
Account acc = new Account();
FlsException e = new FlsException(DatabaseOperation.READ, acc, Account.Name);
```

`LREngine`

```apex
List<Opportunity> records = Trigger.new;

LREngine.Context ctx = new LREngine.Context(
  Account.SObjectType,
  Opportunity.SObjectType,
  Opportunity.AccountId
);

ctx.add(new LREngine.RollupSummaryField(
  Account.AnnualRevenue,
  Opportunity.Amount,
  LREngine.RollupOperation.Sum
));

List<SObject> masters = LREngine.rollUp(ctx, records);
```

`PicklistUtil`

```apex
List<String> labels = PicklistUtil.getLabels('Account', 'Type');
List<String> values = PicklistUtil.getValues('Account', 'Type');

// get state/country codes if its enabled in your org
List<String> stateCodes = PicklistUtil.getStateValues();
```

`RecordTypeUtil`

```apex
Id result = RecordTypeUtil.getId('Account', 'My_Record_Type');
String name = RecordTypeUtil.getName('Account', 'therecordtypeid');
```

`SObjectFactory`

```apex
SObjectFactory factory = new SObjectFactory.Generic(Account.SObjectType, 3);

List<SObject> records = factory.build();

System.assertEquals(3, records.size());
```

`SObjectMatcher`

```apex
Map<Schema.SObjectField, Object> valueByField = new Map<Schema.SObjectField, Object>{
  Account.Name => 'Test',
  Account.Email__c => 'test@test.com',
  Account.Phone => '123-456-7890',
  Account.CreatedDate => Date.today()
};

SObjectMatcher matcher = new SObjectMatcher(Account.SObjectType, valueByField);

matcher.find();

SObject result = matcher.getRecord();
```

`SObjectSelector`

```apex
SObjectSelector selector = new SObjectSelector.Generic(Account.SObjectType);

// select all records with all fields
List<SObject> results = selector.selectAll();
```

`SObjectUnitOfWork`

```apex
List<SObjectType> types = new List<SObjectType>{Account.SObjectType};
SObjectUnitOfWork uow = new SObjectUnitOfWork(types);

for (Integer i = 0; i < 100; i++) {
  Account acc = new Account();
  acc.Name = 'Test' + i;
  uow.registerNew(acc);
}

uow.commitWork();
```

`SObjectUtil`

```apex
Contact cont = [SELECT Id, Account.Name FROM Contact LIMIT 1];
String sObjectName = SObjectUtil.convertIdToName(cont.Id);

Schema.SObjectType type = SObjectUtil.convertNameToType('Contact');

Object value = SObjectUtil.getFieldValue(cont, 'Account.Name');

// ...and many more
```

`RecordData`

// YourComponent.cmp
```html
<aura:handler
  name="recordLoaded"
  event="c:RecordDataLoaded"
  action="{!c.recordLoaded}" />

<c:RecordData aura:id="recordData"
  isLoading="{!v.isLoading}"
  layoutType="FULL"
  mode="EDIT"
  recordId="{#v.recordId}"
  targetFields="{!v.record}" />
```

# Tests

Current test results:

| Class | Percent | Lines |
| ----- | ------- | ----- |
| AddressUtil | 68% | 92/135 |
| DuplicateFinder | 93% | 67/72 |
| FieldSetUtil | 62% | 22/35 |
| IconUtil | 92% | 77/83 |
| LREngine | 92% | 204/221 |
| PicklistUtil | 80%  | 40/50 |
| RecordTypeUtil  | 88%  | 46/52 |
| SObjectFactory | 74% | 140/188 |
| SObjectMatcher | 85% | 97/113 |
| SObjectSelector | 84% | 83/98 |
| SObjectUnitOfWork | 78% | 149/189 |
| SObjectUtil | 86% | 210/243 |
| UserUtil | 100% | 20/20 |