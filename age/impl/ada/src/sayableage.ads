with Sayableage_Types; use Sayableage_Types;

package Sayableage is

   Version : constant String := "0.5.0";

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

end Sayableage;
