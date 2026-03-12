with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Strings.Fixed;

package body Sayabletime is

   function Is_Digit (C : Character) return Boolean is
   begin
      return C >= '0' and then C <= '9';
   end Is_Digit;

   type Time_Parse_Result is record
      Hour   : Integer := -1;
      Minute : Integer := -1;
      OK     : Boolean := False;
   end record;

   function Parse_Time (S : String) return Time_Parse_Result is
      R     : Time_Parse_Result;
      T_Str : Unbounded_String;
      Pos_T : Natural;
      Pos_P : Natural;
      Pos_Z : Natural;
   begin
      if S'Length = 0 then
         return R;
      end if;

      T_Str := To_Unbounded_String (S);

      --  Strip date part if ISO datetime
      Pos_T := Ada.Strings.Fixed.Index (S, "T");
      if Pos_T > 0 then
         T_Str := To_Unbounded_String
           (S (Pos_T + 1 .. S'Last));
      end if;

      --  Strip timezone
      declare
         TS : constant String := To_String (T_Str);
      begin
         Pos_P := Ada.Strings.Fixed.Index (TS, "+");
         if Pos_P > 0 then
            T_Str := To_Unbounded_String
              (TS (TS'First .. Pos_P - 1));
         end if;

         declare
            TS2 : constant String := To_String (T_Str);
         begin
            Pos_Z := Ada.Strings.Fixed.Index (TS2, "Z");
            if Pos_Z > 0 then
               T_Str := To_Unbounded_String
                 (TS2 (TS2'First .. Pos_Z - 1));
            end if;
         end;
      end;

      --  Parse HH:MM
      declare
         TS    : constant String := To_String (T_Str);
         Colon : Natural;
      begin
         Colon := Ada.Strings.Fixed.Index (TS, ":");
         if Colon = 0 then
            return R;
         end if;

         --  Parse hour
         declare
            H_Str : constant String :=
              TS (TS'First .. Colon - 1);
            H_Val : Integer := 0;
         begin
            for I in H_Str'Range loop
               if not Is_Digit (H_Str (I)) then
                  return R;
               end if;
               H_Val := H_Val * 10
                 + Character'Pos (H_Str (I))
                 - Character'Pos ('0');
            end loop;
            R.Hour := H_Val;
         end;

         --  Parse minute (strip seconds/fractional)
         declare
            Rest  : constant String :=
              TS (Colon + 1 .. TS'Last);
            M_Str : Unbounded_String;
            Dot   : Natural;
         begin
            --  Take only first 2 chars or until dot/colon
            Dot := Ada.Strings.Fixed.Index (Rest, ".");
            if Dot > 0 then
               M_Str := To_Unbounded_String
                 (Rest (Rest'First .. Dot - 1));
            else
               --  Check for second colon (seconds part)
               declare
                  C2 : constant Natural :=
                    Ada.Strings.Fixed.Index (Rest, ":");
               begin
                  if C2 > 0 then
                     M_Str := To_Unbounded_String
                       (Rest (Rest'First .. C2 - 1));
                  else
                     M_Str := To_Unbounded_String (Rest);
                  end if;
               end;
            end if;

            declare
               MS    : constant String := To_String (M_Str);
               M_Val : Integer := 0;
            begin
               for I in MS'Range loop
                  if not Is_Digit (MS (I)) then
                     return R;
                  end if;
                  M_Val := M_Val * 10
                    + Character'Pos (MS (I))
                    - Character'Pos ('0');
               end loop;
               R.Minute := M_Val;
            end;
         end;
      end;

      if R.Hour < 0 or else R.Hour > 23
        or else R.Minute < 0 or else R.Minute > 59
      then
         return R;
      end if;

      R.OK := True;
      return R;
   end Parse_Time;

   function Round_To_5 (M : Integer) return Integer is
   begin
      return ((M + 2) / 5) * 5;
   end Round_To_5;

   function Int_To_Str (N : Integer) return String is
      Raw : constant String := Ada.Strings.Fixed.Trim
        (Integer'Image (N), Ada.Strings.Left);
   begin
      return Raw;
   end Int_To_Str;

   function Zfill_2 (N : Integer) return String is
      Raw : constant String := Int_To_Str (N);
   begin
      if Raw'Length < 2 then
         return "0" & Raw;
      else
         return Raw;
      end if;
   end Zfill_2;

   function Replace_First
     (Tmpl : String; Marker : String; Replacement : String)
      return String
   is
      Pos : constant Natural :=
        Ada.Strings.Fixed.Index (Tmpl, Marker);
   begin
      if Pos = 0 then
         return Tmpl;
      end if;
      return Tmpl (Tmpl'First .. Pos - 1) & Replacement
        & Tmpl (Pos + Marker'Length .. Tmpl'Last);
   end Replace_First;

   function Find_Pattern
     (Clk     : Clock_Config;
      Rounded : Integer) return String
   is
   begin
      --  Find exact match
      for I in 1 .. Clk.Pattern_Count loop
         if Clk.Pattern_Keys (I) = Rounded then
            return To_String (Clk.Pattern_Vals (I));
         end if;
      end loop;

      --  Fall back to 0 pattern
      for I in 1 .. Clk.Pattern_Count loop
         if Clk.Pattern_Keys (I) = 0 then
            return To_String (Clk.Pattern_Vals (I));
         end if;
      end loop;

      return "{h}";
   end Find_Pattern;

   function Format_Natural
     (Loc  : Time_Locale;
      Hour : Integer;
      Min  : Integer) return String
   is
      Clk     : constant Clock_Config := Loc.Clock;
      Rounded : Integer;
      H       : Integer;
      H12     : Integer;
      Next_12 : Integer;
      Pattern : Unbounded_String;
   begin
      Rounded := Round_To_5 (Min);
      H := Hour;

      if Rounded = 60 then
         Rounded := 0;
         H := (H + 1) mod 24;
      end if;

      if Rounded = 0 then
         if H = 0 then
            return To_String (Clk.Midnight);
         end if;

         if H = 12 then
            return To_String (Clk.Noon);
         end if;
      end if;

      H12 := H mod 12;
      Next_12 := (H + 1) mod 12;

      Pattern := To_Unbounded_String
        (Find_Pattern (Clk, Rounded));

      declare
         Result : String :=
           Replace_First
             (To_String (Pattern), "{h}",
              To_String (Clk.Hours (H12)));
      begin
         Result := Replace_First
           (Result, "{next_h}",
            To_String (Clk.Hours (Next_12)));
         return Result;
      end;
   end Format_Natural;

   function Format_Digital
     (SC   : Short_Clock_Config;
      Hour : Integer;
      Min  : Integer) return String
   is
      Fmt    : constant String := To_String (SC.Format);
      H12    : Integer;
      Am_Pm  : Unbounded_String;
      Result : Unbounded_String;
   begin
      if SC.Use_24h then
         Result := To_Unbounded_String
           (Replace_First (Fmt, "{h}", Int_To_Str (Hour)));
         Result := To_Unbounded_String
           (Replace_First
              (To_String (Result), "{mm}",
               Zfill_2 (Min)));
         return To_String (Result);
      end if;

      H12 := Hour mod 12;
      if H12 = 0 then
         H12 := 12;
      end if;

      if SC.Has_Am_Pm then
         if Hour < 12 then
            Am_Pm := SC.Am_Str;
         else
            Am_Pm := SC.Pm_Str;
         end if;
      else
         if Hour < 12 then
            Am_Pm := To_Unbounded_String ("AM");
         else
            Am_Pm := To_Unbounded_String ("PM");
         end if;
      end if;

      Result := To_Unbounded_String
        (Replace_First (Fmt, "{h}", Int_To_Str (H12)));
      Result := To_Unbounded_String
        (Replace_First
           (To_String (Result), "{mm}", Zfill_2 (Min)));
      Result := To_Unbounded_String
        (Replace_First
           (To_String (Result), "{ampm}",
            To_String (Am_Pm)));
      return To_String (Result);
   end Format_Digital;

   function Format_Time
     (Loc  : Time_Locale;
      Comp : Compactness;
      Time : String) return String
   is
      Parsed : Time_Parse_Result;
   begin
      if Time'Length = 0 then
         return "";
      end if;

      Parsed := Parse_Time (Time);
      if not Parsed.OK then
         return "";
      end if;

      if Comp = Short and then Loc.Has_Short then
         return Format_Digital
           (Loc.Short_Clock, Parsed.Hour, Parsed.Minute);
      end if;

      if Comp = Compact and then Loc.Has_Compact then
         return Format_Digital
           (Loc.Compact_Clock, Parsed.Hour, Parsed.Minute);
      end if;

      return Format_Natural (Loc, Parsed.Hour, Parsed.Minute);
   end Format_Time;

end Sayabletime;
