module SayableDuration
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
      when .zero? then @zero || @other.not_nil!
      when .one?  then @one || @other.not_nil!
      when .two?  then @two || @other.not_nil!
      when .few?  then @few || @other.not_nil!
      when .many? then @many || @other.not_nil!
      else             @other.not_nil!
      end
    end

    def is_invariant? : Bool
      !@invariant.nil?
    end
  end

  # Compactness override for short/compact modes.
  struct CompactnessOverride
    getter units : Hash(String, UnitForms)?
    getter half : String?
    getter delimiter : String?
    getter ago : String?
    getter in_future : String?

    def initialize(*, @units = nil, @half = nil, @delimiter = nil,
                   @ago = nil, @in_future = nil)
    end
  end

  # Locale definition for duration formatting.
  struct DurationLocale
    getter code : String
    getter plural : Proc(Int32, PluralCategory)
    getter units : Hash(String, UnitForms)
    getter half : String
    getter delimiter : String
    getter just_now : String
    getter ago : String
    getter in_future : String
    getter short : CompactnessOverride?
    getter compact : CompactnessOverride?

    def initialize(*, @code, @plural, @units, @half, @delimiter,
                   @just_now, @ago, @in_future, @short = nil, @compact = nil)
    end
  end

  # Resolve a unit count to its display string using locale rules.
  # When a half marker is applied, the plural category is forced to "other".
  def self.resolve_unit(count : Int32, unit_forms : UnitForms, locale : DurationLocale, half : String = "") : String
    base_n = count.to_s

    n = if !half.empty? && half.includes?("{n}")
          half.sub("{n}", base_n)
        else
          base_n
        end

    template = if unit_forms.is_invariant?
                 unit_forms.resolve(PluralCategory::Other)
               else
                 # Half-marked values use "other" plural (e.g. "1.5 hours" not "1.5 hour")
                 cat = half.empty? ? locale.plural.call(count) : PluralCategory::Other
                 unit_forms.resolve(cat)
               end

    result = template.sub("{n}", n)
    result = half.sub("{0}", result) if !half.empty? && half.includes?("{0}")
    result
  end
end
