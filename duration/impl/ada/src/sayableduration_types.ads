with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package Sayableduration_Types is

   type Plural_Category is (Zero, One, Two, Few, Many, Other);

   type Compactness is (Normal, Short, Compact);

   type Plural_Fn is
     access function (N : Natural) return Plural_Category;

   type Plural_Flags is array (Plural_Category) of Boolean;
   type Plural_Strings is
     array (Plural_Category) of Unbounded_String;

   type Unit_Forms is record
      Has_Simple : Boolean := False;
      Simple     : Unbounded_String := Null_Unbounded_String;
      Has_Form   : Plural_Flags := (others => False);
      Forms      : Plural_Strings :=
        (others => Null_Unbounded_String);
   end record;

   type Unit_Set is record
      Second : Unit_Forms;
      Minute : Unit_Forms;
      Hour   : Unit_Forms;
      Day    : Unit_Forms;
      Week   : Unit_Forms;
      Month  : Unit_Forms;
      Year   : Unit_Forms;
   end record;

   type Compactness_Override is record
      Has_Units     : Boolean := False;
      Has_Second    : Boolean := False;
      Second        : Unit_Forms;
      Has_Minute    : Boolean := False;
      Minute        : Unit_Forms;
      Has_Hour      : Boolean := False;
      Hour          : Unit_Forms;
      Has_Day       : Boolean := False;
      Day           : Unit_Forms;
      Has_Week      : Boolean := False;
      Week          : Unit_Forms;
      Has_Month     : Boolean := False;
      Month         : Unit_Forms;
      Has_Year      : Boolean := False;
      Year          : Unit_Forms;
      Has_Half      : Boolean := False;
      Half          : Unbounded_String := Null_Unbounded_String;
      Has_Delimiter : Boolean := False;
      Delimiter     : Unbounded_String := Null_Unbounded_String;
      Has_Ago       : Boolean := False;
      Ago           : Unbounded_String := Null_Unbounded_String;
      Has_In_Future : Boolean := False;
      In_Future     : Unbounded_String := Null_Unbounded_String;
   end record;

   type Duration_Locale is record
      Code             : Unbounded_String := Null_Unbounded_String;
      Plural           : Plural_Fn := null;
      Units            : Unit_Set;
      Half             : Unbounded_String := Null_Unbounded_String;
      Delimiter        : Unbounded_String := Null_Unbounded_String;
      Just_Now         : Unbounded_String := Null_Unbounded_String;
      Ago              : Unbounded_String := Null_Unbounded_String;
      In_Future        : Unbounded_String := Null_Unbounded_String;
      Has_Short        : Boolean := False;
      Short_Override   : Compactness_Override;
      Has_Compact      : Boolean := False;
      Compact_Override : Compactness_Override;
   end record;

   type Locale_Access is access all Duration_Locale;

end Sayableduration_Types;
