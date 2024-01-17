/**
 * Copyright (c) 2012, FinancialForce.com, inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors 
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

/**
 * Provides an implementation of the Enterprise Application Architecture Unit Of Work, as defined by Martin Fowler
 *   http://martinfowler.com/eaaCatalog/unitOfWork.html
 *
 * "When you're pulling data in and out of a database, it's important to keep track of what you've changed; otherwise, 
 *  that data won't be written back into the database. Similarly you have to insert new objects you create and 
 *  remove any objects you delete."
 *
 * "You can change the database with each change to your object model, but this can lead to lots of very small database calls, 
 *  which ends up being very slow. Furthermore it requires you to have a transaction open for the whole interaction, which is 
 *  impractical if you have a business transaction that spans multiple requests. The situation is even worse if you need to
 *  keep track of the objects you've read so you can avoid inconsistent reads."
 *
 * "A Unit of Work keeps track of everything you do during a business transaction that can affect the database. When you're done, 
 *  it figures out everything that needs to be done to alter the database as a result of your work."
 *
 * In an Apex context this pattern provides the following specific benifits
 *  - Applies bulkfication to DML operations, insert, update and delete
 *  - Manages a business transaction around the work and ensures a rollback occurs (even when exceptions are later handled by the caller)
 *  - Honours dependency rules between records and updates dependent relationships automatically during the commit 
 **/

/**
 * Created on Thur Aug 8 2019
 *
 * Copyright (c) 2019 MJ12358
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

public inherited sharing class SObjectUnitOfWork {

  private IDml dmlImpl;
  
  private List<Schema.SObjectType> sObjectTypes = new List<Schema.SObjectType>();
  
  private Map<Schema.SObjectType, List<SObject>> newListByType = new Map<Schema.SObjectType, List<SObject>>();
  
  private Map<Schema.SObjectType, Map<Id, SObject>> dirtyMapByType = new Map<Schema.SObjectType, Map<Id, SObject>>();

  private Map<Schema.SObjectType, List<SObject>> upsertListByType = new Map<Schema.SObjectType, List<SObject>>();

  private Map<Schema.SObjectType, Schema.SObjectField> externalIdByType = new Map<Schema.SObjectType, Schema.SObjectField>();
  
  private Map<Schema.SObjectType, Map<Id, SObject>> deletedMapByType = new Map<Schema.SObjectType, Map<Id, SObject>>();
  
  private Map<Schema.SObjectType, Relationships> relationships = new Map<Schema.SObjectType, Relationships>();

/**
 * Constructs a new UnitOfWork to support work against the given object list
 *
 * @param sObjectList A list of objects given in dependency order (least dependent first)
 */
  public SObjectUnitOfWork(List<Schema.SObjectType> sObjectTypes) {
    this(sObjectTypes, new SimpleDml());
  }

  public SObjectUnitOfWork(List<Schema.SObjectType> sObjectTypes, Boolean enforceCrud) {
    this(sObjectTypes, enforceCrud ? (IDml)new SecureDml() : (IDml)new SimpleDml());
  }

  public SObjectUnitOfWork(List<Schema.SObjectType> sObjectTypes, Boolean enforceCrud, Boolean enforceFls) {
    this(sObjectTypes, enforceCrud ? (IDml)new SecureDml(enforceFls) : (IDml)new SimpleDml());
  }

  public SObjectUnitOfWork(List<Schema.SObjectType> sObjectTypes, IDml dmlImpl) {
    this.dmlImpl = dmlImpl;
    this.sObjectTypes = sObjectTypes.clone();
    
    for (Schema.SObjectType sObjectType : this.sObjectTypes) {
      this.newListByType.put(sObjectType, new List<SObject>());
      this.dirtyMapByType.put(sObjectType, new Map<Id, SObject>());
      this.upsertListByType.put(sObjectType, new List<SObject>());
      this.deletedMapByType.put(sObjectType, new Map<Id, SObject>());
      this.relationships.put(sObjectType, new Relationships());
    }
  }

