with Parenttime_Types; use Parenttime_Types;

package Parenttime is

   function Format_Age
     (Loc  : Locale;
      Comp : Compactness;
      DOB  : String;
      As_Of : String) return String;

   function Format_Stage
     (Loc    : Locale;
      DOB    : String;
      As_Of  : String;
      Gender : String := "") return String;

end Parenttime;
