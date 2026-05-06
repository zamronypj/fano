unit Logger;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

procedure log(const msg: string);
procedure logErr(const msg: string);

implementation


procedure log(const msg: string);
begin
    writeln(STDOUT, msg);
end;

procedure logErr(const msg: string);
begin
    writeln(STDERR, msg);
end;

end.

