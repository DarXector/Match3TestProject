package utils 
{
	/**
	 * Some Math operations to simplify operations
	 * @author Marko Ristic
	 */

	public class MathUtils 
	{
		/**
		 * Format miliseconds to 00:00:00 time format
         *
         * @oaram milliseconds
         * @param showMilli Do we show the milliseconds or just  00:00
		 */

		public static function toTimeCode(milliseconds:int, showMilli:Boolean = false) : String 
		{
			var isNegative:Boolean = false;
			if (milliseconds < 0) 
			{
				isNegative = true;
				milliseconds = Math.abs(milliseconds);
			}
			 
			var seconds:int = (milliseconds / 1000) % 60;
			var milli:int = Math.round((milliseconds % 1000) / 10);
			var miliS:String = String(milli);
			if (miliS.length < 2) miliS = '0'+miliS;
			else if (miliS.length > 2) miliS = miliS.substr(2,1);
			var strSeconds:String = (seconds < 10) ? ("0" + String(seconds)) : String(seconds);
			if(seconds == 60) strMinutes = "00";
			var minutes:int = Math.round(Math.floor((milliseconds/1000)/60));
			var strMinutes:String = (minutes < 10) ? ("0" + String(minutes)) : String(minutes);
			 
			if (minutes > 60) 
			{
				strSeconds = "60";
				strMinutes = "00";
			}
			 
			var timeCodeAbsolute:String = strMinutes + ":" + strSeconds+(showMilli? ':'+miliS:'');
			var timeCode:String = (isNegative) ? "-" + timeCodeAbsolute : timeCodeAbsolute;
			return timeCode;
		}

        /**
         * Get random number in range
         *
         * @oaram milliseconds
         * @param showMilli Do we show the milliseconds or just  00:00
         */

        public static function random(min:int, max:int):int {
            return Math.round(Math.random() * (max - min) + min);
        }
	}
}