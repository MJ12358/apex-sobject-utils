# apex-sobject-utils
Utilities to make working with [SObjects](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/langCon_apex_SObjects.htm) and [DML](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_dml_section.htm) easier in [Apex](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_dev_guide.htm).

This is a WIP.

<a href="https://githubsfdeploy.herokuapp.com/app/githubdeploy/MJ12358/apex-sobject-utils?ref=main">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

## Requirements

- This package requires my [apex-core-utils](https://github.com/MJ12358/apex-core-utils).
	The `StringBuilder` and `DateUtil`.

## This package's highlights include the following:

-	### CrudException
	Generates a templated error message when a [CRUD](https://developer.salesforce.com/wiki/enforcing_crud_and_fls) exception occurs.

- ### DatabaseException
	An abstract class which is extended by both `CrudException` and `FlsException`, just to make catching easier.

-	###	DuplicateFinder
	Used to easily find duplicates within the org based on the org's defined duplicate rules.

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

# Usage

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

Current test results are as follows:
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
| SObjectUtil | 71% | 189/264 |