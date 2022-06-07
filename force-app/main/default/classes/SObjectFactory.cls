/**
 * Created on Thur Aug 8 2019
 *
 * Copyright (c) 2019 Matt Jants
 * All rights reserved.
 *
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

public inherited sharing abstract class SObjectFactory {

  private abstract Schema.SObjectType getSObjectType();

  private Integer count;
  private Integer recordIndex;
  private List<SObject> records;
  private Map<Schema.SObjectField, Object> fieldToValue;
  public static final AutoFieldValue DEFAULT_VALUE = new AutoFieldValue();

  public virtual Map<Schema.SObjectField, Object> getDefaultFieldToValue() {
    return new Map<Schema.SObjectField, Object>();
  }

  public SObjectFactory() {
    this.count = 1;
    this.recordIndex = 0;
    this.records = new List<SObject>();
    this.fieldToValue = getDefaultFieldToValue();
  }

  public SObjectFactory(Integer count) {
    this();
    if (count == null || count <= 0) {
      throw new SObjectFactoryException(System.Label.SObjectFactoryCountInvalid);
    }
    this.count = count;
  }

  public SObjectFactory(SObject sObj) {
    this();
    this.records = new List<SObject>{ sObj };
  }

  public void put(Schema.SObjectField field, Object value) {
    this.fieldToValue.put(field, value);
  }

  public void put(Schema.SObjectField field, SObject sObj) {
    this.fieldToValue.put(field, sObj.Id);
  }

  public void put(Schema.SObjectField field, Schema.SObjectType sObjectType) {
    this.fieldToValue.put(field, provideSObject(sObjectType));
  }

  public void build() {
    defineRequiredFields();
    while (this.records.size() < this.count) {
      SObject record = getSObjectType().newSObject();
      for (Schema.SObjectField field : this.fieldToValue.keySet()) {
        if (this.fieldToValue.get(field) instanceof AutoFieldValue) {
          Schema.DescribeFieldResult fieldDesc = field.getDescribe();
          Object defaultValue = fieldDesc.getDefaultValue();
          if (defaultValue == null || defaultValue == false) {
            record.put(field, getDefaultValue(fieldDesc));
          } else {
            record.put(field, defaultValue);
          }
        } else {
          record.put(field, getValue(this.fieldToValue.get(field)));
        }
      }
      this.recordIndex++;
      this.records.add(record);
    }
  }

  public void buildAndInsert() {
    build();
    List<Database.SaveResult> saveResults = Database.insert(this.records, false);
    List<String> listErrors = new List<String>();
    Integer i = 0;
    for (Database.SaveResult saveResult : saveResults) {
      if (saveResult.isSuccess()) {
        continue;
      }
      for (Database.Error error : saveResult.getErrors()) {
        System.debug(error);
        Set<String> fieldNames = new Set<String>{'Name', 'RecordTypeId'};
        fieldNames.addAll(error.getFields());
        List<String> listFieldValues = new List<String>();
        for (String fieldName : fieldNames) {
          Object fieldValue;
          try {
            fieldValue = this.records.get(i++).get(fieldName);
          } catch (Exception e) {
            // fail silently
          }
          if (fieldValue != null) {
            listFieldValues.add(fieldName + '=' + fieldValue);
          }
        }
        listErrors.add(String.format('{0} : {1} [{2}]',
          new List<String>{
            String.valueOf(error.getStatusCode()),
            error.getMessage(),
            String.join(listFieldValues, ', ')
          }
        ));
      }
      if (!listErrors.isEmpty()) {
        throw new System.DmlException(String.join(listErrors, '\n') + ' ' + getSObjectType());
      }
    }
  }

  public virtual SObject getRecord() {
    return getRecords().get(0);
  }

  public virtual List<SObject> getRecords() {
    if (this.records == null || this.records.isEmpty()) {
      throw new SObjectFactoryException('You must call build before getting records');
    }
    return this.records;
  }

  //* Utility methods

  protected void defineRequiredFields() {
    Schema.DescribeSObjectResult objDesc = getSObjectType().getDescribe();
    Map<String, Schema.SObjectField> fields = objDesc.fields.getMap();
    System.debug('SOBJECT TYPE: ' + getSObjectType());
    for (Schema.SObjectField field : fields.values()) {
      Schema.DescribeFieldResult fieldDesc = field.getDescribe();
      if (isRequiredField(fieldDesc) && this.fieldToValue.get(field) == null) {
        if (fieldDesc.getReferenceTo().size() == 0) {
          this.fieldToValue.put(field, new AutoFieldValue());
        } else if (fieldDesc.getRelationshipName() == 'RecordType') {
          System.debug('RECORD TYPE REQUIRED: ' + fieldDesc.getName() + ' :: ' + fieldDesc.getReferenceTo());
          this.fieldToValue.put(field, getRecordTypeId(objDesc));
        } else {
          System.debug('RELATIONSHIP REQUIRED: ' + fieldDesc.getName() + ' :: ' + fieldDesc.getReferenceTo());
          this.fieldToValue.put(field, provideSObject(fieldDesc.getReferenceTo().get(0)));
        }
      }
    }
  }

  protected Id getRecordTypeId(Schema.DescribeSObjectResult objDesc) {
    Id result;
    for (Schema.RecordTypeInfo recTypeDesc : objDesc.getRecordTypeInfos()) {
      if (recTypeDesc.isDefaultRecordTypeMapping()) {
        return recTypeDesc.getRecordTypeId();
      }
      result = recTypeDesc.getRecordTypeId();
    }
    return result;
  }

  protected virtual Boolean isRequiredField(Schema.DescribeFieldResult fieldDesc) {
    return
      (!fieldDesc.isDefaultedOnCreate()
      && !fieldDesc.isAutoNumber()
      && !fieldDesc.isNillable()
      && fieldDesc.isCreateable())
      || (fieldDesc.getRelationshipName() == 'RecordType')
      || (fieldDesc.getName() == 'Name' && fieldDesc.isCreateable());
  }

  protected virtual Object getValue(Object value) {
    if (value != null && value instanceof String) {
      String text = (String)value;
      if (text.containsIgnoreCase('{!index}')) {
        String pattern = '(?i)\\{!index\\}';
        text = text.replaceAll(pattern, this.recordIndex.format());
      }
      if (text.containsIgnoreCase('{!rand}')) {
        String pattern = '(?i)\\{!rand\\}';
        text = text.replaceAll(pattern, String.valueOf(System.Math.abs(System.Crypto.getRandomInteger())));
      }
      return text;
    }
    return value;
  }

  //* Default value methods

  private Object getDefaultValue(Schema.DescribeFieldResult fieldDesc) {
    if (fieldDesc == null) {
      return null;
    }
    switch on (fieldDesc.getType()) {
      when Anytype, String, TextArea {
        return getTextDefaultValue(fieldDesc);
      }
      when Base64 {
        return getBase64DefaultValue(fieldDesc);
      }
      when Boolean {
        return getBooleanDefaultValue(fieldDesc);
      }
      when Combobox, MultiPicklist, Picklist {
        return getPicklistDefaultValue(fieldDesc);
      }
      when Currency, Double, Long, Percent {
        return getNumberDefaultValue(fieldDesc);
      }
      when Date {
        return getDateDefaultValue(fieldDesc);
      }
      when Datetime {
        return getDatetimeDefaultValue(fieldDesc);
      }
      when Email {
        return getEmailDefaultValue(fieldDesc);
      }
      when Integer {
        return getIntegerDefaultValue(fieldDesc);
      }
      when Location {
        return getLocationDefaultValue(fieldDesc);
      }
      when Phone {
        return getPhoneDefaultValue(fieldDesc);
      }
      when Reference {
        System.debug(fieldDesc);
        return null; // TODO
      }
      when Time {
        return getTimeDefaultValue(fieldDesc);
      }
      when URL {
        return getURLDefaultValue(fieldDesc);
      }
      when else {
        throw new SObjectFactoryException('Unexpected field type found: ' + fieldDesc.getType());
      }
    }
  }
  
  protected virtual Blob getBase64DefaultValue(Schema.DescribeFieldResult fieldDesc) {
    return Blob.valueOf(this.recordIndex.format());
  }

  protected virtual Boolean getBooleanDefaultValue(Schema.DescribeFieldResult fieldDesc) {
    return false;
  }

  protected virtual Date getDateDefaultValue(Schema.DescribeFieldResult fieldDesc) {
    return Date.today();
  }

  protected virtual Datetime getDatetimeDefaultValue(Schema.DescribeFieldResult fieldDesc) {
    return Datetime.now();
  }

  protected virtual String getEmailDefaultValue(Schema.DescribeFieldResult fieldDesc) {
    return 'test' + this.recordIndex + '@email.com';
  }

  protected virtual System.Location getLocationDefaultValue(Schema.DescribeFieldResult fieldDesc) {
    return System.Location.newInstance(this.recordIndex, this.recordIndex);
  }

  protected virtual Integer getIntegerDefaultValue(Schema.DescribeFieldResult fieldDesc) {
    return Integer.valueOf(this.recordIndex);
  }

  protected virtual Decimal getNumberDefaultValue(Schema.DescribeFieldResult fieldDesc) {
    return Decimal.valueOf(this.recordIndex);
  }

  protected virtual String getPhoneDefaultValue(Schema.DescribeFieldResult fieldDesc) {
    return '(123) 456-789' + this.recordIndex;
  }

  protected virtual String getPicklistDefaultValue(Schema.DescribeFieldResult fieldDesc) {
    if (fieldDesc != null) {
      List<Schema.PicklistEntry> pickVals = fieldDesc.getPicklistValues();
      for (Schema.PicklistEntry pickVal : pickVals) {
        if (pickVal.isDefaultValue()) {
          return pickVal.getValue();
        }
      }
      return pickVals.get(0).getValue();
    }
    return null;
  }

  protected virtual String getTextDefaultValue(Schema.DescribeFieldResult fieldDesc) {
    return ('test' + this.recordIndex).left(fieldDesc.getLength());
  }

  protected virtual Time getTimeDefaultValue(Schema.DescribeFieldResult fieldDesc) {
    return Time.newInstance(12, 0, 0, 0);
  }

  protected virtual String getURLDefaultValue(Schema.DescribeFieldResult fieldDesc) {
    return 'http://test' + this.recordIndex + '.com';
  }

  public virtual Id getAdminProfile() {
    return [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
  }

  public virtual Id getStandardProfile() {
    return [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id;
  }

  public virtual Id getRestrictedProfile() {
    return [SELECT Id FROM Profile WHERE UserLicense.Name = 'Chatter External' LIMIT 1].Id;
  }

  //* Generic sObject provider

  public Id provideSObject(Schema.SObjectType sObjectType) {
    Generic factory = new Generic(sObjectType);
    factory.buildAndInsert();
    SObject sObj = factory.getRecord();
    return sObj.Id;
  }

  //* Generic sObject factory

  public class Generic extends SObjectFactory {

    public Schema.SObjectType sObjectType;

    public override Schema.SObjectType getSObjectType() {
      return this.sObjectType;
    }

    public Generic(Schema.SObjectType sObjectType) {
      this(sObjectType, 1);
    }

    public Generic(Schema.SObjectType sObjectType, Integer count) {
      super(count);
      this.sObjectType = sObjectType;
    }

  }

  //* Auto field value class

  public class AutoFieldValue {}

}