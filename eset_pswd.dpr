program eset_pswd;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  windows,
  math,
  algo in 'algo.pas';

const
  defaultcharset='abcdefghijklmnopqrstuvwxyz0123456789_-';


// Reads the password hash from registry.
function ReadHash(var hash:Cardinal):Boolean;
var
  subkey:HKEY;
  i:Integer;
  len:Cardinal;
begin
  Result := False;

  i := RegOpenKeyEx(HKEY_LOCAL_MACHINE, 'SOFTWARE\ESET\ESET Security\CurrentVersion\Plugins\01000600\settings\EKRN_CFG', 0, KEY_READ, subkey);
  // On 64-Bit Windows we are affected by the registry redirection, so we need to handle this case
  if (i = ERROR_FILE_NOT_FOUND) then begin
    i := RegOpenKeyEx(HKEY_LOCAL_MACHINE, 'SOFTWARE\ESET\ESET Security\CurrentVersion\Plugins\01000600\settings\EKRN_CFG', 0, KEY_READ OR KEY_WOW64_64KEY, subkey);
  end;
  if (i <> ERROR_SUCCESS) then Exit;

  len := 4;
  i := RegQueryValueEx(subkey, 'LockPassword', nil, nil, @hash, @len);
  if (i <> ERROR_SUCCESS) then Exit;

  RegCloseKey(subkey);

  Result := True;
end;


// Quick'n'dirty bruteforce function. Not the best, but works for poc or simple passwords
function BruteForce(hash:Cardinal; charset:String; pwlen:Integer):Boolean;
var
  I, x, max:Int64;
  current_pw:WideString;
  len, y:Integer;
begin
  Result := False;

  max := Round(Power(Length(charset), pwlen));
  I := 0;
  while (I <= max) do begin
    x := I;
    current_pw := '';
    len := Length(charset);
    while (x > len) do begin
      y := x mod len;
      if (y = 0) then y := len;

      current_pw := current_pw + charset[y];
      x := Trunc(x / len);
    end;
    current_pw := current_pw + charset[x];

    if (I mod 100000 = 0) then WriteLn(current_pw);

    if (CalcHash(current_pw) = hash) then begin
      WriteLn(#13#10'Password found!');
      WriteLn(current_pw);
      Result := True;
      Exit;
    end;

    I := I+1;
  end;
end;


procedure Main;
var
  hash:Cardinal;
  line, charset, s:String;
  len:Integer;
begin
  WriteLn('gordon--''s ESET Password Recovery 0.2                         github.com/LFriede'#13#10);

  // Check if help should be displayed
  if (FindCmdLineSwitch('?')) then begin
    WriteLn('Optional command line arguments:');

    WriteLn('-h [hash]');
    WriteLn('  If obtained this hash will be used and this tool will not search the registry for it.');

    WriteLn(#13#10'-c [charset]');
    WriteLn('  Obtain your own charset to the bruteforce routine. Default: '+defaultcharset);

    WriteLn(#13#10'-l [length]');
    WriteLn('  Define the maximal password length for the bruteforce routine. Default: 5');

    WriteLn(#13#10'-?');
    WriteLn('  Displays this help text.');
    Exit;
  end;

  // Check if hash was obtained via argument, if not read it from the registry
  hash := 0;
  if (FindCmdLineSwitch('h', s, False, [clstValueNextParam])) then begin
    try
      hash := StrToInt('$'+s);
    finally
    end;
  end;
  if (hash = 0) then begin
    if (ReadHash(hash) = False) then begin
      WriteLn('Can''t read hash from registry.');
      Exit;
    end;
  end;
  WriteLn('Password hash: '+IntToHex(hash, 8));

  // Get charset from args or use default.
  if (FindCmdLineSwitch('c', charset, False, [clstValueNextParam]) = False) then begin
    charset := defaultcharset;
  end;
  WriteLn('Charset: '+charset);

  // Get bruteforce pw length from args or use default.
  len := 5;
  if (FindCmdLineSwitch('l', s, False, [clstValueNextParam])) then begin
    try
      len := StrToInt(s);
    finally
    end;
  end;
  WriteLn('Bruteforce password length: '+IntToStr(len));

  // Do the magic
  WriteLn(#13#10'Start bruteforce attack? (Y/n)');
  ReadLn(line);
  if ((Length(line) > 0) AND (LowerCase(line) <> 'y')) then exit;

  WriteLn('M''kay!'#13#10);

  if (BruteForce(hash, charset, len) = False) then begin
    WriteLn('Sorry, nothing found!');
    WriteLn('Try another length or another characterset.');
  end;
end;


begin
  Main;
end.
