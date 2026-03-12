with Sayabledate_Types; use Sayabledate_Types;

package Sayabledate is

   Version : constant String := "0.5.0";

   function Format_Date
     (Loc  : Date_Locale;
      Comp : Compactness;
      Date : String) return String;

   function Format_Date_With_Year
     (Loc  : Date_Locale;
      Comp : Compactness;
      Date : String) return String;

   function Format_Relative
     (Loc   : Date_Locale;
      Comp  : Compactness;
      Date  : String;
      As_Of : String) return String;

end Sayabledate;
