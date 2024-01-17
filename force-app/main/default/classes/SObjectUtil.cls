/**
 * Created on Tue Dec 31 2019
 *
 * Copyright (c) 2019 MJ12358
 * All rights reserved.

 * Redistribution and use in source and binary forms, with or without modification, 
 *    are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *    this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *    this list of conditions and the following disclaimer in the documentation 
 *    and/or other materials provided with the distribution.
 * - Neither the name of the company, software or the names of its contributors 
 *    may be used to endorse or promote products derived from this software without 
 *    specific prior written permission.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
 *  TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 *  THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, TORT (INCLUDING NEGLIGENCE) OR OTHERWISE, 
 *  ARISING FROM, OUT OF OR IN CONNECTION WITH THE USE OF THIS SOFTWARE OR OTHER DEALINGS IN THE SOFTWARE, 
 *  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 **/

public inherited sharing class SObjectUtil {

  private static Integer fakeIdCount = 1;

  // cache a map of sObjectType => sObjectFields
  private static Map<Schema.SObjectType, Map<String, Schema.SObjectField>> fieldMap = 
    new Map<Schema.SObjectType, Map<String, Schema.SObjectField>>();

/**
 *  Lazy load / cache the Schema.getGlobalDescribe()
 *  @return Map<String,Schema.SObjectType>
 */
  public static Map<String, Schema.SObjectType> globalDescribe {
    get {
      if (globalDescribe == null) {
        globalDescribe = Schema.getGlobalDescribe();
      }
      return globalDescribe;
    }
    private set;
  }

/**
 *  Lazy load / cache a hash map of SObjectField => SObjectType
 *  @return Map<Integer,Schema.SObjectType>
 */
  public static Map<Integer, Schema.SObjectType> hashMap {
    get {
      if (hashMap == null) {
        hashMap = new Map<Integer, Schema.SObjectType>();
        for (Schema.SObjectType sObjectType : globalDescribe.values()) {
          for (Schema.SObjectField field : getFieldMap(sObjectType).values()) {
            hashMap.put(((Object)field).hashCode(), sObjectType);
          }
        }
      }
      return hashMap;
    }
    private set;
  }

  //* Get field map

/**
 *  Get a field map for a given sObject type
 *  @param Schema.SObjectType
 *  @return Map<String, Schema.SObjectField>
 */
  public static Map<String, Schema.SObjectField> getFieldMap(Schema.SObjectType sObjectType) {
    Map<String, Schema.SObjectField> result = new Map<String, Schema.SObjectField>();
    if (sObjectType == null) {
      return result;
    }
    if (fieldMap.get(sObjectType) != null) {
      return fieldMap.get(sObjectType);
    }
    result = sObjectType.getDescribe().fields.getMap();
    fieldMap.put(sObjectType, result);
    return result;
  }

/**
 *  Get a field map for a given sObject type
 *  @param SObject
 *  @return Map<String, Schema.SObjectField>
 */
  public static Map<String, Schema.SObjectField> getFieldMap(SObject sObj) {
    return getFieldMap(sObj.getSObjectType());
  }

/**
 *  Get a field map for a given sObject type
 *  @param Schema.DescribeSObjectResult
 *  @return Map<String, Schema.SObjectField>
 */
  public static Map<String, Schema.SObjectField> getFieldMap(Schema.DescribeSObjectResult sObjectDescribe) {
    return getFieldMap(sObjectDescribe.getSObjectType());
  }

/**
 *  Get a field map for a given sObject type
 *  @param String
 *  @return Map<String, Schema.SObjectField>
 */
  public static Map<String, Schema.SObjectField> getFieldMap(String sObjectName) {
    return getFieldMap(convertNameToType(sObjectName));
  }

  //* Convert Id to name

/**
 *  Convert an sObject ID to it's name
 *  @param Id The sObject ID to convert
 *  @return String
 */
  public static String convertIdToName(Id recordId) {
    if (String.isBlank(recordId)) {
      return null;
    }
    return recordId.getSObjectType().getDescribe().getName();
  }

/**
 *  Convert an sObject ID to it's name
 *  @param List<Id> The sObject ID to convert
 *  @return String
 */
  public static String convertIdToName(List<Id> recordIds) {
    if (recordIds == null || recordIds.isEmpty()) {
      return null;
    }
    return convertIdToName(recordIds[0]);
  }

/**
 *  Convert an sObject ID to it's name
 *  @param Set<Id> The sObject ID to convert
 *  @return String
 */
  public static String convertIdToName(Set<Id> recordIds) {
    if (recordIds == null || recordIds.isEmpty()) {
      return null;
    }
    return convertIdToName(new List<Id>(recordIds));
  }

  //* Convert Id to type

/**
 *  Convert an sObject ID to it's type
 *  @param Id The sObject ID to convert
 *  @return Schema.SObjectType
 */
  public static Schema.SObjectType convertIdToType(Id recordId) {
    if (String.isBlank(recordId)) {
      return null;
    }
    return recordId.getSObjectType();
  }

/**
 *  Convert an sObject ID to it's type
 *  @param List<Id> The sObject ID to convert
 *  @return Schema.SObjectType
 */
  public static Schema.SObjectType convertIdToType(List<Id> recordIds) {
    if (recordIds == null || recordIds.isEmpty()) {
      return null;
    }
    return convertIdToType(recordIds[0]);
  }

/**
 *  Convert an sObject ID to it's type
 *  @param Set<Id> The sObject ID to convert
 *  @return Schema.SObjectType
 */
  public static Schema.SObjectType convertIdToType(Set<Id> recordIds) {
    if (recordIds == null || recordIds.isEmpty()) {
      return null;
    }
    return convertIdToType(new List<Id>(recordIds));
  }

  //* Convert name to label

/**
 *  Convert an sObject name to it's label
 *  @param String The sObject name to convert
 *  @return String
 */
  public static String convertNameToLabel(String sObjectName) {
    if (String.isBlank(sObjectName)) {
      return null;
    }
    return convertNameToType(sObjectName)?.getDescribe().getLabel(); 
  }

  //* Convert name to type

/**
 *  Convert an sObject name to a concrete sObject type
 *  @param String The sObject name to convert
 *  @return Schema.SObjectType
 */
  public static Schema.SObjectType convertNameToType(String sObjectName) {
    if (String.isBlank(sObjectName)) {
      return null;
    }
    System.Type t = System.Type.forName(sObjectName);
    if (t == null) {
      return null;
    }
    SObject sObj = (SObject)t.newInstance();
    return sObj.getSObjectType();
  }

  //* Convert field to type

/**
 *  Convert an sObject field to a concrete type
 *  @param String The sObject name
 *  @param String The sObject field to convert
 *  @return Schema.SObjectField
 */
  public static Schema.SObjectField convertFieldToType(String sObjectName, String sObjectField) {
    if (String.isBlank(sObjectName) || String.isBlank(sObjectField)) {
      return null;
    }
    return getFieldMap(globalDescribe.get(sObjectName)).get(sObjectField);
  }

/**
 *  Convert an sObject field to a concrete type
 *  @param Schema.SObjectType The sObject type
 *  @param String The sObject field to convert
 *  @return Schema.SObjectField
 */
  public static Schema.SObjectField convertFieldToType(Schema.SObjectType sObjectType, String sObjectField) {
    return convertFieldToType(sObjectType?.getDescribe().getName(), sObjectField);
  }

  //* Get sObject type from field

/**
 *  Retrive an sObject type from an sObject field
 *  @param Schema.SObjectField
 *  @return Schema.SObjectType
 */
  public static Schema.SObjectType getSObjectType(Schema.SObjectField sObjectField) {
    return hashMap.get(((Object)sObjectField).hashCode());
  }

/**
 *  Retrive an sObject type from an sObject field describe
 *  @param Schema.DescribeFieldResult
 *  @return Schema.SObjectType
 */
  public static Schema.SObjectType getSObjectType(Schema.DescribeFieldResult fieldDescribe) {
    return getSObjectType(fieldDescribe.getSObjectField());
  }

  //* Get field value

/**
 *  Get an sObject field value from a string (supports dot notation)
 *  @param String
 *  @return Object
 */
  public static Object getFieldValue(SObject sObj, String field) {
    if (sObj == null || String.isBlank(field)) {
      return null;
    }
    List<String> fieldSplit = field.split('\\.');
    if (fieldSplit.size() > 1) {
      Integer count = 0;
      SObject parentRecord = sObj.getSObject(fieldSplit[count++]);
      while (count < fieldSplit.size() - 1) {
        parentRecord = parentRecord.getSObject(fieldSplit[count]);
        count++;
      }
      // ensure the relationship is not null
      if (parentRecord != null && String.isNotBlank(fieldSplit[count])) {
        return parentRecord.get(fieldSplit[count]);
      }
      return null;
    }
    return sObj.get(field);
  }

  //* Get display type

  public static Schema.DisplayType getDisplayType(String fieldType) {
    Schema.DisplayType displayType;
    if (String.isNotBlank(fieldType)) {
      for (Schema.DisplayType type : Schema.DisplayType.values()) {
        if (type.name().toUpperCase() == fieldType.toUpperCase()) {
          displayType = type;
          break;
        }
      }
    }
    return displayType;
  }

  //* Get accessible fields

/**
 *  Get accessible fields
 *  @param Schema.SObjectType The sObject type
 *  @return List<String>
 */
  public static List<String> getAccessibleFields(Schema.SObjectType sObjectType) {
    List<String> result = new List<String>();
    if (sObjectType != null) {
      for (Schema.SObjectField field : getFieldMap(sObjectType).values()) {
        Schema.DescribeFieldResult describe = field.getDescribe();
        if (describe.isAccessible()) {
          result.add(describe.getName());
        }
      }
    }
    return result;
  }

/**
 *  Get accessible fields
 *  @param Id The sObject id
 *  @return List<String>
 */
  public static List<String> getAccessibleFields(Id recordId) {
    return getAccessibleFields(convertIdToType(recordId));
  }

/**
 *  Get accessible fields
 *  @param String The sObject name
 *  @return List<String>
 */
  public static List<String> getAccessibleFields(String sObjectName) {
    return getAccessibleFields(convertNameToType(sObjectName));
  }

  //* Get accessible fields by type

/**
 *  Get accessible fields by type
 *  @param Schema.SObjectType The sObject type
 *  @param Schema.DisplayType The field type
 *  @return List<String>
 */
  public static List<String> getAccessibleFields(Schema.SObjectType sObjectType, Schema.DisplayType displayType) {
    List<String> result = new List<String>();
    if (sObjectType != null && displayType != null) {
      for (Schema.SObjectField field : getFieldMap(sObjectType).values()) {
        Schema.DescribeFieldResult describe = field.getDescribe();
        if (describe.isAccessible() && describe.getType() == displayType) {
          result.add(describe.getName());
        }
      }
    }
    return result;
  }

/**
 *  Get accessible fields by type
 *  @param String The sObject name
 *  @param Schema.DisplayType The field type
 *  @return List<String>
 */
  public static List<String> getAccessibleFields(String sObjectName, Schema.DisplayType displayType) {
    return getAccessibleFields(convertNameToType(sObjectName), displayType);
  }

/**
 *  Get accessible fields by type
 *  @param String The sObject name
 *  @param String The field type
 *  @return List<String>
 */
  public static List<String> getAccessibleFields(String sObjectName, String fieldType) {
    Schema.DisplayType displayType = getDisplayType(fieldType);
    Schema.SObjectType sObjectType = convertNameToType(sObjectName);
    return getAccessibleFields(sObjectType, displayType);
  }

  //* Get updateable fields

/**
 *  Get updatable fields
 *  @param Schema.SObjectType The sObject type
 *  @return List<String>
 */
  public static List<String> getUpdateableFields(Schema.SObjectType sObjectType) {
    List<String> result = new List<String>();
    if (sObjectType != null) {
      for (Schema.SObjectField field : getFieldMap(sObjectType).values()) {
        Schema.DescribeFieldResult fieldDesc = field.getDescribe();
        if (fieldDesc.isAccessible() && fieldDesc.isUpdateable()) {
          result.add(fieldDesc.getName());
        }
      }
    }
    return result;
  }

/**
 *  Get updatable fields
 *  @param Id The sObject id
 *  @return List<String>
 */
  public static List<String> getUpdateableFields(Id recordId) {
    return getUpdateableFields(convertIdToType(recordId));
  }

/**
 *  Get updatable fields
 *  @param String The sObject name
 *  @return List<String>
 */
  public static List<String> getUpdateableFields(String sObjectName) {
    return getUpdateableFields(convertNameToType(sObjectName));
  }

  //* Get updateable fields by type

/**
 *  Get updateable fields by type
 *  @param Schema.SObjectType The sObject type
 *  @param Schema.DisplayType The field type
 *  @return List<String>
 */
  public static List<String> getUpdateableFields(Schema.SObjectType sObjectType, Schema.DisplayType displayType) {
    List<String> result = new List<String>();
    if (sObjectType != null && displayType != null) {
      for (Schema.SObjectField field : getFieldMap(sObjectType).values()) {
        Schema.DescribeFieldResult describe = field.getDescribe();
        if (describe.isAccessible() && describe.isUpdateable() && describe.getType() == displayType) {
          result.add(describe.getName());
        }
      }
    }
    return result;
  }

/**
 *  Get updateable fields by type
 *  @param String The sObject name
 *  @param Schema.DisplayType The field type
 *  @return List<String>
 */
  public static List<String> getUpdateableFields(String sObjectName, Schema.DisplayType displayType) {
    return getUpdateableFields(convertNameToType(sObjectName), displayType);
  }

/**
 *  Get updateable fields by type
 *  @param String The sObject name
 *  @param String The field type
 *  @return List<String>
 */
  public static List<String> getUpdateableFields(String sObjectName, String fieldType) {
    Schema.DisplayType displayType = getDisplayType(fieldType);
    Schema.SObjectType sObjectType = convertNameToType(sObjectName);
    return getUpdateableFields(sObjectType, displayType);
  }

  //* Generic select statement

/**
 *  Generic select sObject by ID
 *  @param Id The sObject record ID
 *  @return SObject
 */
  public static SObject selectById(Id recordId) {
    Schema.SObjectType sObjectType = recordId.getSObjectType();
    return new SObjectSelector.Generic(sObjectType).selectById(recordId);
  }

  //* Generic delete statement

/**
 *  Generic delete sObject by ID
 *  @param Id The sObject record ID
 */
  public static void deleteById(Id recordId) {
    Schema.SObjectType sObjectType = recordId.getSObjectType();
    SObject record = new SObjectSelector.Generic(sObjectType).selectById(recordId);
    SObjectUnitOfWork uow = new SObjectUnitOfWork(
      new List<Schema.SObjectType>{
        recordId.getSObjectType()
      }
    );
    uow.registerDeleted(record);
    uow.commitWork();
  }

  //* Generic update statement

/**
 *  Generic update records
 *  @param String A serialized list of sObjects
 */
  public static void updateRecords(String records) {
    List<SObject> values = (List<SObject>)System.JSON.deserialize(records, List<SObject>.class);
    SObjectUnitOfWork uow = new SObjectUnitOfWork(
      new List<Schema.SObjectType>{
        values[0].getSObjectType()
      }
    );
    uow.registerDirty(values);
    uow.commitWork();
  }

/**
 *  Generic update record
 *  @param String A serialized sObject
 */
  public static void updateRecord(String record) {
    SObject value = (SObject)System.JSON.deserialize(record, SObject.class);
    SObjectUnitOfWork uow = new SObjectUnitOfWork(
      new List<Schema.SObjectType>{
        value.getSObjectType()
      }
    );
    uow.registerDirty(value);
    uow.commitWork();
  }

  //* Most recently viewed record

/**
 *  Get most recently viewed record
 *  @param String
 *  @return SObject
 */
  public static SObject getRecentlyViewedRecord(String sObjectName) {
    return [
      SELECT Id
      FROM RecentlyViewed
      WHERE Type = :sObjectName
      ORDER BY LastViewedDate DESC
      LIMIT 1
    ];
  }

/**
 *  Get most recently view record
 *  @param Schema.SObjectType
 *  @return SObject
 */
  public static SObject getRecentlyViewedRecord(Schema.SObjectType sObjectType) {
    String sObjectName = sObjectType.getDescribe().getName();
    return getRecentlyViewedRecord(sObjectName);
  }

  //* Get reference to

/**
 *  Get sObject references to an sObject field
 *  @param Schema.SObjectField
 *  @return Set<Schema.SObjectType>
 */
  public static Set<Schema.SObjectType> getReferenceTo(Schema.SObjectField field) {
    Set<Schema.SObjectType> result = new Set<Schema.SObjectType>();
    if (field != null) {
      for (Schema.SObjectType sObjectType : field.getDescribe().getReferenceTo()) {
        if (sObjectType.getDescribe().isAccessible()) {
          result.add(sObjectType);
        }
      }
    }
    return result;
  }

/**
 *  Get sObject references to an sObject field
 *  @param String The sObject name
 *  @param String The sObject field
 *  @return Set<Schema.SObjectType>
 */
  public static Set<Schema.SObjectType> getReferenceTo(String sObjectName, String fieldName) {
    Schema.SObjectField field = getFieldMap(sObjectName).get(fieldName);
    return getReferenceTo(field);
  }

  //* Get relationship name

/**
 *  Get relationship name from SObjectField
 *  @param Schema.SObjectField
 *  @return String
 */
  public static String getRelationshipName(Schema.SObjectField field) {
    return field.getDescribe().getRelationshipName();
  }

/**
 *  Get relationship name from SObjectField
 *  @param Schema.SObjectType
 *  @param String
 *  @return String
 */
  public static String getRelationshipName(Schema.SObjectType sObjectType, String fieldName) {
    Schema.SObjectField field = getFieldMap(sObjectType).get(fieldName);
    return getRelationshipName(field);
  }

/**
 *  Get relationship name from field name
 *  @param String
 *  @param String
 *  @return String
 */
  public static String getRelationshipName(String sObjectName, String fieldName) {
    return getRelationshipName(globalDescribe.get(sObjectName), fieldName);
  }

/**
 *  Get child relationship name
 *  @param Schema.SObjectType
 *  @param Schema.SObjectField
 *  @return String
 */
  public static String getChildRelationshipName(Schema.SObjectType sObjectType, Schema.SObjectField field) {
    if (sObjectType != null && field != null) {
      for (Schema.ChildRelationship child : sObjectType.getDescribe().getChildRelationships()) {
        if (child.getField() == field) {
          return child.getRelationshipName();
        }
      }
    }
    return null;
  }

/**
 *  Get child relationship name
 *  @param String
 *  @param String
 *  @return String
 */
  public static String getChildRelationshipName(String sObjectName, String fieldName) {
    Schema.SObjectType sObjectType = globalDescribe.get(sObjectName);
    if (sObjectType == null) {
      return null;
    }
    Schema.SObjectField field = getFieldMap(sObjectType).get(fieldName);
    if (field == null) {
      return null;
    }
    Schema.SObjectType parentType = field.getDescribe().getReferenceTo().get(0);
    return getChildRelationshipName(parentType, field);
  }

  //* Assignment rule

/**
 *  Set an assignment rule on an sObject
 *  @param SObject
 *  @return SObject
 */
  public static SObject setAssignmentRule(SObject sObj) {
    if (sObj != null) {
      String sObjectName = sObj.getSObjectType().getDescribe().getName();
      List<SObject> arList = [SELECT Id FROM AssignmentRule WHERE (SObjectType = :sObjectName AND Active = true) LIMIT 1];
      if (!arList.isEmpty()) {
        Database.DMLOptions options = new Database.DMLOptions();
        options.AssignmentRuleHeader.AssignmentRuleId = arList[0].Id;
        sObj.setOptions(options);
      }
    }
    return sObj;
  }

  //* Validate sObject

/**
 *  Verify the passed in string is a valid sObject
 *  @param String The sObject name
 *  @return Boolean
 */
  public static Boolean isValid(String sObjectName) {
    Schema.SObjectType sObjectType;
    if (String.isNotBlank(sObjectName)) {
       sObjectType = globalDescribe.get(sObjectName);
    }
    return sObjectType == null ? false : true;
  }

  public static Boolean isNotValid(String sObjectName) {
    return !isValid(sObjectName);
  }

  //* Validate sObject field

/**
 *  Verify the passed in string is a valid field for an sObject (supports dot notation)
 *  @param String The sObject name
 *  @param String The field name
 *  @return Boolean
 */
  public static Boolean isValid(String sObjectName, String fieldName) {
    return isValid(convertNameToType(sObjectName), fieldName);
  }

  public static Boolean isValid(Schema.SObjectType sObjectType, String fieldName) {
    if (sObjectType == null || String.isBlank(fieldName)) {
      return false;
    }
    fieldName = fieldName.toLowerCase();
    List<String> split = fieldName.split('\\.');
    if (split.size() <= 1) {
      return getFieldMap(sObjectType).containsKey(fieldName);
    }

    Boolean isValid = false;
    Integer index = 0;
    Schema.SObjectType parentType = sObjectType; // for first iteration
    
    while (index < split.size() - 1) {
      for (Schema.SObjectField field : getFieldMap(parentType).values()) {
        Schema.DescribeFieldResult dfr = field.getDescribe();
        if (dfr.getType() == Schema.DisplayType.REFERENCE && dfr.getRelationshipName() == split[index]) {
          isValid = true;
          parentType = dfr.getReferenceTo().get(0); // does not account for polymorphic lookups
          break;
        }
      }
      if (!isValid) {
        return false;
      }
      index++;
    }
    
    return getFieldMap(parentType).containsKey(split[index]);
  }

  public static Boolean isNotValid(String sObjectName, String fieldName) {
    return !isValid(sObjectName, fieldName);
  }

  public static Boolean isNotValid(Schema.SObjectType sObjectType, String fieldName) {
    return !isValid(sObjectType, fieldName);
  }

  //* Person accounts

/**
 *  Check if person accounts are enabled
 *  @return Boolean
 */
  public static Boolean isPersonAccountsEnabled() {
    return getFieldMap(Account.SObjectType).containsKey('isPersonAccount');
  }

  //* Fake Id

/**
 *  Generate a fake sObject Id
 *  @param Schema.SObjectType
 *  @return Id
 */
  public static Id getFakeId(Schema.SObjectType sObjectType) {
    String keyPrefix = sObjectType.getDescribe().getKeyPrefix();
    String result = String.valueOf(fakeIdCount++);
    return keyPrefix + '0'.repeat(12 - result.length()) + result;
  }

/**
 *  Generate a fake sObject Id
 *  @param String The sObject name
 *  @return Id
 */
  public static Id getFakeId(String sObjectName) {
    return getFakeId(convertNameToType(sObjectName));
  }
}
