module SayableAge
  enum PluralCategory
    Zero
    One
    Two
    Few
    Many
    Other
  end

  # Unit forms: either a plain string (invariant) or plural-category forms.
  struct UnitForms
    getter zero : String?
    getter one : String?
    getter two : String?
    getter few : String?
    getter many : String?
    getter other : String?
    getter invariant : String?

    def initialize(@invariant : String)
      @zero = nil
      @one = nil
      @two = nil
      @few = nil
      @many = nil
      @other = nil
    end

    def initialize(*, @zero : String? = nil, @one : String? = nil,
                   @two : String? = nil, @few : String? = nil,
                   @many : String? = nil, @other : String? = nil)
      @invariant = nil
    end

    def resolve(category : PluralCategory) : String
      return @invariant.not_nil! if @invariant
      case category
      when .zero?  then @zero || @other.not_nil!
      when .one?   then @one || @other.not_nil!
      when .two?   then @two || @other.not_nil!
      when .few?   then @few || @other.not_nil!
      when .many?  then @many || @other.not_nil!
      else              @other.not_nil!
      end
    end

    def is_invariant? : Bool
      !@invariant.nil?
    end
  end

  # Stage label: either a plain string or gendered (m/f).
  struct StageLabel
    getter plain : String?
    getter m : String?
    getter f : String?

    def initialize(@plain : String)
      @m = nil
      @f = nil
    end

    def initialize(*, @m : String, @f : String)
      @plain = nil
    end

    def resolve(gender : String? = nil) : String
      return @plain.not_nil! if @plain
      gender == "f" ? @f.not_nil! : @m.not_nil!
    end
  end

  # Compactness override for short/compact modes.
  struct CompactnessOverride
    getter units : Hash(String, UnitForms)?
    getter half : String?
    getter delimiter : String?
    getter just_born : String?

    def initialize(*, @units : Hash(String, UnitForms)? = nil,
                   @half : String? = nil,
                   @delimiter : String? = nil,
                   @just_born : String? = nil)
    end
  end

  # Locale definition for age formatting.
  struct AgeLocale
    getter code : String
    getter plural : Proc(Int32, PluralCategory)
    getter units : Hash(String, UnitForms)
    getter half : String
    getter delimiter : String
    getter just_born : String
    getter stages : Hash(String, StageLabel)
    getter short : CompactnessOverride?
    getter compact : CompactnessOverride?

    def initialize(*, @code, @plural, @units, @half, @delimiter,
                   @just_born, @stages, @short = nil, @compact = nil)
    end
  end

  # Resolve a unit count to its display string using locale rules.
  def self.resolve_unit(count : Int32, unit_forms : UnitForms, locale : AgeLocale, half : String = "") : String
    base_n = count.to_s

    n = if !half.empty? && half.includes?("{n}")
          half.sub("{n}", base_n)
        else
          base_n
        end

    template = if unit_forms.is_invariant?
                 unit_forms.resolve(PluralCategory::Other)
               else
                 cat = locale.plural.call(count)
                 unit_forms.resolve(cat)
               end

    result = template.sub("{n}", n)
    result = half.sub("{0}", result) if !half.empty? && half.includes?("{0}")
    result
  end
end
