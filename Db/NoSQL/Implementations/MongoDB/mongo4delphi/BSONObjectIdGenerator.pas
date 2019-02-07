{***************************************************************************}
{                                                                           }
{                    Mongo Delphi Driver                                    }
{                                                                           }
{           Copyright (c) 2012 Fabricio Colombo                             }
{                                                                           }
{  Licensed under the Apache License, Version 2.0 (the "License");          }
{  you may not use this file except in compliance with the License.         }
{  You may obtain a copy of the License at                                  }
{                                                                           }
{      http://www.apache.org/licenses/LICENSE-2.0                           }
{                                                                           }
{  Unless required by applicable law or agreed to in writing, software      }
{  distributed under the License is distributed on an "AS IS" BASIS,        }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{  See the License for the specific language governing permissions and      }
{  limitations under the License.                                           }
{                                                                           }
{***************************************************************************}
unit BSONObjectIdGenerator;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

{$IFDEF MSWINDOWS}
uses Windows;
{$ELSE}
uses Unix, BaseUnix, LclIntf;
{$ENDIF}

type
  TBSONObjectIdGenerator = class
  public
    class function GenId: String;
  end;

implementation

uses Registry, SysUtils, DateUtils;

var
  _mongoObjectID_MachineID: Integer;
  _mongoObjectID_Counter: Integer;

{$ifndef MSWINDOWS}   ////////add by James ----->
function GetComputerNameByLinux: String;
var
  aUtsName: UtsName;
begin
  Result:='';
  aUtsName.Nodename[0]:=#0; // This is just for suppressing the compiler warning.
  FillChar(aUtsName,SizeOf(aUtsName),0);
  if FpUname(aUtsName)<>-1 then
  begin
    Result:=aUtsName.Nodename;
  end;
end;
{$endif}

procedure InitMongoObjectID;
const
  KEY_WOW64_64KEY = $0100;
var
  r:TRegistry;
  s:string;
  i,l:integer;
begin
  //render a number out of the host name
  r:=TRegistry.Create(KEY_READ or KEY_WOW64_64KEY);
  try
    r.RootKey:=HKEY_LOCAL_MACHINE;
    if r.OpenKey('\Software\Microsoft\Cryptography',false) then
      s:=r.ReadString('MachineGuid')
    else
      s:='';
  finally
    r.Free;
  end;
  if s='' then
   begin
    l:=MAX_PATH;
    SetLength(s,l);
    {$IFDEF MSWINDOWS}
      if GetComputerName(PChar(s),cardinal(l)) then
        SetLength(s,l)
      else
        s := GetEnvironmentVariable('COMPUTERNAME');
    {$ELSE}
       s := GetComputerNameByLinux();
    {$ENDIF}
    _mongoObjectID_MachineID:=$10101;
    for i:=1 to Length(s) do
      case s[i] of
        '0'..'9':
          _mongoObjectID_MachineID:=(_mongoObjectID_MachineID*36+(byte(s[i]) and $0F)) and $FFFFFF;
        'A'..'Z','a'..'z':
          _mongoObjectID_MachineID:=(_mongoObjectID_MachineID*36+(byte(s[i]) and $1F)+9) and $FFFFFF;
        //else ignore
      end;
   end
  else
    _mongoObjectID_MachineID:=StrToInt('$'+Copy(s,1,6));

  _mongoObjectID_Counter := GetTickCount;
end;

{ TBSONObjectIdGenerator }

class function TBSONObjectIdGenerator.GenId: String;
var
  a,b,c,d:integer;
const
  hex:array[0..15] of char='0123456789abcdef';
begin
  a:= DateTimeToUnix(Now);//(((Round(EncodeDate(st.wYear,st.wMonth,st.wDay))-UnixDateDelta)*24+st.wHour)*60+st.wMinute)*60+st.wSecond;
  b:= _mongoObjectID_MachineID;
  c:= GetCurrentThreadId;
  d:= InterlockedIncrement(_mongoObjectID_Counter);
  Result:=
    hex[(a shr 28) and $F]+hex[(a shr 24) and $F]+
    hex[(a shr 20) and $F]+hex[(a shr 16) and $F]+
    hex[(a shr 12) and $F]+hex[(a shr  8) and $F]+
    hex[(a shr  4) and $F]+hex[(a       ) and $F]+

    hex[(b shr 20) and $F]+hex[(b shr 16) and $F]+
    hex[(b shr 12) and $F]+hex[(b shr  8) and $F]+
    hex[(b shr  4) and $F]+hex[(b       ) and $F]+

    hex[(c shr 12) and $F]+hex[(c shr  8) and $F]+
    hex[(c shr  4) and $F]+hex[(c       ) and $F]+

    hex[(d shr 20) and $F]+hex[(d shr 16) and $F]+
    hex[(d shr 12) and $F]+hex[(d shr  8) and $F]+
    hex[(d shr  4) and $F]+hex[(d       ) and $F];
end;

initialization
  InitMongoObjectID;

end.
