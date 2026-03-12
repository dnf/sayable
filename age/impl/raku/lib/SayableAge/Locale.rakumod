use v6.d;

unit module SayableAge::Locale;

our sub resolve-stage($label, Str $gender = '') {
    if $label ~~ Associative {
        return $gender eq 'f' ?? $label<f> !! $label<m>;
    }
    return $label;
}

our sub resolve-unit(Int $count, $unit-forms, %locale, Str $half = '') {
    my $base-n = ~$count;

    my $n;
    if $half ne '' && $half.contains('{n}') {
        $n = $half.subst('{n}', $base-n);
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

    my $result = $template.subst('{n}', $n);

    if $half ne '' && $half.contains('{0}') {
        $result = $half.subst('{0}', $result);
    }

    return $result;
}
