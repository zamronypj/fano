{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit clamav3;

{*--------------------------------------------------
 * ClamAV header translation
 *
 * @author reyjieroque https://github.com/reyjieroque
 * @author GuvaCode https://github.com/GuvaCode
 * @credit https://github.com/reyjieroque/delphi-clamav
 *----------------------------------------------------*}

{$IFDEF Fpc}
  {$MODE Delphi}
{$ENDIF}

interface

const
 {$IFDEF Linux}
  External_library='libclamav.so.9'; {Setup as you need}
 {$ELSE}
  External_library = 'libclamav.dll'; {Setup as you need}
 {$ENDIF}

type
  DWord = Word;
  uint32_t = LongWord;
  uint64_t = Cardinal;
  PLongint = ^Longint;
  PSmallInt = ^SmallInt;
  PByte = ^Byte;
  PWord = ^Word;
  PDWord = ^DWord;
  PDouble = ^Double;
  cint = Integer;
  Pcli_ftype = Pointer;
  Pcli_ignored = Pointer;
  Pcli_matcher = Pointer;
  Pcli_meta_node = Pointer;
  Pmpool_t = Pointer;
  Pphishcheck = Pointer;
  Pregex_matcher = Pointer;
  PStat = Pointer;

const
  CL_COUNT_PRECISION = 4096;

type
  Pcl_error_t = ^cl_error_t;
  cl_error_t = Longint;
const
  {libclamav specific}
  CL_CLEAN = 0;
  CL_SUCCESS = 0;
  CL_VIRUS = 1;
  CL_ENULLARG = 2;
  CL_EARG = 3;
  CL_EMALFDB = 4;
  CL_ECVD = 5;
  CL_EVERIFY = 6;
  CL_EUNPACK = 7;
  {I/O and memory errors}
  CL_EOPEN = 8;
  CL_ECREAT = 9;
  CL_EUNLINK = 10;
  CL_ESTAT = 11;
  CL_EREAD = 12;
  CL_ESEEK = 13;
  CL_EWRITE = 14;
  CL_EDUP = 15;
  CL_EACCES = 16;
  CL_ETMPFILE = 17;
  CL_ETMPDIR = 18;
  CL_EMAP = 19;
  CL_EMEM = 20;
  CL_ETIMEOUT = 21;
  {internal (not reported outside libclamav)}
  CL_BREAK = 22;
  CL_EMAXREC = 23;
  CL_EMAXSIZE = 24;
  CL_EMAXFILES = 25;
  CL_EFORMAT = 26;
  CL_EPARSE = 27;
  CL_EBYTECODE = 28;
  CL_EBYTECODE_TESTFAIL = 29;
  {c4w error codes}
  CL_ELOCK = 30;
  CL_EBUSY = 31;
  CL_ESTATE = 32;
  {no error codes below this line please}
  CL_ELAST_ERROR = 33;
  {db options}
  CL_DB_PHISHING = $2;
  CL_DB_PHISHING_URLS = $8;
  CL_DB_PUA = $10;
  CL_DB_CVDNOTMP = $20;
  CL_DB_OFFICIAL = $40;
  CL_DB_PUA_MODE = $80;
  CL_DB_PUA_INCLUDE = $100;
  CL_DB_PUA_EXCLUDE = $200;
  CL_DB_COMPILED = $400;
  CL_DB_DIRECTORY = $800;
  CL_DB_OFFICIAL_ONLY = $1000;
  CL_DB_BYTECODE = $2000;
  CL_DB_SIGNED = $4000;
  CL_DB_BYTECODE_UNSIGNED = $8000;
  CL_DB_UNSIGNED = $10000;
  CL_DB_BYTECODE_STATS = $20000;
  CL_DB_ENHANCED = $40000;
  CL_DB_PCRE_STATS =$80000;
  CL_DB_YARA_EXCLUDE = $100000;
  CL_DB_YARA_ONLY = $200000;
  {recommended db settings}
  CL_DB_STDOPT = (CL_DB_PHISHING or CL_DB_PHISHING_URLS or CL_DB_BYTECODE);
  {scan options}
  CL_SCAN_RAW = $0;
  CL_SCAN_ARCHIVE = $1;
  CL_SCAN_MAIL = $2;
  CL_SCAN_OLE2 = $4;
  CL_SCAN_BLOCKENCRYPTED = $8;
  CL_SCAN_HTML = $10;
  CL_SCAN_PE = $20;
  CL_SCAN_BLOCKBROKEN = $40;
  CL_SCAN_MAILURL = $80;
  CL_SCAN_BLOCKMAX = $100;
  CL_SCAN_ALGORITHMIC = $200;
  CL_SCAN_PHISHING_BLOCKSSL = $800;
  CL_SCAN_PHISHING_BLOCKCLOAK = $1000;
  CL_SCAN_ELF = $2000;
  CL_SCAN_PDF = $4000;
  CL_SCAN_STRUCTURED = $8000;
  CL_SCAN_STRUCTURED_SSN_NORMAL = $10000;
  CL_SCAN_STRUCTURED_SSN_STRIPPED = $20000;
  CL_SCAN_PARTIAL_MESSAGE = $40000;
  CL_SCAN_HEURISTIC_PRECEDENCE = $80000;
  CL_SCAN_BLOCKMACROS = $100000;
  CL_SCAN_ALLMATCHES = $200000;
  CL_SCAN_SWF = $400000;
  CL_SCAN_PARTITION_INTXN = $800000;
  CL_SCAN_FILE_PROPERTIES = $10000000;
  // UNUSED =  0x20000000;
  CL_SCAN_PERFORMANCE_INFO = $40000000;
  CL_SCAN_INTERNAL_COLLECT_SHA = $80000000;
  {recommended scan settings}
   // problems with scan options ? you can switch from the previous settings (CL_SCAN_STDOPT)
  //CL_SCAN_STDOPT = ((((((CL_SCAN_ARCHIVE or CL_SCAN_MAIL) or CL_SCAN_OLE2) or CL_SCAN_PDF) or CL_SCAN_HTML) or CL_SCAN_PE) or CL_SCAN_ALGORITHMIC) or CL_SCAN_ELF;
  CL_SCAN_STDOPT = ((((((CL_SCAN_ARCHIVE or CL_SCAN_MAIL) or CL_SCAN_OLE2) or CL_SCAN_PDF) or CL_SCAN_HTML) or CL_SCAN_PE) or CL_SCAN_ALGORITHMIC) or CL_SCAN_ELF or CL_SCAN_SWF;
  {cl_countsigs options}
  CL_COUNTSIGS_OFFICIAL = $1;
  CL_COUNTSIGS_UNOFFICIAL = $2;
  CL_COUNTSIGS_ALL = CL_COUNTSIGS_OFFICIAL or CL_COUNTSIGS_UNOFFICIAL;

  {  ??????????????
/* For the new engine_options bit field in the engine
  #define ENGINE_OPTIONS_NONE             0x0
 #define ENGINE_OPTIONS_DISABLE_CACHE    0x1
 #define ENGINE_OPTIONS_FORCE_TO_DISK    0x2
 #define ENGINE_OPTIONS_DISABLE_PE_STATS 0x4
     ??????????????                 }


type
  cli_dconf = record
    pe: uint32_t;
    elf: uint32_t;
    archive: uint32_t;
    doc: uint32_t;
    mail: uint32_t;
    other: uint32_t;
    phishing: uint32_t;
  end;

  Pcli_dconf = ^cli_dconf;
  Pcl_engine = ^cl_engine;

  icomtr = record
    group: array[0..1] of uint32_t;
    color_avg: array[0..2] of uint32_t;
    color_x: array[0..2] of uint32_t;
    color_y: array[0..2] of uint32_t;
    gray_avg: array[0..2] of uint32_t;
    gray_x: array[0..2] of uint32_t;
    gray_y: array[0..2] of uint32_t;
    bright_avg: array[0..2] of uint32_t;
    bright_x: array[0..2] of uint32_t;
    bright_y: array[0..2] of uint32_t;
    dark_avg: array[0..2] of uint32_t;
    dark_x: array[0..2] of uint32_t;
    dark_y: array[0..2] of uint32_t;
    edge_avg: array[0..2] of uint32_t;
    edge_x: array[0..2] of uint32_t;
    edge_y: array[0..2] of uint32_t;
    noedge_avg: array[0..2] of uint32_t;
    noedge_x: array[0..2] of uint32_t;
    noedge_y: array[0..2] of uint32_t;
    rsum: uint32_t;
    gsum: uint32_t;
    bsum: uint32_t;
    ccount: uint32_t;
    name: PChar;
  end;

  picon_matcher = ^icon_matcher;
  icon_matcher = record
    group_names: array[0..1] of char;
    group_counts: array[0..1] of uint32_t;
    icons: array[0..2] of icomtr;
    icon_counts: array[0..2] of uint32_t;
  end;

  pcli_dbinfo = ^cli_dbinfo;
  cli_dbinfo = record
    name: Pchar;
    hash: Pchar;
    size: integer;
    cvd: Pointer;
    next: Pointer;
  end;

  clcb_pre_scan = function(fd: longint; var context: pointer): cl_error_t; cdecl;
  clcb_post_scan = function(fd: longint; result: longint; virname: Pchar; var context: pointer): cl_error_t; cdecl;
  clcb_sigload = function(_type: Pchar; name: Pchar; var context: pointer): longint; cdecl;

  cl_engine = record
    refcount: uint32_t;
    sdb: uint32_t;
    dboptions: uint32_t;
    dbversion: array[0..1] of uint32_t;
    ac_only: uint32_t;
    ac_mindepth: uint32_t;
    ac_maxdepth: uint32_t;
    tmpdir: PChar;
    keeptmp: uint32_t;
    maxscansize: uint64_t;
    maxfilesize: uint64_t;
    maxreclevel: uint32_t;
    maxfiles: uint32_t;
    min_cc_count: uint32_t;
    min_ssn_count: uint32_t;
    root: Pcli_matcher;
    hm_hdb: Pcli_matcher;
    hm_mdb: Pcli_matcher;
    hm_fp: Pcli_matcher;
    cdb: Pointer;
    whitelist_matcher: Pregex_matcher;
    domainlist_matcher: Pregex_matcher;
    phishcheck: Pphishcheck;
    dconf: Pcli_dconf;
    ftypes: Pcli_ftype;
    ignored: Pcli_ignored;
    pua_cats: PChar;
    iconcheck: picon_matcher;
    cache: Pointer;
    db_info: pcli_dbinfo;
    clcb_pre_scan: clcb_pre_scan;
    clcb_post_scan: clcb_post_scan;
    clcb_sigload: clcb_sigload;
    cb_sigload_ctx: Pointer;
    mempool: Pmpool_t;
    callback: function(desc: cint; bytes: cint): cint; cdecl;
  end;

  Pcl_settings = ^cl_settings;
  cl_settings = record
    ac_only: uint32_t;
    ac_mindepth: uint32_t;
    ac_maxdepth: uint32_t;
    tmpdir: pchar;
    keeptmp: uint32_t;
    maxscansize: uint64_t;
    maxfilesize: uint64_t;
    maxreclevel: uint32_t;
    maxfiles: uint32_t;
    min_cc_count: uint32_t;
    min_ssn_count: uint32_t;
    pua_cats: pchar;
    // undefined structure //
  end;

const
  CL_INIT_DEFAULT = $0;

var
  cl_init: function(initoptions: dword): longint; cdecl;
  cl_engine_new: function: Pcl_engine; cdecl;

type
  cl_engine_field = Longint;

const
  CL_ENGINE_MAX_SCANSIZE = 0;
  CL_ENGINE_MAX_FILESIZE = 1;
  CL_ENGINE_MAX_RECURSION = 2;
  CL_ENGINE_MAX_FILES = 3;
  CL_ENGINE_MIN_CC_COUNT = 4;
  CL_ENGINE_MIN_SSN_COUNT = 5;
  CL_ENGINE_PUA_CATEGORIES = 6;
  CL_ENGINE_DB_OPTIONS = 7;
  CL_ENGINE_DB_VERSION = 8;
  CL_ENGINE_DB_TIME = 9;
  CL_ENGINE_AC_ONLY = 10;
  CL_ENGINE_AC_MINDEPTH = 11;
  CL_ENGINE_AC_MAXDEPTH = 12;
  CL_ENGINE_TMPDIR = 13;
  CL_ENGINE_KEEPTMP = 14;
  CL_ENGINE_BYTECODE_SECURITY = 15;
  CL_ENGINE_BYTECODE_TIMEOUT = 16;
  CL_ENGINE_BYTECODE_MODE = 17;

type
  bytecode_security = Longint;

const
  CL_BYTECODE_TRUST_ALL = 0;
  CL_BYTECODE_TRUST_SIGNED = 1;
  CL_BYTECODE_TRUST_NOTHING = 2;

type
  bytecode_mode = Longint;

const
  CL_BYTECODE_MODE_AUTO = 0;
  CL_BYTECODE_MODE_JIT = 1;
  CL_BYTECODE_MODE_INTERPRETER = 2;
  CL_BYTECODE_MODE_TEST = 3;
  CL_BYTECODE_MODE_OFF = 4;

var
  cl_engine_set_num: function(var engine: cl_engine; field: cl_engine_field; num: int64): longint; cdecl;
  cl_engine_get_num: function(var engine: cl_engine; field: cl_engine_field; var err: longint): int64; cdecl;
  cl_engine_set_str: function(var engine: cl_engine; field: cl_engine_field; str: Pchar): longint; cdecl;
  cl_engine_get_str: function(var engine: cl_engine; field: cl_engine_field; var err: longint): Pchar; cdecl;
  cl_engine_settings_copy: function(var engine: cl_engine): Pcl_settings; cdecl;
  cl_engine_settings_apply: function(var engine: cl_engine; var settings: cl_settings): longint; cdecl;
  cl_engine_settings_free: function(var settings: cl_settings): longint; cdecl;
  cl_engine_compile: function(var engine: cl_engine): longint; cdecl;
  cl_engine_addref: function(var engine: cl_engine): longint; cdecl;
  cl_engine_free: function(var engine: cl_engine): longint; cdecl;
  cl_engine_set_clcb_pre_scan: procedure(var engine: cl_engine; callback: clcb_pre_scan); cdecl;
  cl_engine_set_clcb_post_scan: procedure(var engine: cl_engine; callback: clcb_post_scan); cdecl;
  cl_engine_set_clcb_sigload: procedure(var engine: cl_engine; callback: clcb_sigload; var context: pointer); cdecl;

type
  cl_msg = Longint;
const
  CL_MSG_INFO_VERBOSE = 32;
  CL_MSG_WARN = 64;
  CL_MSG_ERROR = 128;

type
  clcb_msg = procedure(severity: cl_msg; fullmsg: Pchar; msg: Pchar; var context: pointer); cdecl;

var
  cl_set_clcb_msg: procedure(callback: clcb_msg); cdecl;

type
  clcb_hash = procedure(fd: longint; size: word; var md5: byte; virname: Pchar; var context: pointer); cdecl;

var
  cl_engine_set_clcb_hash: procedure(var engine: cl_engine; callback: clcb_hash); cdecl;

type
  Pcl_stat = ^cl_stat;
  cl_stat = record
    dir: Pchar;
    stattab: Pstat;
    statdname: ^Pchar;
    entries: dword;
  end;

  Pcl_cvd = ^cl_cvd;
  cl_cvd = record
    time: Pchar;
    version: dword;
    sigs: dword;
    fl: dword;
    md5: Pchar;
    dsig: Pchar;
    builder: Pchar;
    stime: dword;
  end;

type
  Pbytecode_mode = ^bytecode_mode;
  Pbytecode_security = ^bytecode_security;
  Pchar = ^char;
  Pcl_engine_field = ^cl_engine_field;
  Pcl_msg = ^cl_msg;

var
  cl_scandesc: function(desc: longint; virname: PPchar; var scanned: dword; var engine: cl_engine; scanoptions: dword): longint; cdecl;
  cl_scandesc_callback: function(desc: longint; virname: PPchar; var scanned: dword; var engine: cl_engine; scanoptions: dword; var context: pointer): longint; cdecl;
  cl_scanfile: function(filename: Pchar; virname: PPchar; var scanned: dword; var engine: cl_engine; scanoptions: dword): longint; cdecl;
  cl_scanfile_callback: function(filename: Pchar; virname: PPchar; var scanned: dword; var engine: cl_engine; scanoptions: dword; var context: pointer): longint; cdecl;
  cl_load: function(path: Pchar; var engine: cl_engine; var signo: longint; dboptions: dword): longint; cdecl;
  cl_retdbdir: function: Pchar; cdecl;
  cl_cvdhead: function(cfile: Pchar): Pcl_cvd; cdecl;
  cl_cvdparse: function(head: Pchar): Pcl_cvd; cdecl;
  cl_cvdverify: function(cfile: Pchar): longint; cdecl;
  cl_cvdfree: procedure(var cvd: cl_cvd); cdecl;
  cl_statinidir: function(dirname: Pchar; var dbstat: cl_stat): longint; cdecl;
  cl_statchkdir: function(var dbstat: cl_stat): longint; cdecl;
  cl_statfree: function(var dbstat: cl_stat): longint; cdecl;
  cl_countsigs: function(path: Pchar; countoptions: dword; var sigs: dword): {longint} int64; cdecl;
  cl_debug: procedure; cdecl;
  cl_retflevel: function: dword; cdecl;
  cl_retver: function: Pchar; cdecl;
  cl_strerror: function(clerror: longint): Pchar; cdecl;

var
  IsLibraryLoaded : Boolean;
  // change the record type cl_engine to unknown pointer since
  // a call to cl_engine_compile returns a pointer to pcl_engine which points to cl_engine
  // in this case the previously defined Engine : cl_engine expects a record type
  // during initialization. (already declared public), in my previous example,
  // Engine : cl_engine is declared private as it expects to be used after the engine
  // is initialized and cl_engine_compile is assigned.
  Engine          : Pointer;

function IsClamAVLibPresent: Boolean;

implementation

uses
{$IFDEF Windows} Windows, {$ENDIF}
{$IFDEF LINUX}Process, {$ENDIF}
{$IFDEF Fpc} Dynlibs,{$ENDIF}
SysUtils, Classes;

var
  hlib: HMODULE = 0;


procedure Freeclamav;
begin
  if (hlib<>0) then
  FreeLibrary(hlib);
  cl_init := nil;
  cl_engine_new := nil;
  cl_engine_set_num := nil;
  cl_engine_get_num := nil;
  cl_engine_set_str := nil;
  cl_engine_get_str := nil;
  cl_engine_settings_copy := nil;
  cl_engine_settings_apply := nil;
  cl_engine_settings_free := nil;
  cl_engine_compile := nil;
  cl_engine_addref := nil;
  cl_engine_free := nil;
  cl_engine_set_clcb_pre_scan := nil;
  cl_engine_set_clcb_post_scan := nil;
  cl_engine_set_clcb_sigload := nil;
  cl_set_clcb_msg := nil;
  cl_engine_set_clcb_hash := nil;
  cl_scandesc := nil;
  cl_scandesc_callback := nil;
  cl_scanfile := nil;
  cl_scanfile_callback := nil;
  cl_load := nil;
  cl_retdbdir := nil;
  cl_cvdhead := nil;
  cl_cvdparse := nil;
  cl_cvdverify := nil;
  cl_cvdfree := nil;
  cl_statinidir := nil;
  cl_statchkdir := nil;
  cl_statfree := nil;
  cl_countsigs := nil;
  cl_debug := nil;
  cl_retflevel := nil;
  cl_retver := nil;
  cl_strerror := nil;
end;
var
  ClamAVVarArray: array of ^Pointer;

procedure PushProc(procvar: Pointer);
var
  L: Integer;
begin
  L := Length(ClamAVVarArray);
  SetLength(ClamAVVarArray, L + 1);
  ClamAVVarArray[L] := procvar;
end;

procedure Loadclamav(lib: PAnsiChar);
  procedure assign_proc(var proc: Pointer; name: PAnsiChar);
  begin
    proc := GetProcAddress(hlib, name);
    if proc <> nil then
      PushProc(@proc);
  end;
begin
  {$IFDEF Windows}
  Freeclamav;
 {$ENDIF}
  hlib := LoadLibrary(lib);
  if hlib = 0 then
  raise Exception.Create(format('Could not load library: %s', [lib]));
  assign_proc(@cl_init, 'cl_init');
  assign_proc(@cl_engine_new, 'cl_engine_new');
  assign_proc(@cl_engine_set_num, 'cl_engine_set_num');
  assign_proc(@cl_engine_get_num, 'cl_engine_get_num');
  assign_proc(@cl_engine_set_str, 'cl_engine_set_str');
  assign_proc(@cl_engine_get_str, 'cl_engine_get_str');
  assign_proc(@cl_engine_settings_copy, 'cl_engine_settings_copy');
  assign_proc(@cl_engine_settings_apply, 'cl_engine_settings_apply');
  assign_proc(@cl_engine_settings_free, 'cl_engine_settings_free');
  assign_proc(@cl_engine_compile, 'cl_engine_compile');
  assign_proc(@cl_engine_addref, 'cl_engine_addref');
  assign_proc(@cl_engine_free, 'cl_engine_free');
  assign_proc(@cl_engine_set_clcb_pre_scan, 'cl_engine_set_clcb_pre_scan');
  assign_proc(@cl_engine_set_clcb_post_scan, 'cl_engine_set_clcb_post_scan');
  assign_proc(@cl_engine_set_clcb_sigload, 'cl_engine_set_clcb_sigload');
  assign_proc(@cl_set_clcb_msg, 'cl_set_clcb_msg');
  assign_proc(@cl_engine_set_clcb_hash, 'cl_engine_set_clcb_hash');
  assign_proc(@cl_scandesc, 'cl_scandesc');
  assign_proc(@cl_scandesc_callback, 'cl_scandesc_callback');
  assign_proc(@cl_scanfile, 'cl_scanfile');
  assign_proc(@cl_scanfile_callback, 'cl_scanfile_callback');
  assign_proc(@cl_load, 'cl_load');
  assign_proc(@cl_retdbdir, 'cl_retdbdir');
  assign_proc(@cl_cvdhead, 'cl_cvdhead');
  assign_proc(@cl_cvdparse, 'cl_cvdparse');
  assign_proc(@cl_cvdverify, 'cl_cvdverify');
  assign_proc(@cl_cvdfree, 'cl_cvdfree');
  assign_proc(@cl_statinidir, 'cl_statinidir');
  assign_proc(@cl_statchkdir, 'cl_statchkdir');
  assign_proc(@cl_statfree, 'cl_statfree');
  assign_proc(@cl_countsigs, 'cl_countsigs');
  assign_proc(@cl_debug, 'cl_debug');
  assign_proc(@cl_retflevel, 'cl_retflevel');
  assign_proc(@cl_retver, 'cl_retver');
  assign_proc(@cl_strerror, 'cl_strerror');
  IsLibraryLoaded := True;

end;

function IsClamAVLibPresent: Boolean;
{$IFDEF LINUX}
  var
    OutList: Tstringlist;
    Proc: TProcess;
 {$ENDIF}
begin
  {$IFDEF Fpc}
   {$IFDEF Linux}
  OutList := Tstringlist.create;
  Proc := TProcess.Create(nil);
  Proc.Options := [poWaitOnExit,poUsePipes];
  Proc.Executable := 'whereis';
  Proc.Parameters.Add('-b');
  Proc.Parameters.Add(External_library);
  Proc.Execute;
  OutList.LoadFromStream(Proc.Output);
  Proc.Free;
  if Length(OutList.Strings[0])>13 then Result:=true
   else Result:=false;
   OutList.free;
    {$ELSE}
        Result := FileExists(External_library);
   {$ENDIF}
  {$ELSE}
  	Result := FileExistsUTF8(External_library);
  {$ENDIF}
end;

procedure Initclamav;
begin
  try
    IsLibraryLoaded := False;
    if IsClamAVLibPresent then
    Loadclamav(External_library);
  except
    on E: Exception do
     begin
     WriteLn(E.Message);
     Halt; // go finalization
    end;
  end;
end;

initialization
Initclamav;

finalization
 Freeclamav;

end.
