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
unit BSON;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

const
  BSON_EOF          = $00;
  BSON_FLOAT        = $01; //double 8-byte float
  BSON_STRING       = $02; //UTF-8 string
  BSON_DOC          = $03; //embedded document
  BSON_ARRAY        = $04; //bson document but using integer string for key
  BSON_BINARY       = $05; //
//  BSON_UNDEFINED    = $06; //deprecated
  BSON_OBJECTID     = $07; //
  BSON_BOOLEAN      = $08; //false:$00, true:$01
  BSON_DATETIME     = $09;
  BSON_NULL         = $0A;
  BSON_REGEX        = $0B; //
//  BSON_REF          = $0C; //deprecated
  BSON_CODE         = $0D;
  BSON_SYMBOL       = $0E;
  BSON_CODE_W_SCOPE = $0F;
  BSON_INT32        = $10;
  BSON_TIMESTAMP    = $11;
  BSON_INT64        = $12;
  BSON_MINKEY       = $FF;
  BSON_MAXKEY       = $7F;
  {subtype}
  BSON_SUBTYPE_GENERIC = $00;
  BSON_SUBTYPE_FUNC    = $01;
  BSON_SUBTYPE_OLD_BINARY  = $02;
  BSON_SUBTYPE_UUID    = $03;
  BSON_SUBTYPE_MD5     = $05;
  BSON_SUBTYPE_USER    = $80;
  {boolean constant}
  BSON_BOOL_FALSE      = $00;
  BSON_BOOL_TRUE       = $01;

const
  OP_REPLY        = 1;
  OP_MSG          = 1000;
  OP_UPDATE       = 2001;
  OP_INSERT       = 2002;
  OP_QUERY        = 2004;
  OP_GET_MORE     = 2005;
  OP_DELETE       = 2006;
  OP_KILL_CURSORS = 2007;

const
  //special prefix with unassigned(?) unicode symbols from the Special range
  bsonJavaScriptCodePrefix:WideString=#$FFF1'bsonJavaScriptCode'#$FFF2;
  bsonRegExPrefix:WideString=#$FFF1'bsonRegEx'#$FFF2;

  BSON_OBJECTID_PREFIX = 'ObjectId("';
  BSON_OBJECTID_SUFIX = '")';

type
  TMongoMsgHeader = packed record
    length: integer;
    requestID: integer;
    responseTo: integer;
    opcode: integer;
  end;

type
  TMongoWireMsgHeader=packed record
    MsgLength:integer;
    RequestID:integer;
    ResponseTo:integer;
    OpCode:integer;
    Flags:integer;
    //for server response only:
    CursorID:int64;
    StartingFrom:integer;
    NumberReturned:integer;
  end;
  PMongoWireMsgHeader=^TMongoWireMsgHeader;

implementation

end.