/**
 *  Add an sObjectType to the unit of work
 *   this allows for a dynamic list of sObjectTypes
 *
 *  @param Schema.SObjectType The sObjectType to add
 */
  public void addSObjectType(Schema.SObjectType sObjectType) {
    if (!this.sObjectTypes.contains(sObjectType)) {
      this.sObjectTypes.add(sObjectType);
      this.newListByType.put(sObjectType, new List<SObject>());
      this.dirtyMapByType.put(sObjectType, new Map<Id, SObject>());
      this.upsertListByType.put(sObjectType, new List<SObject>());
      this.deletedMapByType.put(sObjectType, new Map<Id, SObject>());
      this.relationships.put(sObjectType, new Relationships());
    }
  }

  //* Insert
  
/**
 * Register a newly created SObject instance to be inserted when commitWork is called
 *
 * @param record A newly created SObject instance to be inserted during commitWork
 **/
  public void registerNew(SObject record) {
    if (record.Id != null) {
      throw new SObjectUnitOfWorkException(System.Label.SObjectUowNewRecordsInvalid);
    }
    Schema.SObjectType sObjectType = record.getSObjectType();
    if (!this.newListByType.containsKey(sObjectType)) {
      throw new SObjectUnitOfWorkException(String.format(System.Label.SObjectUowTypeInvalid,
        new List<Object>{
          sObjectType
        }
      ));
    }
    this.newListByType.get(sObjectType).add(record);
  }

  public void registerNew(List<SObject> records) {
    for (SObject record : records) {
      registerNew(record);
    }
  }

/**
 * Register a newly created SObject instance to be inserted when commitWork is called, 
 *   you may also provide a reference to the parent record instance (should also be registered as new separatly)
 *
 * @param record A newly created SObject instance to be inserted during commitWork
 * @param relatedToParentField A SObjectField reference to the child field that associates the child record with its parent
 * @param relatedToParentRecord A SObject instance of the parent record (should also be registered as new separatly)
 **/
  public void registerNew(SObject record, Schema.sObjectField relatedToParentField, SObject relatedToParentRecord) {
    registerNew(record);
    if (relatedToParentRecord != null && relatedToParentField != null) {
      registerRelationship(record, relatedToParentField, relatedToParentRecord);
    }
  }
  
/**
 * Register a relationship between two records that have yet to be inserted to the database. This information will be 
 *  used during the commitWork phase to make the references only when related records have been inserted to the database.
 *
 * @param record An existing or newly created record
 * @param relatedToField A SObjectField referene to the lookup field that relates the two records together
 * @param relatedTo A SObject instance (yet to be commited to the database)
 */
  public void registerRelationship(SObject record, Schema.sObjectField relatedToField, SObject relatedTo) {
    Schema.SObjectType sObjectType = record.getSObjectType();
    if (!this.newListByType.containsKey(sObjectType)) {
      throw new SObjectUnitOfWorkException(String.format(System.Label.SObjectUowTypeInvalid,
        new List<Object>{
          sObjectType
        }
      ));
    }
    this.relationships.get(sObjectType).add(record, relatedToField, relatedTo);
  }

  //* Update
  
/**
 * Register an existing record to be updated during the commitWork method
 *
 * @param record An existing record
 **/
  // TODO: Overload this method with the option to pass in a list of dirtyFields (List<Schema.SObjectField>)
  public void registerDirty(SObject record) {
    if (record.Id == null) {
      throw new SObjectUnitOfWorkException(System.Label.SObjectUowDirtyInvalid);
    }
    Schema.SObjectType sObjectType = record.getSObjectType();
    if (!this.dirtyMapByType.containsKey(sObjectType)) {
      throw new SObjectUnitOfWorkException(String.format(System.Label.SObjectUowTypeInvalid,
        new List<Object>{
          sObjectType
        }
      ));
    }
    // if the record isn't already registered as dirty
    if (!this.dirtyMapByType.get(sObjectType).containsKey(record.Id)) {
      this.dirtyMapByType.get(sObjectType).put(record.Id, record);
    } else {
      // update the registered records fields
      SObject registeredRecord = this.dirtyMapByType.get(sObjectType).get(record.Id);
      Map<String, Object> populatedFields = record.getPopulatedFieldsAsMap();
      Map<String, Schema.SObjectField> fieldMap = sObjectType.getDescribe().fields.getMap();
      // BUG: when selector is used this will just overwrite the registeredRecords values
      for (String field : populatedFields.keySet()) {
        if (fieldMap.get(field) != null && fieldMap.get(field).getDescribe().isUpdateable()) {
          Object value = populatedFields.get(field);
          registeredRecord.put(field, value);
        }
      }
      this.dirtyMapByType.get(sObjectType).put(record.Id, registeredRecord);
    }
  }

  public void registerDirty(List<SObject> records) {
    for (SObject record : records) {
      registerDirty(record);
    }
  }

  //* Upsert

