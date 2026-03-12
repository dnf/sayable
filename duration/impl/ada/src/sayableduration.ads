with Sayableduration_Types; use Sayableduration_Types;

package Sayableduration is

   Version : constant String := "0.5.0";

   function Format_Duration
     (Loc     : Duration_Locale;
      Comp    : Compactness;
      Seconds : Integer) return String;

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
