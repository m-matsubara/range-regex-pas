unit range_regex_test;

interface

uses
  DUnitX.TestFramework
  , System.RegularExpressions;

type
  [TestFixture]
  TMyTestObject = class
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    procedure _verify_range(RegExStr: String; min, max, from_min, to_max: Int64);

    [Test]
    procedure TestQuality;
    [Test]
    procedure TestOptimization;
    [Test]
    procedure TestEqual;
    [Test]
    procedure TestEqual_2;
    [Test]
    procedure TestEqual_3;
    [Test]
    procedure test_repeated_digit;
    [Test]
    procedure test_repeated_zeros;
    [Test]
    procedure test_zero_one;
    [Test]
    procedure test_different_len_numbers_1;
    [Test]
    procedure test_repetead_one;
    [Test]
    procedure test_small_diff_1;
    [Test]
    procedure test_small_diff_2;
    [Test]
    procedure test_random_range_1;
    [Test]
    procedure test_one_digit_numbers;
    [Test]
    procedure test_one_digit_at_bounds;
    [Test]
    procedure test_power_of_ten;
    [Test]
    procedure test_different_len_numbers_2;
    [Test]
    procedure test_different_len_numbers_small_diff;
    [Test]
    procedure test_different_len_zero_eight_nine;
    [Test]
    procedure test_small_diff;
    [Test]
    procedure test_different_len_zero_one_nine;

  end;

implementation

uses
  range_regex
  , System.SysUtils;

procedure TMyTestObject.Setup;
begin
end;

procedure TMyTestObject.TearDown;
begin
end;

procedure TMyTestObject._verify_range(RegExStr: String; min, max, from_min, to_max: Int64);
var
  idx: Int64;
  RegEx: TRegEx;