/**
 * Register a new or existing record to be inserted/updated during the commitWork method
 *
 * @param record A new or existing record
 * @param externalId The external id field
 **/
  public void registerUpsert(SObject record, Schema.SObjectField externalId) {
    Schema.SObjectType sObjectType = record.getSObjectType();
    if (!this.upsertListByType.containsKey(sObjectType)) {
      throw new SObjectUnitOfWorkException(String.format(System.Label.SObjectUowTypeInvalid,
        new List<Object>{
          sObjectType
        }
      ));
    }
    if (externalId != null) {
      if (!sObjectType.getDescribe().fields.getMap().values().contains(externalId)) {
        throw new SObjectUnitOfWorkException(String.format(System.Label.SObjectUowExternalIdForSObjectInvalid,
          new List<Object>{
            externalId,
            sObjectType
          }
        ));
      }
      if (!externalId.getDescribe().isIdLookup()) {
        throw new SObjectUnitOfWorkException(String.format(System.Label.SObjectUowExternalIdForUpsertInvalid,
          new List<Object>{
            externalId,
            sObjectType
          }
        ));
      }
    }
    this.upsertListByType.get(sObjectType).add(record);
    this.externalIdByType.put(sObjectType, externalId);
  }

  public void registerUpsert(List<SObject> records, Schema.SObjectField externalId) {
    for (SObject record : records) {
      registerUpsert(record, externalId);
    }
  }

  public void registerUpsert(SObject record) {
    registerUpsert(record, null);
  }

  public void registerUpsert(List<SObject> records) {
    registerUpsert(records, null);
  }

  //* Delete
  
/**
 * Register an existing record to be deleted during the commitWork method
 *
 * @param record An existing record
 **/
  public void registerDeleted(SObject record) {
    if (record.Id == null) {
      throw new SObjectUnitOfWorkException(System.Label.SObjectUowDeleteInvalid);
    }
    Schema.SObjectType sObjectType = record.getSObjectType();
    if (!this.deletedMapByType.containsKey(sObjectType)) {
      throw new SObjectUnitOfWorkException(String.format(System.Label.SObjectUowTypeInvalid,
        new List<Object>{
          sObjectType
        }
      ));
    }
    this.deletedMapByType.get(sObjectType).put(record.Id, record);          
  }

  public void registerDeleted(List<SObject> records) {
    for (SObject record : records) {
      registerDeleted(record);
    }
  }
  
