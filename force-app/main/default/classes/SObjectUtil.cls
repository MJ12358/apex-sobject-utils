/**
 * Created on Tue Dec 31 2019
 *
 * Copyright (c) 2019 Matt Jants
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

	// cache a map of sObjectType => sObjectFields
	private static Map<Schema.SObjectType, Map<String, Schema.SObjectField>> fieldMap = new Map<Schema.SObjectType, Map<String, Schema.SObjectField>>();

/**
 *	Lazy load / cache the Schema.getGlobalDescribe()
 *	@return Map<String,Schema.SObjectType>
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
 *	Lazy load / cache a hash map of SObjectField => SObjectType
 *	@return Map<Integer,Schema.SObjectType>
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
 *	Get a field map for a given sObject type
 *	@param Schema.SObjectType
 *	@return Map<String, Schema.SObjectField>
 */
	public static Map<String, Schema.SObjectField> getFieldMap(Schema.SObjectType sObjectType) {
		if (sObjectType == null) {
			return new Map<String, Schema.SObjectField>();
		}
		if (fieldMap.get(sObjectType) != null) {
			return fieldMap.get(sObjectType);
		}
		Map<String, Schema.SObjectField> result = sObjectType.getDescribe().fields.getMap();
		fieldMap.put(sObjectType, result);
		return result;
	}

/**
 *	Get a field map for a given sObject type
 *	@param SObject
 *	@return Map<String, Schema.SObjectField>
 */
	public static Map<String, Schema.SObjectField> getFieldMap(SObject sObj) {
		return getFieldMap(sObj.getSObjectType());
	}

/**
 *	Get a field map for a given sObject type
 *	@param Schema.DescribeSObjectResult
 *	@return Map<String, Schema.SObjectField>
 */
	public static Map<String, Schema.SObjectField> getFieldMap(Schema.DescribeSObjectResult sObjectDescribe) {
		return getFieldMap(sObjectDescribe.getSObjectType());
	}

/**
 *	Get a field map for a given sObject type
 *	@param String
 *	@return Map<String, Schema.SObjectField>
 */
	public static Map<String, Schema.SObjectField> getFieldMap(String sObjectName) {
		return getFieldMap(convertNameToType(sObjectName));
	}

	//* Convert Id to name

/**
 *	Convert an sObject ID to it's name
 *	@param Id The sObject ID to convert
 *	@return String
 */
	@AuraEnabled
	public static String convertIdToName(Id recordId) {
		if (String.isNotBlank(recordId)) {
			return recordId.getSObjectType().getDescribe().getName();
		}
		return recordId;
	}

/**
 *	Convert an sObject ID to it's name
 *	@param List<Id> The sObject ID to convert
 *	@return String
 */
	@AuraEnabled
	public static String convertIdToName(List<Id> recordIds) {
		if (recordIds != null && !recordIds.isEmpty()) {
			return convertIdToName(recordIds[0]);
		}
		return null;
	}

/**
 *	Convert an sObject ID to it's name
 *	@param Set<Id> The sObject ID to convert
 *	@return String
 */
	public static String convertIdToName(Set<Id> recordIds) {
		if (recordIds != null && !recordIds.isEmpty()) {
			return convertIdToName(new List<Id>(recordIds));
		}
		return null;
	}

	//* Convert Id to type

/**
 *	Convert an sObject ID to it's type
 *	@param Id The sObject ID to convert
 *	@return Schema.SObjectType
 */
	public static Schema.SObjectType convertIdToType(Id recordId) {
		if (String.isNotBlank(recordId)) {
			return recordId.getSObjectType();
		}
		return null;
	}

/**
 *	Convert an sObject ID to it's type
 *	@param List<Id> The sObject ID to convert
 *	@return Schema.SObjectType
 */
	public static Schema.SObjectType convertIdToType(List<Id> recordIds) {
		if (recordIds != null && !recordIds.isEmpty()) {
			return convertIdToType(recordIds[0]);
		}
		return null;
	}

/**
 *	Convert an sObject ID to it's type
 *	@param Set<Id> The sObject ID to convert
 *	@return Schema.SObjectType
 */
	public static Schema.SObjectType convertIdToType(Set<Id> recordIds) {
		if (recordIds != null && !recordIds.isEmpty()) {
			return convertIdToType(new List<Id>(recordIds));
		}
		return null;
	}

	//* Convert name to label

/**
 *	Convert an sObject name to it's label
 *	@param String The sObject name to convert
 *	@return String
 */
	@AuraEnabled
	public static String convertNameToLabel(String sObjectName) {
		if (String.isNotBlank(sObjectName)) {
			return convertNameToType(sObjectName).getDescribe().getLabel(); 
		}
		return sObjectName;
	}

	//* Convert name to type

