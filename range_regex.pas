unit range_regex;

// https://github.com/m-matsubara/range-regex-pas

// coding=utf8

//  Split range to ranges that has its unique pattern.
//  Example for 12-345:
//
//  12- 19: 1[2-9]
//  20- 99: [2-9]\d
// 100-299: [1-2]\d{2}
// 300-339: 3[0-3]\d
// 340-345: 34[0-5]

interface

uses
  System.Classes
  , System.Generics.Collections
  ;

function bounded_regex_for_range(min_, max_: Integer): String;
function regex_for_range(min_, max_: Integer): String;
function split_to_patterns(min_, max_: Integer): TStrings;
function split_to_ranges(min_, max_: Integer): TList<Integer>;
function fill_by_nines(integer_, nines_count: Integer): Integer;
function fill_by_zeros(integer_, zeros_count: Integer): Integer;
function range_to_pattern(start, stop: Integer): String;


implementation

uses
  System.SysUtils
  ;


(*
def bounded_regex_for_range(min_, max_):
    return r'\b({})\b'.format(regex_for_range(min_, max_))
*)
function bounded_regex_for_range(min_, max_: Integer): String;
begin
  Result := Format('\b(%s)\b', [regex_for_range(min_, max_)]);
end;


function regex_for_range(min_, max_: Integer): String;
var
  min__: Integer;
  max__: Integer;
  negative_subpatterns: TStrings;
  positive_subpatterns: TStrings;
  negative_only_subpatterns: TStrings;
  positive_only_subpatterns: TStrings;
  subpatterns: TStrings;
  val: String;
begin
  negative_subpatterns := nil;
  positive_subpatterns := nil;
  negative_only_subpatterns := nil;
  positive_only_subpatterns := nil;
  try
    (*
    > regex_for_range(12, 345)
    '1[2-9]|[2-9]\d|[1-2]\d{2}|3[0-3]\d|34[0-5]'
    *)

    (*
    positive_subpatterns = []
    negative_subpatterns = []
    *)

    (*
    if min_ < 0:
      min__ = 1
      if max_ < 0:
        min__ = abs(max_)
      max__ = abs(min_)

      negative_subpatterns = split_to_patterns(min__, max__)
      min_ = 0
    *)
    if (min_ < 0) then
    begin
      min__ := 1;
      if (max_ < 0) then
        min__ := abs(max_);
      max__ := abs(min_);

      negative_subpatterns := split_to_patterns(min__, max__);
      min_ := 0;
    end
    else
      negative_subpatterns := TStringList.Create;

    (*
    if max_ >= 0:
      positive_subpatterns = split_to_patterns(min_, max_)
    *)
    if (max_ >= 0) then
      positive_subpatterns := split_to_patterns(min_, max_)
    else
      positive_subpatterns := TStringList.Create;


    //negative_only_subpatterns = ['-' + val for val in negative_subpatterns if val not in positive_subpatterns]
    negative_only_subpatterns := TStringList.Create;
    for val in negative_subpatterns do
    begin
      if (positive_subpatterns.IndexOf(val) < 0) then
        negative_only_subpatterns.Add('-' + val);
    end;

    //positive_only_subpatterns = [val for val in positive_subpatterns if val not in negative_subpatterns]
    positive_only_subpatterns := TStringList.Create;
    for val in positive_subpatterns do
    begin
      if (negative_subpatterns.IndexOf(val) < 0) then
        positive_only_subpatterns.Add(val);
    end;

    (*
    intersected_subpatterns = ['-?' + val for val in negative_subpatterns if val in positive_subpatterns]

    subpatterns = negative_only_subpatterns + intersected_subpatterns + positive_only_subpatterns
    *)
    subpatterns := TStringList.Create;

    subpatterns.AddStrings(negative_only_subpatterns);
    for val in negative_subpatterns do
    begin
      if (positive_subpatterns.IndexOf(val) >= 0) then
        subpatterns.Add('-?' + val);
    end;
    subpatterns.AddStrings(positive_only_subpatterns);

    //return '|'.join(subpatterns)
    subpatterns.Delimiter := '|';
    subpatterns.StrictDelimiter := True;
    Result := subpatterns.DelimitedText;
  finally
    FreeAndNil(negative_subpatterns);
    FreeAndNil(positive_subpatterns);
    FreeAndNil(negative_only_subpatterns);
    FreeAndNil(positive_only_subpatterns);
  end;
end;


function split_to_patterns(min_, max_: Integer): TStrings;
var
  subpatterns: TStrings;
  start: Integer;
  stop: Integer;
  ranges: TList<Integer>;
