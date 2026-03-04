use strict;
use warnings;
use utf8;

package SayableAge::Locale;

sub resolve_stage {
  my ($label, $gender) = @_;
  return $label unless ref $label eq 'HASH';
  return (defined $gender && $gender eq 'f') ? $label->{f} : $label->{m};
}

sub resolve_unit {
  my ($count, $unit_forms, $locale, $half) = @_;
  $half = '' unless defined $half;

  my $base_n = "$count";

  my $n;
  if ($half ne '' && index($half, '{n}') != -1) {
    $n = $half;
    $n =~ s/\{n\}/$base_n/;
  } else {
    $n = $base_n;
  }

  my $template;
  if (ref $unit_forms eq 'HASH') {
    my $cat = $locale->{plural}->($count);
    $template = $unit_forms->{$cat} // $unit_forms->{other};
  } else {
    $template = $unit_forms;
  }

  my $result = $template;
  $result =~ s/\{n\}/$n/;

  if ($half ne '' && index($half, '{0}') != -1) {
    my $wrapped = $half;
    $wrapped =~ s/\{0\}/$result/;
    $result = $wrapped;
  }

  return $result;
}

1;