/**
 *	Convert an sObject name to a concrete sObject type
 *	@param String The sObject name to convert
 *	@return Schema.SObjectType
 */
	public static Schema.SObjectType convertNameToType(String sObjectName) {
		if (String.isNotBlank(sObjectName)) {
			System.Type t = System.Type.forName(sObjectName);
			if (t == null) {
				return null;
			}
			SObject sObj = (SObject)t.newInstance();
			return sObj.getSObjectType();
		}
		return null;
	}

	//* Convert field to type

/**
 *	Convert an sObject field to a concrete type
 *	@param String The sObject name
 *	@param String The sObject field to convert
 *	@return Schema.SObjectField
 */
	public static Schema.SObjectField convertFieldToType(String sObjectName, String sObjectField) {
		if (String.isNotBlank(sObjectName) && String.isNotBlank(sObjectField)) {
			return getFieldMap(globalDescribe.get(sObjectName)).get(sObjectField);
		}
		return null;
	}

/**
 *	Convert an sObject field to a concrete type
 *	@param Schema.SObjectType The sObject type
 *	@param String The sObject field to convert
 *	@return Schema.SObjectField
 */
	public static Schema.SObjectField convertFieldToType(Schema.SObjectType sObjectType, String sObjectField) {
		if (sObjectType != null) {
			return convertFieldToType(sObjectType.getDescribe().getName(), sObjectField);
		}
		return null;
	}

	//* Get sObject type from field

/**
 *	Retrive an sObject type from an sObject field
 *	@param Schema.SObjectField
 *	@return Schema.SObjectType
 */
	public static Schema.SObjectType getSObjectType(Schema.SObjectField sObjectField) {
		return hashMap.get(((Object)sObjectField).hashCode());
	}

/**
 *	Retrive an sObject type from an sObject field describe
 *	@param Schema.DescribeFieldResult
 *	@return Schema.SObjectType
 */
	public static Schema.SObjectType getSObjectType(Schema.DescribeFieldResult fieldDescribe) {
		return getSObjectType(fieldDescribe.getSObjectField());
	}

	//* Get field value

/**
 *	Get an sObject field value from a string (supports dot notation)
 *	@param String
 *	@return Object
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

	//* Get all fields

/**
 * 	Get all fields from an sObject
 *	@param Schema.SObjectType
 *	@return Map<String, Schema.SObjectField>
 */
	public static Map<String, Schema.SObjectField> getAllFields(Schema.SObjectType sObjectType) {
		Map<String, Schema.SObjectField> result = new Map<String, Schema.SObjectField>();
		if (sObjectType != null) {
			result = getFieldMap(sObjectType);
		}
		return result;
	}

/**
 * 	Get all fields from an sObject
 *	@param String
 *	@return Map<String, Schema.SObjectField>
 */
	public static Map<String, Schema.SObjectField> getAllFields(String sObjectName) {
		return getAllFields(convertNameToType(sObjectName));
	}

	//* Generic select statement