/**
 * Takes all the work that has been registered with the UnitOfWork and commits it to the database
 **/
  public void commitWork() {
    // Wrap the work in its own transaction 
    Savepoint sp = Database.setSavePoint();
    try { 
      // Insert by type
      for (Schema.SObjectType sObjectType : this.sObjectTypes) {
        Relationships relationships = this.relationships.get(sObjectType);
        relationships.resolve();
        this.dmlImpl.onInsert(this.newListByType.get(sObjectType));
        if (relationships.hasReflective()) {
          this.dmlImpl.onUpdate(relationships.getResolvedReflectiveRecords());
        }
      }
      // Update by type
      for (Schema.SObjectType sObjectType : this.sObjectTypes) {
        this.dmlImpl.onUpdate(this.dirtyMapByType.get(sObjectType).values());
      }
      // Upsert by type
      for (Schema.SObjectType sObjectType : this.sObjectTypes) {
        if (!this.upsertListByType.get(sObjectType).isEmpty()) {
          String listType = 'List<' + sObjectType.getDescribe().getName() + '>';
          List<SObject> castRecords = (List<SObject>)Type.forName(listType).newInstance();
          castRecords.addAll(this.upsertListByType.get(sObjectType));
          this.dmlImpl.onUpsert(castRecords, this.externalIdByType.get(sObjectType));
        }
      }
      // Delete by type (in reverse dependency order)
      Integer objectIdx = this.sObjectTypes.size() - 1;
      while (objectIdx >= 0) {
        this.dmlImpl.onDelete(this.deletedMapByType.get(this.sObjectTypes[objectIdx--]).values());
      }
    } catch (Exception e) {
      // Rollback
      Database.rollback(sp);
      // Throw exception on to caller
      throw e;
    }
  }

  public List<SObject> getNewRecords() {
    List<SObject> result = new List<SObject>();
    for (Schema.SObjectType sObjType : this.newListByType.keySet()) {
      result.addAll(this.newListByType.get(sObjType));
    }
    return result;
  }

  public Map<Id, SObject> getDirtyRecords() {
    Map<Id, SObject> result = new Map<Id, SObject>();
    for (Schema.SObjectType sObjType : this.dirtyMapByType.keySet()) {
      for (SObject sObj : this.dirtyMapByType.get(sObjType).values()) {
        result.put(sObj.Id, sObj);
      }
    }
    return result;
  }

  public Map<Id, SObject> getUpsertedRecords() {
    Map<Id, SObject> result = new Map<Id, SObject>();
    for (Schema.SObjectType sObjType : this.upsertListByType.keySet()) {
      for (SObject sObj : this.upsertListByType.get(sObjType)) {
        result.put(sObj.Id, sObj);
      }
    }
    return result;
  }

  public Map<Id, SObject> getDeletedRecords() {
    Map<Id, SObject> result = new Map<Id, SObject>();
    for (Schema.SObjectType sObjType : this.deletedMapByType.keySet()) {
      for (SObject sObj : this.deletedMapByType.get(sObjType).values()) {
        result.put(sObj.Id, sObj);
      }
    }
    return result;
  }

  public List<SObject> getRecords() {
    List<SObject> results = new List<SObject>();
    results.addAll(getNewRecords());
    results.addAll(getDirtyRecords().values());
    results.addAll(getUpsertedRecords().values());
    results.addAll(getDeletedRecords().values());
    return results;
  }

  //* Relationship classes
  
  private class Relationships {

    private List<Relationship> relationships = new List<Relationship>();
    private List<Relationship> reflectiveRelationships = new List<Relationship>();

    public void resolve() {
      // Resolve relationships
      for (Relationship relationship : this.relationships) {
        relationship.record.put(relationship.relatedToField, relationship.RelatedTo.Id);
      }
    }

    public void resolveReflective() {
      // Resolve reflective relationships
      for (Relationship relationship : this.reflectiveRelationships) {
        relationship.record.put(relationship.relatedToField, relationship.RelatedTo.Id);
      }
    }

    public Boolean hasReflective() {
      return this.reflectiveRelationships.size() > 0;
    }

    public List<SObject> getResolvedReflectiveRecords() {
      resolveReflective();
      List<SObject> records = new List<SObject>();
      for (Relationship relationship : this.reflectiveRelationships) {
        records.add(relationship.record);
      }
      return records;
    }
    
    public void add(SObject record, Schema.SObjectField relatedToField, SObject relatedTo) {
      // Relationship to resolve
      Relationship relationship = new Relationship();
      relationship.record = record;
      relationship.relatedToField = relatedToField;
      relationship.relatedTo = relatedTo;
      if (record.getSObjectType() == relatedTo.getSObjectType() && relatedTo.Id == null) {
        this.reflectiveRelationships.add(relationship);
      } else {
        this.relationships.add(relationship);
      }
    }

  }
  
  private class Relationship {

    public SObject record;
    public Schema.SObjectField relatedToField;
    public SObject relatedTo;

  }

}