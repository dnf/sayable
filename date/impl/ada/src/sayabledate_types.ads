with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package Sayabledate_Types is

   type Compactness is (Normal, Short, Compact);

   Max_Day_Format_Exceptions : constant := 32;

   type String_Array_12 is array (1 .. 12) of Unbounded_String;
   type String_Array_7  is array (1 .. 7)  of Unbounded_String;

   type Exception_Keys is
     array (1 .. Max_Day_Format_Exceptions) of Unbounded_String;
   type Exception_Vals is
     array (1 .. Max_Day_Format_Exceptions) of Unbounded_String;

   type Compactness_Override is record
      Has_Months                : Boolean := False;
      Months                    : String_Array_12;
      Has_Months_In_Date        : Boolean := False;
      Months_In_Date            : String_Array_12;
      Has_Weekdays              : Boolean := False;
      Weekdays                  : String_Array_7;
      Has_Day_Format            : Boolean := False;
      Day_Format                : Unbounded_String := Null_Unbounded_String;
      Has_Day_Format_Exceptions : Boolean := False;
      Day_Format_Exception_Count : Natural := 0;
      Day_Format_Exception_Keys : Exception_Keys;
      Day_Format_Exception_Vals : Exception_Vals;
      Has_Date_Pattern          : Boolean := False;
      Date_Pattern              : Unbounded_String := Null_Unbounded_String;
      Has_Date_Pattern_With_Year : Boolean := False;
      Date_Pattern_With_Year    : Unbounded_String := Null_Unbounded_String;
      Has_Today                 : Boolean := False;
      Today                     : Unbounded_String := Null_Unbounded_String;
      Has_Tomorrow              : Boolean := False;
      Tomorrow                  : Unbounded_String := Null_Unbounded_String;
      Has_Yesterday             : Boolean := False;
      Yesterday                 : Unbounded_String := Null_Unbounded_String;
   end record;

   type Date_Locale is record
      Code                    : Unbounded_String := Null_Unbounded_String;
      Months                  : String_Array_12;
      Weekdays                : String_Array_7;
      Day_Format              : Unbounded_String := Null_Unbounded_String;
      Day_Format_Exception_Count : Natural := 0;
      Day_Format_Exception_Keys : Exception_Keys;
      Day_Format_Exception_Vals : Exception_Vals;
      Date_Pattern            : Unbounded_String := Null_Unbounded_String;
      Date_Pattern_With_Year  : Unbounded_String := Null_Unbounded_String;
      Today                   : Unbounded_String := Null_Unbounded_String;
      Tomorrow                : Unbounded_String := Null_Unbounded_String;
      Yesterday               : Unbounded_String := Null_Unbounded_String;
      Has_Day_After_Tomorrow  : Boolean := False;
      Day_After_Tomorrow      : Unbounded_String := Null_Unbounded_String;
      Has_Day_Before_Yesterday : Boolean := False;
      Day_Before_Yesterday    : Unbounded_String := Null_Unbounded_String;
      Has_This_Weekday        : Boolean := False;
      This_Weekday            : Unbounded_String := Null_Unbounded_String;
      Has_Next_Weekday        : Boolean := False;
      Next_Weekday            : Unbounded_String := Null_Unbounded_String;
      Has_Last_Weekday        : Boolean := False;
      Last_Weekday            : Unbounded_String := Null_Unbounded_String;
      Has_Months_In_Date      : Boolean := False;
      Months_In_Date          : String_Array_12;
      Has_Short               : Boolean := False;
      Short_Override           : Compactness_Override;
      Has_Compact             : Boolean := False;
      Compact_Override         : Compactness_Override;
   end record;

   type Locale_Access is access all Date_Locale;

end Sayabledate_Types;
