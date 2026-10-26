use v6.d;

unit module SayableAge::Locale;

# Placeholders are matched on code points, not graphemes. Raku strings are
# graphemes, and a placeholder followed by a combining mark (Tamil "{h}" then
# U+0BC1) is the single grapheme "}" + U+0BC1, which .subst and .contains never
# match. Every occurrence is replaced, as in the other implementations.
my sub replace-placeholder(Str $template, Str $placeholder, Str $value --> Str) {
    my @text = $template.ords;
    my @hole = $placeholder.ords;
    my @out;
    my $i = 0;
    while $i < @text.elems {
        if $i + @hole.elems <= @text.elems && @text[$i ..^ $i + @hole.elems] eqv @hole.List {
            @out.append: $value.ords;
            $i += @hole.elems;
        }
        else {
            @out.push: @text[$i++];
        }
    }
    @out.chrs
}

my sub has-placeholder(Str $template, Str $placeholder --> Bool) {
    (',' ~ $template.ords.join(',') ~ ',').contains(',' ~ $placeholder.ords.join(',') ~ ',')
}

our sub resolve-stage($label, Str $gender = '') {
    if $label ~~ Associative {
        return $gender eq 'f' ?? $label<f> !! $label<m>;
    }
    return $label;
}

our sub resolve-unit(Int $count, $unit-forms, %locale, Str $half = '') {
    my $base-n = ~$count;

    my $n;
    if $half ne '' && has-placeholder($half, '{n}') {
        $n = replace-placeholder($half, '{n}', $base-n);
    } else {
        $n = $base-n;
    }

    my $template;
    if $unit-forms ~~ Associative {
        my $cat = %locale<plural>.($count);
        $template = $unit-forms{$cat} // $unit-forms<other>;
    } else {
        $template = $unit-forms;
    }

    my $result = replace-placeholder($template, '{n}', $n);

    if $half ne '' && has-placeholder($half, '{0}') {
        $result = replace-placeholder($half, '{0}', $result);
    }

    return $result;
}
