/**
 * Created on Fri Jul 31 2020
 *
 * Copyright (c) 2020 MJ12358
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

// TODO: Allow relationship fields (you'll have to use strings)
// TODO: account for multiple sObjects with the same confidence level

public inherited sharing class SObjectMatcher {

  private Integer confidence;
  private Map<SObject, Integer> confidenceBySObject;
  private SObject record;
  private Schema.SObjectType sObjectType;
  private Integer threshold;
  private Map<Schema.SObjectField, Object> valueByField;

  public SObjectMatcher(Schema.SObjectType sObjectType, Map<Schema.SObjectField, Object> valueByField) {
    if (sObjectType == null) {
      throw new SObjectMatcherException('The sObject type must not be null');
    }
    if (valueByField == null || valueByField.isEmpty()) {
      throw new SObjectMatcherException('The field to value map must not be null or empty');
    }
    this.confidence = 0;
    this.confidenceBySObject = new Map<SObject, Integer>();
    this.sObjectType = sObjectType;
    this.valueByField = valueByField;
    this.threshold = 0;
  }

/**
 *  Allow setting a threshold for the confidence
 *  @param Integer
 *  @return SObjectMatcher
 */
  public SObjectMatcher setThreshold(Integer value) {
    if (value != null && value > 0) {
      if (value >= this.valueByField.size()) {
        throw new SObjectMatcherException('Threshold cannot be greater than the number of given fields');
      }
      this.threshold = value;
    }
    return this;
  }

/**
 *  Find the highest confidence sObject
 *  @param List<SObject>
 *  @return SObjectMatcher
 */
  public SObjectMatcher find(List<SObject> sObjects) {
    for (SObject sObj : sObjects) {
      Integer count = 0;
      // loop all the fields we want to match
      for (Schema.SObjectField field : this.valueByField.keySet()) {
        count += compare(sObj, field, this.valueByField.get(field));
      }
      this.confidenceBySObject.put(sObj, count);
    }
    // default to the first sObject
    SObject result = this.confidenceBySObject.isEmpty() ? null : new List<SObject>(this.confidenceBySObject.keySet())[0];
    // find the best result
    for (SObject sObj : this.confidenceBySObject.keySet()) {
      if (this.confidenceBySObject.get(sObj) > this.confidenceBySObject.get(result)) {
        this.confidence = this.confidenceBySObject.get(sObj);
        result = sObj;
      } else {
        this.confidence = this.confidenceBySObject.get(result);
      }
    }
    this.record = result;
    return this;
  }

/**
 *  Find the highest confidence sObject
 *  @return SObjectMatcher
 */
  public SObjectMatcher find() {
    List<SObject> sObjects;
    String query = generateQuery();
    if (String.isNotBlank(query)) {
      sObjects = Database.query(query);
    } else {
      sObjects = new List<SObject>();
    }
    return find(sObjects);
  }

/**
 *  Get the resulting confidence
 *  @return Integer
 */
  public Integer getConfidence() {
    return this.confidence;
  }

/**
 *  Get the resulting confidence map
 *  @return Map<SObject,Integer>
 */
  public Map<SObject, Integer> getConfidenceBySObject() {
    return this.confidenceBySObject;
  }

/**
 *  Get the resulting record
 *  Only return the record when the confidence is above the threshold
 *  @return SObject
 */
  public SObject getRecord() {
    if (this.confidence > this.threshold) {
      return this.record;
    }
    return null;
  }

/**
 *  Set a query for sObject gathering
 *  @param String The generated query is based on the provided fields in the valueByField property
 */
  private String generateQuery() {
    Set<String> fields = getDefaultFieldSet();
    String clause = '';
    String query = '';
    Boolean isFirstCondition = true;
    for (Schema.SObjectField field : this.valueByField.keySet()) {
      String fieldName = field.getDescribe().getName();
      Object fieldValue = this.valueByField.get(field);
      if (fieldValue != null && String.isNotBlank(String.valueOf(fieldValue))) {
        if (!isFirstCondition) {
          clause += ' OR ';
        } else {
          isFirstCondition = false;
        }
        fields.add(fieldName);
        clause += fieldName + ' = ' + formatFieldValue(field, fieldValue);
      }
    }
    if (String.isNotBlank(clause)) {
      fields.addAll(SObjectUtil.getAccessibleFields(this.sObjectType));
      query = String.format('SELECT {0}{1} FROM {2} WHERE {3} LIMIT {4}',
        new List<Object>{
          fields.contains('Id') ? '' : 'Id,',
          String.join(new List<String>(fields), ','),
          this.sObjectType,
          clause,
          System.Limits.getLimitQueryRows() - System.Limits.getQueryRows()
        }
      );
    }
    return query;
  }

/**
 *  Format the field value from the object type
 *  Its purpose is to only put quotes around field values that need them
 *  @param Schema.SObjectField
 *  @param Object The value to format
 *  @return Object The formatted object
 */
  private Object formatFieldValue(Schema.SObjectField field, Object fieldValue) {
    Schema.DescribeFieldResult fieldDesc = field.getDescribe();
    switch on fieldDesc.getType() {
      when Boolean, Currency, Double, Integer, Long, Percent {
        return fieldValue;
      }
      when Date {
        return DateUtil.toISODateString(String.valueOf(fieldValue));
      }
      when Datetime {
        return DateUtil.toISOString(String.valueOf(fieldValue));
      }
      when Time {
        return DateUtil.toISOTimeString(String.valueOf(fieldValue));
      }
      when else {
        return '\'' + String.escapeSingleQuotes(String.valueOf(fieldValue)) + '\'';
      }
    }
  }

/**
 *  Compare the sObject field value with the expected value
 *  @param SObject
 *  @param Schema.SObjectField
 *  @param Object
 *  @return Integer 1 if the values match otherwise 0
 */
  private Integer compare(SObject sObj, Schema.SObjectField field, Object valueToCompare) {
    Schema.DescribeFieldResult fieldDesc = field.getDescribe();
    try {
      Object value = sObj.get(fieldDesc.getName());
      if (value != null) {
        // if the string values match there is no need for further processing
        if (String.valueOf(value) == String.valueOf(valueToCompare)) {
          return 1;
        }
        // attempt coersion of field types
        switch on fieldDesc.getType() {
          when Currency, Double, Percent {
            if ((Double)value == Double.valueOf(valueToCompare)) {
              return 1;
            }
          }
          when Date {
            if ((Date)value == DateUtil.toDate(String.valueOf(valueToCompare))) {
              return 1;
            }
          }
          when Datetime {
            if ((Datetime)value == DateUtil.toDatetime(String.valueOf(valueToCompare))) {
              return 1;
            }
          }
          when Integer, Long {
            if ((Integer)value == Integer.valueOf(valueToCompare)) {
              return 1;
            }
          }
          when Phone {
            if (StringUtil.getDigits((String)value) == StringUtil.getDigits(String.valueOf(valueToCompare))) {
              return 1;
            }
          }
        }
      }
    } catch (Exception e) {
      // hey, we did our best
    }
    return 0;
  }

  private Set<String> getDefaultFieldSet() {
    Set<String> fields = new Set<String>();
    for (Schema.SObjectField field : this.sObjectType.getDescribe().fields.getMap().values()) {
      Schema.DescribeFieldResult fieldDesc = field.getDescribe();
      // exclude managed package fields
      if (fieldDesc.getName().countMatches('__') <= 1) {
        fields.add(fieldDesc.getName());
      }
    }
    return fields;
  }

}