begin
  RegEx := TRegEx.Create(RegExStr, []);
  for idx := from_min to to_max do
  begin
    if (min <= idx) and (idx <= max) then
      Assert.IsTrue(RegEx.IsMatch(IntToStr(idx)), 'Failure: ''' + RegExStr + ''' (expect true) : ' + IntToStr(idx))
    else
      Assert.IsFalse(RegEx.IsMatch(IntToStr(idx)), 'Failure: ''' + RegExStr + ''' (expect false) : ' + IntToStr(idx));
  end;
end;


procedure TMyTestObject.TestQuality;
begin
  Assert.AreEqual(regex_for_range(1, 1), '1', 'regex_for_range(1, 1)');
  Assert.AreEqual(regex_for_range(0, 1), '[0-1]', 'regex_for_range(0, 1)');
  Assert.AreEqual(regex_for_range(-1, -1), '-1', 'regex_for_range(-1, -1');
  Assert.AreEqual(regex_for_range(-1, 0), '-1|0', 'regex_for_range(-1, 0)');
  Assert.AreEqual(regex_for_range(-1, 1), '-1|[0-1]', 'regex_for_range(-1, 1)');
  Assert.AreEqual(regex_for_range(-4, -2), '-[2-4]', 'regex_for_range(-4, -2');
  Assert.AreEqual(regex_for_range(-3, 1), '-[1-3]|[0-1]', 'regex_for_range(-3, 1)');
  Assert.AreEqual(regex_for_range(-2, 0), '-[1-2]|0', 'regex_for_range(-2, 0)');
  Assert.AreEqual(regex_for_range(0, 2), '[0-2]', 'regex_for_range(0, 2)');
  Assert.AreEqual(regex_for_range(-1, 3), '-1|[0-3]', 'regex_for_range(-1, 3)');
  Assert.AreEqual(regex_for_range(65666, 65667), '6566[6-7]', 'regex_for_range(65666, 65667)');
  Assert.AreEqual(regex_for_range(12, 3456), '1[2-9]|[2-9]\d|[1-9]\d{2}|[1-2]\d{3}|3[0-3]\d{2}|34[0-4]\d|345[0-6]', 'regex_for_range(12, 3456)');
  Assert.AreEqual(regex_for_range(1, 19), '[1-9]|1\d', 'regex_for_range(1, 19)');
  Assert.AreEqual(regex_for_range(1, 99), '[1-9]|[1-9]\d', 'regex_for_range(1, 99)');
end;

procedure TMyTestObject.TestOptimization;
begin
  Assert.AreEqual(regex_for_range(-9, 9), '-[1-9]|\d', 'regex_for_range(-9, 9)');
  Assert.AreEqual(regex_for_range(-19, 19), '-[1-9]|-?1\d|\d', 'regex_for_range(-19, 19)');
  Assert.AreEqual(regex_for_range(-29, 29), '-[1-9]|-?[1-2]\d|\d', 'regex_for_range(-29, 29)');
  Assert.AreEqual(regex_for_range(-99, 99), '-[1-9]|-?[1-9]\d|\d', 'regex_for_range(-99, 99)');
  Assert.AreEqual(regex_for_range(-999, 999), '-[1-9]|-?[1-9]\d|-?[1-9]\d{2}|\d', 'regex_for_range(-999, 999)');
  Assert.AreEqual(regex_for_range(-9999, 9999), '-[1-9]|-?[1-9]\d|-?[1-9]\d{2}|-?[1-9]\d{3}|\d', 'regex_for_range(-9999, 9999)');
end;

procedure TMyTestObject.TestEqual;
var
  regex: String;
begin
  regex := bounded_regex_for_range(1, 1);
  self._verify_range(regex, 1, 1, 0, 100);
end;

procedure TMyTestObject.TestEqual_2;
var
  regex: String;
begin
  regex := bounded_regex_for_range(65443, 65443);
  self._verify_range(regex, 65443, 65443, 65000, 66000);
end;

procedure TMyTestObject.TestEqual_3;
var
  regex: String;
begin
  regex := bounded_regex_for_range(192, 100020000300000);
  self._verify_range(regex, 192, 1000, 0, 1000);
  self._verify_range(regex, Int64(100019999300000), Int64(100020000300000), Int64(100019999300000), Int64(100020000400000));
end;

procedure TMyTestObject.test_repeated_digit;
var
  regex: String;
begin
  regex := bounded_regex_for_range(10331, 20381);
  self._verify_range(regex, 10331, 20381, 0, 99999);
end;

procedure TMyTestObject.test_repeated_zeros;
var
  regex: String;
begin
  regex := bounded_regex_for_range(10031, 20081);
  self._verify_range(regex, 10031, 20081, 0, 99999);
end;

procedure TMyTestObject.test_zero_one;
var
  regex: String;
begin
  regex := bounded_regex_for_range(10301, 20101);
  self._verify_range(regex, 10301, 20101, 0, 99999);
end;

procedure TMyTestObject.test_different_len_numbers_1;
var
  regex: String;
begin
  regex := bounded_regex_for_range(1030, 20101);
  self._verify_range(regex, 1030, 20101, 0, 99999);
end;

procedure TMyTestObject.test_repetead_one;
var
  regex: String;
begin
  regex := bounded_regex_for_range(102, 111);
  self._verify_range(regex, 102, 111, 0, 1000);
end;

procedure TMyTestObject.test_small_diff_1;
var
  regex: String;
begin
  regex := bounded_regex_for_range(102, 110);
  self._verify_range(regex, 102, 110, 0, 1000);
end;

procedure TMyTestObject.test_small_diff_2;
var
  regex: String;
begin
  regex := bounded_regex_for_range(102, 130);
  self._verify_range(regex, 102, 130, 0, 1000);
end;

procedure TMyTestObject.test_random_range_1;
var
  regex: String;
begin
  regex := bounded_regex_for_range(4173, 7981);
  self._verify_range(regex, 4173, 7981, 0, 99999);
end;

procedure TMyTestObject.test_one_digit_numbers;
var
  regex: String;
begin
  regex := bounded_regex_for_range(3, 7);
  self._verify_range(regex, 3, 7, 0, 99);
end;

procedure TMyTestObject.test_one_digit_at_bounds;
var
  regex: String;
begin
  regex := bounded_regex_for_range(1, 9);
  self._verify_range(regex, 1, 9, 0, 1000);
end;

procedure TMyTestObject.test_power_of_ten;
var
  regex: String;
begin
  regex := bounded_regex_for_range(1000, 8632);
  self._verify_range(regex, 1000, 8632, 0, 99999);
end;

procedure TMyTestObject.test_different_len_numbers_2;
var
  regex: String;
begin
  regex := bounded_regex_for_range(13, 8632);
  self._verify_range(regex, 13, 8632, 0, 10000);
end;

procedure TMyTestObject.test_different_len_numbers_small_diff;
var
  regex: String;
begin
  regex := bounded_regex_for_range(9, 11);
  self._verify_range(regex, 9, 11, 0, 100);
end;

procedure TMyTestObject.test_different_len_zero_eight_nine;
var
  regex: String;
begin
  regex := bounded_regex_for_range(90, 980099);
  self._verify_range(regex, 90, 980099, 0, 999999);
end;

procedure TMyTestObject.test_small_diff;
var
  regex: String;
begin
  regex := bounded_regex_for_range(19, 21);
  self._verify_range(regex, 19, 21, 0, 100);
end;

procedure TMyTestObject.test_different_len_zero_one_nine;
var
  regex: String;
begin
  regex := bounded_regex_for_range(999, 10000);
  self._verify_range(regex, 999, 10000, 1, 20000);
end;


initialization
  TDUnitX.RegisterTestFixture(TMyTestObject);

end.
