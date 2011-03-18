package org.understandinguncertainty.QRISKLifetime
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import org.understandinguncertainty.QRISKLifetime.support.IntervalTimer;
	import org.understandinguncertainty.QRISKLifetime.vo.BaseHazard;
	import org.understandinguncertainty.QRISKLifetime.vo.LifetimeRiskRow;
	import org.understandinguncertainty.QRISKLifetime.vo.QResultVO;
	import org.understandinguncertainty.QRISKLifetime.vo.TimeTableRow;

	[Event(name="init", type="flash.events.Event")]
	[Event(name="complete", type="flash.events.Event")]
	public class LifetimeRisk extends EventDispatcher
	{

		public var annualRiskTable:LifetimeRiskTable;
		
		public function load(path:String):void
		{
			var timeTable:TimeTable = new TimeTable();
			timeTable.addEventListener(Event.COMPLETE, timeTableLoaded);
			timeTable.load(path);
		}

		public function timeTableLoaded(event:Event):void
		{
			dispatchEvent(new Event(Event.INIT));
		}
		
		/**
		 * 
		 * Create new array
		 * & form the product and sum as we go
		 * return the array
		 * NB need to multiply cif by 100 to get percentage
		 * 
		 * @param timeTable
		 * @param from
		 * @param a_cvd
		 * @param a_death
		 * @return 
		 * 
		 */
		public function produceLifetimeRiskTable(timeTable:TimeTable, 
												 from:int, 
												 a_cvd:Number, 
												 a_death:Number):LifetimeRiskTable
		{
			// // S_1, sum(S_1[n-1] * basehaz_cvd_1) 
			
			// // do the first S_1, cif_cvd_1
			// double *timeTableIndex = timeTable + from*3;
			var timeTableIndex:int = from;
			
			// double basehaz_cvd_0 = *(timeTableIndex+2);
			// double basehaz_death_0 = *(timeTableIndex+1);			
			// double basehaz_cvd_1 = basehaz_cvd_0 * exp(a_cvd);
			// double basehaz_death_1 = basehaz_death_0 * exp(a_death);
			timeTable.init(a_cvd, a_death);
			var baseHazard:BaseHazard = timeTable.getBaseHazardAt(timeTableIndex++);
			
			// double a = 1 - basehaz_cvd_1 - basehaz_death_1; 
			// // S_1
			// *(lifetimeRiskIndex++)=a;
			// // cif_cvd_1
			// *(lifetimeRiskIndex++)=0;
			var lifetimeRiskTable:LifetimeRiskTable = new LifetimeRiskTable();
			annualRiskTable = new LifetimeRiskTable();
			//lifetimeRiskTable = new LifetimeRiskTable();
			
			lifetimeRiskTable.push(1 - baseHazard.cvd_1 - baseHazard.death_1, 0, 0);
			annualRiskTable.push(1 - baseHazard.cvd_1 - baseHazard.death_1, 0, 0);
			
			// // next index
			// timeTableIndex+=3;
			
			// // do the rest
			// for (i=1; i < (to-from+1); i++, timeTableIndex+=3, lifetimeRiskIndex+=2) {
			
			var t:int = 0;
			for(var i:int=1; i < timeTable.length - from -1; i++) {
				
				// basehaz_cvd_0 = *(timeTableIndex+2);
				// basehaz_death_0 = *(timeTableIndex+1);
				// basehaz_cvd_1 = basehaz_cvd_0 * exp(a_cvd);
				// basehaz_death_1 = basehaz_death_0 * exp(a_death);
				baseHazard = timeTable.getBaseHazardAt(timeTableIndex++);
				
				// a = 1 - basehaz_cvd_1 - basehaz_death_1; 
				// // S_1
				//*lifetimeRiskIndex=*(lifetimeRiskIndex-2)*a;
				// // cif_cvd
				//*(lifetimeRiskIndex+1) = *(lifetimeRiskIndex-1) + *(lifetimeRiskIndex-2) * basehaz_cvd_1;
				lifetimeRiskTable.push(1 - baseHazard.cvd_1 - baseHazard.death_1, baseHazard.cvd_1, baseHazard.death_1);
				
				// populate the annual table if we've reached a year boundary
				var t1:int = timeTable.getTAt(i);
				if(t1 > t) {
					t = t1;
					annualRiskTable.rows[t] = lifetimeRiskTable.rows[i];
				}
				
			}
			
			return lifetimeRiskTable;
		}
		/*
		void lifetimeRiskInit(void) {
			loadTables();
		}
		
		void lifetimeRiskClose(void) {
			free(resultArray);
			free(timeTableFemale);
			free(timeTableMale);
		}
		*/
		
		public var result:QResultVO;
		
		private var intervalTimer:IntervalTimer = new IntervalTimer();
		
		// void lifetimeRisk(int cage, int sex, double a_cvd, double a_death, int noOfFollowupYears, double *result) {
		public function lifetimeRisk(path:String, cage:int, a_cvd:Number, a_death:Number, noOfFollowupYears:Number):void 
		{
			// int sage=30;
		 	// int lage=95;
			// int startRow;
			// int finishRow;
			// int resultArraySize;
			// double lifetimeRisk;
			// int followupIndex;
			// double nYearRisk;
			

			var sage:int = 30;
		 	var lage:int = 95;
			
			var timeTable:TimeTable = new TimeTable();
			timeTable.init(a_cvd, a_death);
			timeTable.addEventListener(Event.COMPLETE, function(event:Event):void {
				
//				var timeTableLoadTime:int = intervalTimer.readTime("timeTableLoadTime");
				
				// double *timeTable;
				// int arrayNumberOfRows;
				// if (sex==0) {
				//	timeTable = timeTableFemale;
				//	arrayNumberOfRows=arrayNumberOfRowsFemale;
				// }
				// else {
				//  	timeTable = timeTableMale;
				//  	arrayNumberOfRows=arrayNumberOfRowsMale;
				// }
				
				//// start row is the one with the first _t >= cage-sage
				// startRow=find_biggest_t_below_number_in_array(cage-sage, timeTable, arrayNumberOfRows)+1;
				//// last row in table has index arrayNumberOfRows -1
				// finishRow=arrayNumberOfRows-1;
				// resultArraySize = finishRow-startRow+1;
				//
				// resultArray = produceLifetimeRiskTable(timeTable, startRow, finishRow, a_cvd, a_death);
//				intervalTimer.time("biggest_t1");
				var startRow:int = timeTable.find_biggest_t_below(cage-sage)+1;
//				var biggest_t1:int=intervalTimer.readTime("biggest_t1");
				
//				intervalTimer.time("riskTable1");
				var lifetimeRiskTable:LifetimeRiskTable = 
				produceLifetimeRiskTable(timeTable, startRow, a_cvd, a_death);
//				var riskTable1:int = intervalTimer.readTime("riskTable1");
				
				//// get lifetime risk
				//// this is the last entry in the table!
				// lifetimeRisk = *(resultArray + 2*(resultArraySize-1) + 1);	
				var lifetimeRisk:Number = lifetimeRiskTable.lifetimeRisk;
				
				// get n-year risk
				var followupIndex:int = cage-sage+noOfFollowupYears;

				//// if too big, use lifetime risk instead!
				// if (followupIndex >= lage-sage) {
				//  	nYearRisk = lifetimeRisk;
				// }
				// else {
				//  	int followupRow = find_biggest_t_below_number_in_array(followupIndex, timeTable, arrayNumberOfRows);
				//		nYearRisk = *(resultArray + 2*(followupRow-startRow) + 1);	
				// }

				var nYearRisk:Number;
				if (followupIndex >= lage-sage) {
				  	nYearRisk = lifetimeRisk;
				}
				else {
//					intervalTimer.time("biggest_t2");
				  	var followupRow:int = timeTable.find_biggest_t_below(followupIndex);
//					var biggest_t2:int = intervalTimer.readTime("biggest_t2");
					nYearRisk = lifetimeRiskTable.getRiskAt(followupRow-startRow);	
				}
				
				// *result = nYearRisk;
				// *(result+1) = lifetimeRisk;
				result = new QResultVO(nYearRisk, lifetimeRisk);

//				trace("bt1", biggest_t1, "prTable", riskTable1, "bt2", biggest_t2, "ttLoadTime", timeTableLoadTime);
				dispatchEvent(new Event(Event.COMPLETE));
			});
			
//			intervalTimer.time("timeTableLoadTime");
			timeTable.load(path);
		}

		public function lifetimeRisk_int(path:String, cage:int, age_int:int, a_cvd:Number, a_death:Number, a_cvd_int:Number, a_death_int:Number, noOfFollowupYears:Number):void 
		{
			var sage:int = 30;
		 	var lage:int = 95;
			
			var timeTable:TimeTable = new TimeTable();
			timeTable.init(a_cvd, a_death);
			timeTable.addEventListener(Event.COMPLETE, function(event:Event):void {
				
				var startRow:int = timeTable.find_biggest_t_below(cage-sage)+1;
				var intRow:int = timeTable.find_biggest_t_below(age_int-sage)+1;
				
				var lifetimeRiskTable:LifetimeRiskTable = 
				produceLifetimeRiskTable(timeTable, startRow, intRow, a_cvd, a_death, a_cvd_int, a_death_int);

				var lifetimeRisk:Number = lifetimeRiskTable.lifetimeRisk;
				
				var followupIndex:int = cage-sage+noOfFollowupYears;

				var nYearRisk:Number;
				if (followupIndex >= lage-sage) {
				  	nYearRisk = lifetimeRisk;
				}
				else {
				  	var followupRow:int = timeTable.find_biggest_t_below(followupIndex);
					nYearRisk = lifetimeRiskTable.getRiskAt(followupRow-startRow);	
				}
				
				result = new QResultVO(nYearRisk, lifetimeRisk);

				dispatchEvent(new Event(Event.COMPLETE));
			});
			
			timeTable.load(path);
		}

	}
}