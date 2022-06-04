/**
 * Created on Fri Mar 12 2021
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

public inherited sharing class OptionDml implements IDml {

	private Database.DMLOptions options;

	public OptionDml(Database.DMLOptions options) {
		if (options == null) {
			throw new IllegalArgumentException(System.Label.SObjectDmlOptionsInvalid);
		}
		this.options = options;
	}

	public void onInsert(List<SObject> records) {
		if (records == null || records.isEmpty()) {
			return;
		}
		Database.insert(records, this.options);
	}

	public void onUpdate(List<SObject> records) {
		if (records == null || records.isEmpty()) {
			return;
		}
		Database.update(records, this.options);
	}

	public void onUpsert(List<SObject> records, Schema.SObjectField externalId) {
		if (records == null || records.isEmpty()) {
			return;
		}
		if (externalId != null) {
			Database.upsert(records, externalId, getOptAllOrNone());
		} else {
			Database.upsert(records, getOptAllOrNone());
		}
	}

	public void onDelete(List<SObject> records) {
		if (records == null || records.isEmpty()) {
			return;
		}
		Database.delete(records, getOptAllOrNone());
	}

	private Boolean getOptAllOrNone() {
		if (this.options?.OptAllOrNone == true) {
			return this.options.OptAllOrNone;
		}
		return false;
	}

}
