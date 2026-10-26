with Sayableduration_Types; use Sayableduration_Types;

package Sayableduration is

   Version : constant String := "0.5.0";

   --  500 years, the same ceiling as sayable-age
   Max_Duration_Months : constant := 6000;

   function Format_Duration
     (Loc     : Duration_Locale;
      Comp    : Compactness;
      Seconds : Long_Long_Integer) return String;

   --  Timestamp mode: the absolute difference between two ISO timestamps.
   function Format_Duration
     (Loc    : Duration_Locale;
      Comp   : Compactness;
      Start  : String;
      Finish : String) return String;

   function Format_Since
     (Loc   : Duration_Locale;
      Comp  : Compactness;
      Start : String;
      As_Of : String) return String;

   function Format_Until
     (Loc    : Duration_Locale;
      Comp   : Compactness;
      Target : String;
      As_Of  : String) return String;

end Sayableduration;
