with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package Sayabletime_Types is

   type Compactness is (Normal, Short, Compact);

   Max_Patterns : constant := 16;

   type Hour_Names is array (0 .. 11) of Unbounded_String;
   type Pattern_Key_Array is array (1 .. Max_Patterns) of Integer;
   type Pattern_Val_Array is
     array (1 .. Max_Patterns) of Unbounded_String;

   type Clock_Config is record
      Hours         : Hour_Names;
      Midnight      : Unbounded_String := Null_Unbounded_String;
      Noon          : Unbounded_String := Null_Unbounded_String;
      Pattern_Count : Natural := 0;
      Pattern_Keys  : Pattern_Key_Array := (others => 0);
      Pattern_Vals  : Pattern_Val_Array;
   end record;

   type Short_Clock_Config is record
      Use_24h    : Boolean := False;
      Format     : Unbounded_String := Null_Unbounded_String;
      Has_Am_Pm  : Boolean := False;
      Am_Str     : Unbounded_String := Null_Unbounded_String;
      Pm_Str     : Unbounded_String := Null_Unbounded_String;
   end record;

   type Time_Locale is record
      Code          : Unbounded_String := Null_Unbounded_String;
      Clock         : Clock_Config;
      Has_Short     : Boolean := False;
      Short_Clock   : Short_Clock_Config;
      Has_Compact   : Boolean := False;
      Compact_Clock : Short_Clock_Config;
   end record;

   type Locale_Access is access all Time_Locale;

end Sayabletime_Types;
