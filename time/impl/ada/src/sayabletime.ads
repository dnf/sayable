with Sayabletime_Types; use Sayabletime_Types;

package Sayabletime is

   Version : constant String := "0.5.0";

   function Format_Time
     (Loc  : Time_Locale;
      Comp : Compactness;
      Time : String) return String;

end Sayabletime;