/**
 *	Generic select sObject by ID
 *	@param Id The sObject record ID
 *	@return SObject
 */
	@AuraEnabled
	public static SObject selectById(Id recordId) {
		try {
			return new SObjectSelector.Generic(recordId.getSObjectType()).selectById(recordId);
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	//* Generic delete statement

/**
 *	Generic delete sObject by ID
 *	@param Id The sObject record ID
 */
	@AuraEnabled
	public static void deleteById(Id recordId) {
		try {
			SObject record = new SObjectSelector.Generic(recordId.getSObjectType()).selectById(recordId);
			SObjectUnitOfWork uow = new SObjectUnitOfWork(
				new List<Schema.SObjectType>{
					recordId.getSObjectType()
				}
			);
			uow.registerDeleted(record);
			uow.commitWork();
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	//* Generic update statement

/**
 *	Generic update records
 *	@param String A serialized list of sObjects
 */
	@AuraEnabled
	public static void updateRecords(String records) {
		try {
			List<SObject> values = (List<SObject>)System.JSON.deserialize(records, List<SObject>.class);
			SObjectUnitOfWork uow = new SObjectUnitOfWork(
				new List<Schema.SObjectType>{
					values[0].getSObjectType()
				}
			);
			uow.registerDirty(values);
			uow.commitWork();
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

/**
 *	Generic update record
 *	@param String A serialized sObject
 */
	@AuraEnabled
	public static void updateRecord(String record) {
		try {
			SObject value = (SObject)System.JSON.deserialize(record, SObject.class);
			SObjectUnitOfWork uow = new SObjectUnitOfWork(
				new List<Schema.SObjectType>{
					value.getSObjectType()
				}
			);
			uow.registerDirty(value);
			uow.commitWork();
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	//* Most recently viewed record

/**
 *	Get most recently viewed record
 *	@param String
 *	@return SObject
 */
	@AuraEnabled
	public static SObject getMostRecentlyViewedRecord(String sObjectName) {
		try {
			return [
				SELECT Id
				FROM RecentlyViewed
				WHERE Type = :sObjectName
				ORDER BY LastViewedDate DESC
				LIMIT 1
			];
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

/**
 *	Get most recently view record
 *	@param Schema.SObjectType
 *	@return SObject
 */
	public static SObject getMostRecentlyViewedRecord(Schema.SObjectType sObjectType) {
		return getMostRecentlyViewedRecord(sObjectType.getDescribe().getName());
	}

	//* Create ContentVersion

/**
 *	Create content version
 *	@param File
 */
	// @AuraEnabled
	// public static void createContentVersion(List<File> files, Id recordId) {
	// 	try {
	// 		SObjectUnitOfWork uow = new SObjectUnitOfWork(
	// 			new List<Schema.SObjectType>{
	// 				ContentVersion.SObjectType
	// 			}
	// 		);
	// 		for (File file : files) {
	// 			ContentVersion cv = file.toContentVersion();
	// 			cv.FirstPublishLocationId = recordId;
	// 			uow.registerNew(cv);
	// 		}
	// 		uow.commitWork();
	// 	} catch (Exception e) {
	// 		throw new AuraHandledException(e.getMessage());
	// 	}
	// }

	//* Get field set fields

/**
 *	Get Fieldset fields
 *	@param Schema.FieldSet
 *	@return List<String>
 */
	public static List<String> getFieldSetFields(Schema.FieldSet fieldSet) {
		List<String> result = new List<String>();
		if (fieldSet != null) {
			for (Schema.FieldSetMember fsm : fieldSet.getFields()) {
				result.add(fsm.getFieldPath());
			}
		}
		return result;
	}

/**
 *	Get Fieldset fields
 *	@param Schema.SObjectType
 *	@param String The field set name
 *	@return List<String>
 */
	public static List<String> getFieldSetFields(Schema.SObjectType sObjectType, String fieldSetName) {
		if (sObjectType != null) {
			Schema.FieldSet fieldSet = sObjectType.getDescribe().fieldSets.getMap().get(fieldSetName);
			return getFieldSetFields(fieldSet);
		}
		return new List<String>();
	}

/**
 *	Get Fieldset fields
 *	@param String The sObject name
 *	@param String The field set name
 *	@return List<String>
 */
	@AuraEnabled
	public static List<String> getFieldSetFields(String sObjectName, String fieldSetName) {
		Schema.SObjectType sObjectType = convertNameToType(sObjectName);
		return getFieldSetFields(sObjectType, fieldSetName);
	}

	//* Get field set fields described

/**
 *	Get Fieldset fields described
 *	@param Schema.SObjectType
 *	@param Schema.FieldSet
 *	@return List<Schema.DescribeFieldResult>
 */
	public static List<Schema.DescribeFieldResult> getFieldSetFieldsDesc(Schema.SObjectType sObjectType, Schema.FieldSet fieldSet) {
		List<Schema.DescribeFieldResult> result = new List<Schema.DescribeFieldResult>();
		if (fieldSet != null) {
			Map<String, Schema.SObjectField> sObjMap = getFieldMap(sObjectType);
			for (Schema.FieldSetMember fsm : fieldSet.getFields()) {
				List<String> split = fsm.getFieldPath().split('\\.');
				String fieldPath;
				if (split.size() > 1) {
					fieldPath = split[split.size() - 2].replace('__r', '__c');
				} else {
					fieldPath = fsm.getFieldPath();
				}
				if (sObjMap.get(fieldPath) != null) {
					result.add(sObjMap.get(fieldPath).getDescribe());
				}
			}
		}
		return result;
	}

/**
 *	Get Fieldset fields described
 *	@param Schema.SObjectType
 *	@param String The field set name
 *	@return List<Schema.DescribeFieldResult>
 */
	public static List<Schema.DescribeFieldResult> getFieldSetFieldsDesc(Schema.SObjectType sObjectType, String fieldSetName) {
		if (sObjectType != null && String.isNotBlank(fieldSetName)) {
			Schema.FieldSet fieldSet = sObjectType.getDescribe().fieldSets.getMap().get(fieldSetName);
			return getFieldSetFieldsDesc(sObjectType, fieldSet);
		}
		return new List<Schema.DescribeFieldResult>();
	}

/**
 *	Get Fieldset fields described
 *	@param String The sObject name
 *	@param String The field set name
 *	@return String
 */
	@AuraEnabled
	public static String getFieldSetFieldsDesc(String sObjectName, String fieldSetName) {
		Schema.SObjectType sObjectType = convertNameToType(sObjectName);
		return System.JSON.serialize(getFieldSetFieldsDesc(sObjectType, fieldSetName));
	}

	//* Get picklist values

/**
 *	Get picklist values aka: labels
 *	@param Schema.SObjectField
 *	@return List<String>
 */
	public static List<String> getPicklistValues(Schema.SObjectField field) {
		Set<String> result = getPicklistValueByLabel(field).keySet();
		return new List<String>(result);
	}

/**
 *	Get map of picklist value by label
 *	@param Schema.SObjectField
 *	@return Map<String,String>
 */
	public static Map<String, String> getPicklistValueByLabel(Schema.SObjectField field) {
		Map<String, String> result = new Map<String, String>();
		if (field != null) {
			Schema.DescribeFieldResult fieldResult = field.getDescribe();
			if (fieldResult.getType() == Schema.DisplayType.PICKLIST || fieldResult.getType() == Schema.DisplayType.MULTIPICKLIST) {
				for (Schema.PicklistEntry ple : fieldResult.getPicklistValues()) {
					if (ple.isActive()) {
						result.put(ple.getLabel(), ple.getValue());
					}
				}
			}
		}
		return result;
	}

/**
 *	Get picklist values aka: labels
 *	@param String The sObject name
 *	@param String The sObject field name
 *	@return List<String>
 */
	@AuraEnabled
	public static List<String> getPicklistValues(String sObjectName, String fieldName) {
		return getPicklistValues(getAllFields(sObjectName).get(fieldName));
	}

/**
 *	Get country picklist values aka: labels
 *	@return List<String>
 */
	// @AuraEnabled
	// public static List<String> getCountryPicklistValues() {
	// 	List<String> result = new List<String>();
	// 	if (!isStateCountryPicklistEnabled()) {
	// 		return result;
	// 	}
	// 	// TODO: how the hell to do this with scheme types
	// 	// 		when the org does not have state/country picklists enabled?????????
	// 	Schema.DescribeFieldResult fieldResult = Schema.User.CountryCode.getDescribe();
	// 	// SObject user = User.getSObjectType();
	// 	// Schema.SObjectField field = user.get('CountryCode');
	// 	for (Schema.PicklistEntry ple : fieldResult.getPicklistValues()) {
	// 		if (ple.isActive()) {
	// 			result.add(ple.getLabel());
	// 		}
	// 	}
	// 	return result;
	// }

/**
 *	Get state picklist values aka: labels
 *	@return List<String>
 */
	// @AuraEnabled
	// public static List<String> getStatePicklistValues() {
	// 	List<String> result = new List<String>();
	// 	if (!isStateCountryPicklistEnabled()) {
	// 		return result;
	// 	}
	// 	Schema.DescribeFieldResult fieldResult = Schema.User.StateCode.getDescribe();
	// 	for (Schema.PicklistEntry ple : fieldResult.getPicklistValues()) {
	// 		if (ple.isActive()) {
	// 			result.add(ple.getLabel());
	// 		}
	// 	}
	// 	return result;
	// }

	//* Get reference to

/**
 *	Get sObject references to an sObject field
 *	@param Schema.SObjectField
 *	@return Set<Schema.SObjectType>
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
 *	Get sObject references to an sObject field
 *	@param String The sObject name
 *	@param String The sObject field
 *	@return Set<Schema.SObjectType>
 */
	public static Set<Schema.SObjectType> getReferenceTo(String sObjectName, String fieldName) {
		return getReferenceTo(getAllFields(sObjectName).get(fieldName));
	}

	//* Get accessible fields

/**
 *	Get accessible fields
 *	@param Schema.SObjectType The sObject type
 *	@return List<String>
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
 *	Get accessible fields
 *	@param Id The sObject id
 *	@return List<String>
 */
	public static List<String> getAccessibleFields(Id recordId) {
		return getAccessibleFields(convertIdToType(recordId));
	}

/**
 *	Get accessible fields
 *	@param String The sObject name
 *	@return List<String>
 */
	@AuraEnabled
	public static List<String> getAccessibleFields(String sObjectName) {
		return getAccessibleFields(convertNameToType(sObjectName));
	}

	//* Get accessible fields by type

/**
 *	Get fields by type
 *	@param Schema.SObjectType The sObject type
 *	@param Schema.DisplayType The field type
 *	@return List<String>
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
 *	Get field by type
 *	@param String The sObject name
 *	@param Schema.DisplayType The field type
 *	@return List<String>
 */
	public static List<String> getAccessibleFields(String sObjectName, Schema.DisplayType displayType) {
		return getAccessibleFields(convertNameToType(sObjectName), displayType);
	}

/**
 *	Get field by type
 *	@param String The sObject name
 *	@param String The field type
 *	@return List<String>
 */
	@AuraEnabled
	public static List<String> getAccessibleFields(String sObjectName, String fieldType) {
		Schema.DisplayType displayType;
		if (String.isNotBlank(fieldType)) {
			for (Schema.DisplayType type : Schema.DisplayType.values()) {
				if (type.name().toUpperCase() == fieldType.toUpperCase()) {
					displayType = type;
					break;
				}
			}
		}
		return getAccessibleFields(convertNameToType(sObjectName), displayType);
	}

	//* Get updateable fields

/**
 *	Get updatable fields
 *	@param Schema.SObjectType The sObject type
 *	@return List<String>
 */
	public static List<String> getUpdateableFields(Schema.SObjectType sObjectType) {
		List<String> result = new List<String>();
		if (sObjectType != null) {
			for (Schema.SObjectField field : getAllFields(sObjectType).values()) {
				Schema.DescribeFieldResult fieldDesc = field.getDescribe();
				if (fieldDesc.isAccessible() && fieldDesc.isUpdateable()) {
					result.add(fieldDesc.getName());
				}
			}
		}
		return result;
	}

/**
 *	Get updatable fields
 *	@param Id The sObject id
 *	@return List<String>
 */
	@AuraEnabled
	public static List<String> getUpdateableFields(Id recordId) {
		return getUpdateableFields(convertIdToType(recordId));
	}

/**
 *	Get updatable fields
 *	@param String The sObject name
 *	@return List<String>
 */
	@AuraEnabled
	public static List<String> getUpdateableFields(String sObjectName) {
		return getUpdateableFields(convertNameToType(sObjectName));
	}

	//* Get record types

/**
 *	Get record types
 *	@param String sObjectName
 */
	@AuraEnabled
	public static Map<Id, String> getRecordTypes(String sObjectName) {
		return getRecordTypes(convertNameToType(sObjectName));
	}

	public static Map<Id, String> getRecordTypes(Schema.SObjectType sObjectType) {
		Map<Id, String> result = new Map<Id, String>();
		if (sObjectType != null) {
			for (Schema.RecordTypeInfo info : sObjectType.getDescribe().getRecordTypeInfos()) {
				// active, available and not master
				if (info.isActive() && info.isAvailable() && !info.isMaster()) {
					result.put(info.getRecordTypeId(), info.getName());
				}
			}
		}
		return result;
	}

/**
 *	Get record type id
 *	@param Schema.DescribeSObjectResult The sObjectDescribe
 *	@param String The record type name
 *	@return Id The record type ID
 */
	public static Id getRecordTypeId(Schema.DescribeSObjectResult sObjectDesc, String recTypeName) {
		if (sObjectDesc != null && String.isNotBlank(recTypeName)) {
			Map<String, Schema.RecordTypeInfo> recordTypeMap = sObjectDesc.getRecordTypeInfosByName();
			if (recordTypeMap.get(recTypeName) != null) {
				return recordTypeMap.get(recTypeName).getRecordTypeId();
			}
		}
		return null;
	}

/**
 *	Get record type id
 *	@param Schema.SObjectType The sObjectType
 *	@param String The record type name
 *	@return Id The record type ID
 */
	public static Id getRecordTypeId(Schema.SObjectType sObjectType, String recTypeName) {
		if (sObjectType != null) {
			return getRecordTypeId(sObjectType.getDescribe(), recTypeName);
		}
		return null;
	}

/**
 *	Get record type id
 *	@param SObject The sObject
 *	@param String The record type name
 *	@return Id The record type ID
 */
	public static Id getRecordTypeId(SObject sObj, String recTypeName) {
		if (sObj != null) {
			return getRecordTypeId(sObj.getSObjectType(), recTypeName);
		}
		return null;
	}

/**
 *	Get record type id
 *	@param String The sObject name
 *	@param String The record type name
 *	@return Id The record type ID
 */
	@AuraEnabled
  public static Id getRecordTypeId(String sObjectName, String recTypeName) {
		return getRecordTypeId(convertNameToType(sObjectName), recTypeName);
	}

/**
 *	Get record type label
 *	@param Schema.DescribeSObjectResult The sObjectDescribe
 *	@param Id The record type id
 *	@return String The record type label
 */
	public static String getRecordTypeLabel(Schema.DescribeSObjectResult sObjectDesc, Id recTypeId) {
		if (sObjectDesc != null && String.isNotBlank(recTypeId)) {
			Map<Id, Schema.RecordTypeInfo> recordTypeMap = sObjectDesc.getRecordTypeInfosById();
			if (recordTypeMap.get(recTypeId) != null) {
				return recordTypeMap.get(recTypeId).getName();
			}
		}
		return null;
	}

/**
*	Get record type label
*	@param Schema.SObjectType The sObjectType
*	@param Id The record type id
*	@return String The record type label
*/
	public static String getRecordTypeLabel(Schema.SObjectType sObjectType, Id recTypeId) {
		if (sObjectType != null) {
			return getRecordTypeLabel(sObjectType.getDescribe(), recTypeId);
		}
		return null;
	}

/**
*	Get record type label
*	@param SObject The sObject
*	@param Id The record type id
*	@return String The record type label
*/
	public static String getRecordTypeLabel(SObject sObj, Id recTypeId) {
		if (sObj != null) {
			return getRecordTypeLabel(sObj.getSObjectType(), recTypeId);
		}
		return null;
	}

/**
*	Get record type label
*	@param String The sObject name
*	@param Id The record type id
*	@return String The record type label
*/
	@AuraEnabled
	public static String getRecordTypeLabel(String sObjectName, Id recTypeId) {
		return getRecordTypeLabel(convertNameToType(sObjectName), recTypeId);
	}
	
/**
 *	Get record type name
 *	@param Schema.DescribeSObjectResult The sObjectDescribe
 *	@param Id The record type id
 *	@return String The record type name
 */
	public static String getRecordTypeName(Schema.DescribeSObjectResult sObjectDesc, Id recTypeId) {
		if (sObjectDesc != null && String.isNotBlank(recTypeId)) {
			Map<Id, Schema.RecordTypeInfo> recordTypeMap = sObjectDesc.getRecordTypeInfosById();
			if (recordTypeMap.get(recTypeId) != null) {
				return recordTypeMap.get(recTypeId).getDeveloperName();
			}
		}
		return null;
	}

/**
 *	Get record type name
 *	@param Schema.SObjectType The sObjectType
 *	@param Id The record type id
 *	@return String The record type name
 */
	public static String getRecordTypeName(Schema.SObjectType sObjectType, Id recTypeId) {
		if (sObjectType != null) {
			return getRecordTypeName(sObjectType.getDescribe(), recTypeId);
		}
		return null;
	}

/**
 *	Get record type name
 *	@param SObject The sObject
 *	@param Id The record type id
 *	@return String The record type name
 */
	public static String getRecordTypeName(SObject sObj, Id recTypeId) {
		if (sObj != null) {
			return getRecordTypeName(sObj.getSObjectType(), recTypeId);
		}
		return null;
	}

/**
 *	Get record type name
 *	@param String The sObject name
 *	@param Id The record type id
 *	@return String The record type name
 */
	@AuraEnabled
	public static String getRecordTypeName(String sObjectName, Id recTypeId) {
		return getRecordTypeName(convertNameToType(sObjectName), recTypeId);
	}

	//* Get relationship names

/**
 *	Get relationship name from SObjectField
 *	@param Schema.SObjectField
 *	@return String
 */
	public static String getRelationshipName(Schema.SObjectField field) {
		return field.getDescribe().getRelationshipName();
	}

/**
 *	Get relationship name from SObjectField
 *	@param Schema.SObjectType
 *	@param String
 *	@return String
 */
	public static String getRelationshipName(Schema.SObjectType sObjectType, String fieldName) {
		return getRelationshipName(getFieldMap(sObjectType).get(fieldName));
	}

/**
 *	Get relationship name from field name
 *	@param String
 *	@param String
 *	@return String
 */
	@AuraEnabled
	public static String getRelationshipName(String sObjectName, String fieldName) {
		return getRelationshipName(globalDescribe.get(sObjectName), fieldName);
	}

/**
 *	Get child relationship name
 *	@param Schema.SObjectType
 *	@param Schema.SObjectField
 *	@return String
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
 *	Get child relationship name
 *	@param String
 *	@param String
 *	@return String
 */
	@AuraEnabled
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
 *	Set an assignment rule on an sObject
 *	@param SObject
 *	@return SObject
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

	//* Copy address fields

/**
 *	Copy address fields
 *	@param System.Address The address to copy from
 *	@param SObject The sObject to copy the address to
 */
	public static void copyToAddress(System.Address addr, SObject obj) {
		if (addr != null && obj != null) {
			obj.put('City', addr.getCity());
			obj.put('Country', addr.getCountry());
			obj.put('CountryCode', addr.getCountryCode());
			obj.put('PostalCode', addr.getPostalCode());
			obj.put('State', addr.getState());
			obj.put('StateCode', addr.getStateCode());
			obj.put('Street', addr.getStreet());
			obj.put('Latitude', addr.getLatitude());
			obj.put('Longitude', addr.getLongitude());
		}
	}

/**
 *	Copy address fields
 *	@param SObject The sObject to copy the address from
 *	@param SObject The sObject to copy the address to
 */
	public static void copyToAddress(SObject fromObj, SObject toObj) {
		if (fromObj != null && toObj != null) {
			toObj.put('City', fromObj.get('City'));
			toObj.put('Country', fromObj.get('Country'));
			toObj.put('CountryCode', fromObj.get('CountryCode'));
			toObj.put('PostalCode', fromObj.get('PostalCode'));
			toObj.put('State', fromObj.get('State'));
			toObj.put('StateCode', fromObj.get('StateCode'));
			toObj.put('Street', fromObj.get('Street'));
			toObj.put('Latitude', fromObj.get('Latitude'));
			toObj.put('Longitude', fromObj.get('Longitude'));
		}
	}

/**
 *	Copy billing address fields
 *	@param System.Address The address to copy from
 *	@param SObject The sObject to copy the address to
 */
	public static void copyToBillingAddress(System.Address addr, SObject obj) {
		if (addr != null && obj != null) {
			obj.put('BillingCity', addr.getCity());
			obj.put('BillingCountry', addr.getCountry());
			obj.put('BillingCountryCode', addr.getCountryCode());
			obj.put('BillingPostalCode', addr.getPostalCode());
			obj.put('BillingState', addr.getState());
			obj.put('BillingStateCode', addr.getStateCode());
			obj.put('BillingStreet', addr.getStreet());
			obj.put('BillingLatitude', addr.getLatitude());
			obj.put('BillingLongitude', addr.getLongitude());
		}
	}

/**
 *	Copy shipping address fields
 *	@param System.Address The address to copy from
 *	@param SObject The sObject to copy the address to
 */
	public static void copyToShippingAddress(System.Address addr, SObject obj) {
		if (addr != null && obj != null) {
			obj.put('ShippingCity', addr.getCity());
			obj.put('ShippingCountry', addr.getCountry());
			obj.put('ShippingCountryCode', addr.getCountryCode());
			obj.put('ShippingPostalCode', addr.getPostalCode());
			obj.put('ShippingState', addr.getState());
			obj.put('ShippingStateCode', addr.getStateCode());
			obj.put('ShippingStreet', addr.getStreet());
			obj.put('ShippingLatitude', addr.getLatitude());
			obj.put('ShippingLongitude', addr.getLongitude());
		}
	}

/**
 *	Is an address empty (skip checking country it defaults to US)
 *	@param System.Address
 *	@return Boolean
 */
	public static Boolean isAddressEmpty(System.Address addr) {
		return String.isBlank(addr?.getCity())
			&& String.isBlank(addr?.getPostalCode())
			&& String.isBlank(addr?.getState())
			&& String.isBlank(addr?.getStateCode())
			&& String.isBlank(addr?.getStreet());
	}

/**
 *	Is an address empty (skip checking country it defaults to US)
 *	@param SObject
 *	@return Boolean
 */
	public static Boolean isAddressEmpty(SObject obj) {
		return obj?.get('City') == null
			&& obj?.get('PostalCode') == null
			&& obj?.get('State') == null
			&& obj?.get('StateCode') == null
			&& obj?.get('Street') == null;
	}

/**
 *	Is billing address empty (skip checking country it defaults to US)
 *	@param SObject
 *	@return Boolean
 */
	public static Boolean isBillingAddressEmpty(SObject obj) {
		return obj?.get('BillingCity') == null
			&& obj?.get('BillingPostalCode') == null
			&& obj?.get('BillingState') == null
			&& obj?.get('BillingStateCode') == null
			&& obj?.get('BillingStreet') == null;
	}

/**
 *	Is shipping address empty (skip checking country it defaults to US)
 *	@param SObject
 *	@return Boolean
 */
	public static Boolean isShippingAddressEmpty(SObject obj) {
		return obj?.get('ShippingCity') == null
			&& obj?.get('ShippingPostalCode') == null
			&& obj?.get('ShippingState') == null
			&& obj?.get('ShippingStateCode') == null
			&& obj?.get('ShippingStreet') == null;
	}

/**
 *	Did the address change
 *	@param SObject
 *	@param SObject
 *	@return Boolean
 */
	public static Boolean hasAddressChanged(SObject newObj, SObject oldObj) {
		if (newObj == null || oldObj == null) {
			return false;
		}
		return newObj.get('City') != oldObj.get('City')
			|| newObj.get('State') != oldObj.get('State')
			|| newObj.get('StateCode') != oldObj.get('StateCode')
			|| newObj.get('Street') != oldObj.get('Street')
			|| newObj.get('PostalCode') != oldObj.get('PostalCode')
			|| newObj.get('Country') != oldObj.get('Country')
			|| newObj.get('CountryCode') != oldObj.get('CountryCode')
			|| newObj.get('Latitude') != oldObj.get('Latitude')
			|| newObj.get('Longitude') != oldObj.get('Longitude');
	}

/**
 *	Did the address change
 *	@param System.Address
 *	@param System.Address
 *	@return Boolean
 */
	public static Boolean hasAddressChanged(System.Address newAddr, System.Address oldAddr) {
		if (newAddr == null || oldAddr == null) {
			return false;
		}
		return newAddr.getCity() != oldAddr.getCity()
			|| newAddr.getState() != oldAddr.getState()
			|| newAddr.getStateCode() != oldAddr.getStateCode()
			|| newAddr.getStreet() != oldAddr.getStreet()
			|| newAddr.getPostalCode() != oldAddr.getPostalCode()
			|| newAddr.getCountry() != oldAddr.getCountry()
			|| newAddr.getCountryCode() != oldAddr.getCountryCode()
			|| newAddr.getLatitude() != oldAddr.getLatitude()
			|| newAddr.getLongitude() != oldAddr.getLongitude();
	}

	//* Lightning icon names

/**
 *	Get the sObject lightning icon name
 *	@param String The sObject name
 *	@return String The icon name formatted for slds
 */
	@AuraEnabled
	public static String getLightningIconName(String sObjectName) {
		if (String.isBlank(sObjectName)) {
			return 'standard:default';
		}
		String result = '';
		switch on sObjectName.toLowerCase() {
			when 'contractlineitem' {
				result = 'contract_line_item';
			}
			when 'order' {
				result = 'orders';
			}
			when 'orderitem' {
				result = 'order_item';
			}
			when 'pricebook2' {
				result = 'pricebook';
			}
			when 'productconsumed' {
				result = 'product_consumed';
			}
			when 'productitemtransaction' {
				result = 'product_item_transaction';
			}
			when 'productitem' {
				result = 'product_item';
			}
			when 'productrequestlineitem' {
				result = 'product_request_line_item';
			}
			when 'productrequest' {
				result = 'product_request';
			}
			when 'productrequired' {
				result = 'product_required';
			}
			when 'producttransfer' {
				result = 'product_transfer';
			}
			when 'product2' {
				result = 'product';
			}
			when 'quote' {
				result = 'quotes';
			}
			when 'resourceabsence' {
				result = 'resource_absence';
			}
			when 'resourcecapacity' {
				result = 'resource_capacity';
			}
			when 'resourcepreference' {
				result = 'resource_preference';
			}
			when 'returnorderlineitem' {
				result = 'return_order_line_item';
			}
			when 'returnorder' {
				result = 'return_order';
			}
			when 'serviceappointment' {
				result = 'service_appointment';
			}
			when 'servicecontract' {
				result = 'service_contract';
			}
			when 'servicecrewmember' {
				result = 'service_crew_member';
			}
			when 'servicecrew' {
				result = 'service_crew';
			}
			when 'servicereport' {
				result = 'service_report';
			}
			when 'serviceresource' {
				result = 'service_resource';
			}
			when 'serviceterritorylocation' {
				result = 'service_territory_location';
			}
			when 'serviceterritorymember' {
				result = 'service_territory_member';
			}
			when 'serviceterritory' {
				result = 'service_territory';
			}
			when 'skill' {
				result = 'resource_skill';
			}
			when 'timesheetentry' {
				result = 'timesheet_entry';
			}
			when 'workcapacitylimit' {
				result = 'work_capacity_limit';
			}
			when 'workcapacityusage' {
				result = 'work_capacity_usage';
			}
			when 'workorderlineitem' {
				result = 'work_order_item';
			}
			when 'workorder' {
				result = 'work_order';
			}
			when 'workqueue' {
				result = 'work_queue';
			}
			when 'worktypegroup' {
				result = 'work_type_group';
			}
			when 'worktype' {
				result = 'work_type';
			}
			when else {
				result = sObjectName.toLowerCase();
			}
		}
		return 'standard:' + result;
	}

/**
 *	Get the sObject lightning icon name
 *	@param Schema.SObjectType The sObject type
 *	@return String
 */
	public static String getLightningIconName(Schema.SObjectType sObjectType) {
		if (sObjectType != null) {
			return getLightningIconName(sObjectType.getDescribe().getName());
		}
		return null;
	}

/**
 *	Get the sObject lightning icon name
 *	@param SObject The sObject
 *	@return String
 */
	public static String getLightningIconName(SObject sObj) {
		if (sObj != null) {
			return getLightningIconName(sObj.getSObjectType());
		}
		return null;
	}

	//* Validation

/**
 *	Verify the passed in string is a valid sObject
 *	@param String The sObject name
 *	@return Boolean
 */
	@AuraEnabled
	public static Boolean isValid(String sObjectName) {
		Schema.SObjectType sObjectType;
		if (String.isNotBlank(sObjectName)) {
			 sObjectType = globalDescribe.get(sObjectName);
		}
		return sObjectType == null ? false : true;
	}

	@AuraEnabled
	public static Boolean isNotValid(String sObjectName) {
		return !isValid(sObjectName);
	}

/**
 *	Verify the passed in string is a valid field for an sObject (supports dot notation)
 *	@param String The sObject name
 *	@param String The field name
 *	@return Boolean
 */
	@AuraEnabled
	public static Boolean isValid(String sObjectName, String fieldName) {
		return isValid(convertNameToType(sObjectName), fieldName);
	}

	public static Boolean isValid(Schema.SObjectType sObjectType, String fieldName) {
		if (sObjectType != null) {
			List<String> split = fieldName.split('\\.');
			if (split.size() > 1) {
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
			return getFieldMap(sObjectType).containsKey(fieldName);
		}
		return false;
	}

	@AuraEnabled
	public static Boolean isNotValid(String sObjectName, String fieldName) {
		return !isValid(sObjectName, fieldName);
	}

	public static Boolean isNotValid(Schema.SObjectType sObjectType, String fieldName) {
		return !isValid(sObjectType, fieldName);
	}

/**
 *	Check if person accounts are enabled
 *	@return Boolean
 */
	public static Boolean isPersonAccountsEnabled() {
		return getFieldMap(Account.SObjectType).containsKey('isPersonAccount');
	}

/**
 *	Check if state/country picklists are enabled
 *	@return Boolean
 */
	public static Boolean isStateCountryPicklistEnabled() {
		return getFieldMap(Account.SObjectType).containsKey('BillingCountryCode');
	}

}
