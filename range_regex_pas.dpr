program range_regex_pas;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  range_regex in 'range_regex.pas';

var
  num1: Int64;
  num2: Int64;
begin
  try
    num1 := StrToInt(ParamStr(1));
    num2 := StrToInt(ParamStr(2));
    writeln(regex_for_range(num1, num2));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
