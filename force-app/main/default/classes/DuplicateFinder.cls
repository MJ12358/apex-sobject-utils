/**
 * Created on Fri Oct 15 2021
 *
 * Copyright (c) 2021 Matt Jants
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

// TODO: get by ruleName

public inherited sharing class DuplicateFinder {

	private String ruleName;
	private Integer confidence;
	private List<MatchRecordWrapper> records;

	public DuplicateFinder() {
		this.confidence = 5;
		this.records = new List<MatchRecordWrapper>();
	}

	public DuplicateFinder(String ruleName) {
		this();
		this.ruleName = ruleName;
		if ([SELECT Count() FROM DuplicateRule WHERE DeveloperName = :ruleName AND IsActive = true] <= 0) {
			throw new DuplicateFinderException(System.Label.SObjectDuplicateRuleInvalid);
		}
	}

/**
 *	Set the confidence level
 *	@param Integer
 */
	public DuplicateFinder setConfidence(Integer value) {
		if (value == null || value < 5 || value > 10) {
			throw new DuplicateFinderException(System.Label.SObjectDuplicateConfidenceInvalid);
		}
		this.confidence = value;
		return this;
	}

/**
 *	Find duplicates
 *	@param SObject
 */
	public DuplicateFinder find(SObject sObj) {
		return find(new List<SObject>{ sObj });
	}

/**
 *	Find duplicates
 *	@param List<SObject>
 */
	public DuplicateFinder find(List<SObject> sObjects) {
		List<Datacloud.FindDuplicatesResult> findDuplicateResults;

		try {
			findDuplicateResults = Datacloud.FindDuplicates.findDuplicates(sObjects);
		} catch (System.HandledException e) {
			throw new DuplicateFinderException(e.getMessage());
		}

		return find(findDuplicateResults);
	}

/**
 *	Find duplicates by id
 *	@param Id
 */
	public DuplicateFinder find(Id recordId) {
		return find(new List<Id>{ recordId });
	}

/**
 *	Find duplicates by id
 *	@param List<Id>
 */
	public DuplicateFinder find(List<Id> recordIds) {
		List<Datacloud.FindDuplicatesResult> findDuplicateResults;

		try {
			findDuplicateResults = Datacloud.FindDuplicatesByIds.findDuplicatesByIds(recordIds);
		} catch (System.HandledException e) {
			throw new DuplicateFinderException(e.getMessage());
		}

		return find(findDuplicateResults);
	}

/**
 *  Find
 * 	@param Datacloud.FindDuplicatesResult
 */
	private DuplicateFinder find(List<Datacloud.FindDuplicatesResult> findDuplicateResults) {
		for (Datacloud.FindDuplicatesResult findDupResult : findDuplicateResults) {
			
			List<Datacloud.DuplicateResult> duplicateResults = findDupResult.getDuplicateResults();
			for (Datacloud.DuplicateResult dupResult : duplicateResults) {
				
				String rule = dupResult.getDuplicateRule();
				List<Datacloud.MatchResult> matchResults = dupResult.getMatchResults();
				for (Datacloud.MatchResult matchResult : matchResults) {
					
					for (Datacloud.MatchRecord record : matchResult.getMatchRecords()) {
						this.records.add(new MatchRecordWrapper(record));
					}
				}
			}
		}
		return this;
	}

/**
 *	Get record
 *	@return SObject The best match or null if none
 */
	public SObject getRecord() {
		this.records.sort();
		for (MatchRecordWrapper wrap : this.records) {
			if (wrap.record.getMatchConfidence() > this.confidence) {
				return wrap.record.getRecord();
			}
		}
		return null;
	}

/**
 *  Get records
 *  @return List<SObject> All the duplicate records
 */
  public List<SObject> getRecords() {
    List<SObject> results = new List<SObject>();
    this.records.sort();
    for (MatchRecordWrapper wrap : this.records) {
      results.add(wrap.record);
    }
    return results;
  }

/**
 *	Get record populated with field data
 *		by default the record returned only contains "Compact Layout" fields
 *	@return SObject
 */
	public SObject getRecordPopulated() {
		SObject result = getRecord();
		if (result == null) {
			return result;
		}
		Id recordId = result.Id;
		String query = String.format('SELECT {0} FROM {1} WHERE Id = :recordId',
			new List<Object>{
				String.join(new List<String>(result.getSObjectType().getDescribe().fields.getMap().keySet()), ','),
				result.getSObjectType().getDescribe().getName()
			}
		);
		return Database.query(query)[0];
	}

/**
 * 	Datacloud.MatchRecord wrapper class
 * 		implements Comparable to allow sorting by confidence
 */
	private class MatchRecordWrapper implements Comparable {
		public Datacloud.MatchRecord record;

		public MatchRecordWrapper(Datacloud.MatchRecord record) {
			this.record = record;
		}

		public Integer compareTo(Object compareTo) {
			MatchRecordWrapper compare = (MatchRecordWrapper)compareTo;
			if (record.getMatchConfidence() > compare.record.getMatchConfidence()) {
				return 1;
			}
			if (record.getMatchConfidence() < compare.record.getMatchConfidence()) {
				return -1;
			}
			return 0;
		}
	}

}