begin
  //subpatterns = []
  subpatterns := TStringList.Create;

  //start = min_
  start := min_;

  (*
  for stop in split_to_ranges(min_, max_):
      subpatterns.append(range_to_pattern(start, stop))
      start = stop + 1
  *)
  ranges := split_to_ranges(min_, max_);
  try
    for stop in ranges do
    begin
      subpatterns.Add(range_to_pattern(start, stop));
      start := stop + 1;
    end;
  finally
    FreeAndNil(ranges);
  end;

  //return subpatterns
  Result := subpatterns;
end;


function split_to_ranges(min_, max_: Integer): TList<Integer>;
var
  stops: TList<Integer>;
  nines_count: Integer;
  stop: Integer;
  zeros_count: Integer;
begin
  //stops = {max_}
  stops := TList<Integer>.Create;
  stops.Add(max_);

  //nines_count = 1
  nines_count := 1;

  //stop = fill_by_nines(min_, nines_count)
  stop := fill_by_nines(min_, nines_count);

  (*
  while min_ <= stop < max_:
      stops.add(stop)

      nines_count += 1
      stop = fill_by_nines(min_, nines_count)
  *)
  while (min_ <= stop) and (stop < max_) do
  begin
    if (stops.Contains(stop) = False) then
      stops.Add(stop);

    Inc(nines_count);
    stop := fill_by_nines(min_, nines_count);
  end;

  //zeros_count = 1
  zeros_count := 1;
  //stop = fill_by_zeros(max_ + 1, zeros_count) - 1
  stop := fill_by_zeros(max_ + 1, zeros_count) - 1;
  (*
  while min_ < stop <= max_:
      stops.add(stop)

      zeros_count += 1
      stop = fill_by_zeros(max_ + 1, zeros_count) - 1
  *)
  while (min_ < stop) and (stop <= max_) do
  begin
    if (stops.Contains(stop) = False) then
      stops.add(stop);

    Inc(zeros_count);
    stop := fill_by_zeros(max_ + 1, zeros_count) - 1;
  end;

  //stops = list(stops)
  //stops.sort()
  stops.Sort;

  //return stops
  Result := stops;
end;

function fill_by_nines(integer_, nines_count: Integer): Integer;
var
  str: String;
begin
  //return int(str(integer_)[:-nines_count] + '9' * nines_count)
  str := IntToStr(integer_);
  Result := StrToInt(
    Copy(str, 1, Length(str) - nines_count)
     + Copy('9999999999999999999', 1, nines_count)
    );
end;


function fill_by_zeros(integer_, zeros_count: Integer): Integer;
var
  idx: Integer;
  pow: Integer;
begin
  //return integer - integer % 10 ** zeros_count
  pow := 1;
  for idx := 1 to zeros_count do
    pow := pow * 10;
  result := integer_ - integer_ mod pow;
end;


function range_to_pattern(start, stop: Integer): String;
var
  pattern: String;
  any_digit_count: Integer;
  start_digit: Char;
  stop_digit: Char;

  str_start: String;
  str_stop: String;
  idx: Integer;
  str_start_len: Integer;
  str_stop_len: Integer;
  len: Integer;
begin
  //pattern = ''
  //any_digit_count = 0
  pattern := '';
  any_digit_count := 0;

  (*
  for start_digit, stop_digit in zip(str(start), str(stop)):
    if start_digit == stop_digit:
      pattern += start_digit
    elif start_digit != '0' or stop_digit != '9':
      pattern += '[{}-{}]'.format(start_digit, stop_digit)
    else:
      any_digit_count += 1
  *)
  str_start := IntToStr(start);
  str_stop := IntToStr(stop);
  str_start_len := Length(str_start);
  str_stop_len  := Length(str_stop);
  if (str_start_len < str_stop_len) then
    len := str_start_len
  else
    len := str_stop_len;
  for idx := 1 to len do
  begin
    start_digit := str_start[idx];
    stop_digit := str_stop[idx];
    if (start_digit = stop_digit) then
      pattern := pattern + start_digit
    else if (start_digit <> '0') or (stop_digit <> '9') then
      pattern := pattern + Format('[%s-%s]', [start_digit, stop_digit])
    else
      Inc(any_digit_count);
  end;

  (*
  if any_digit_count:
    pattern += r'\d'
  *)
  if (any_digit_count > 0) then
    pattern := pattern + '\d';

  (*
  if any_digit_count > 1:
    pattern += '{{{}}}'.format(any_digit_count)
  *)
  if (any_digit_count > 1) then
    pattern := pattern + Format('{%d}', [any_digit_count]);

  //return pattern
  Result := pattern;
end;

end.
